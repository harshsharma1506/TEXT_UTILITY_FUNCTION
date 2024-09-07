FUNCTION z_text_mail_utility.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_TEXT_NAME) TYPE  TDNAME
*"     REFERENCE(I_TXT_ID) TYPE  TDID
*"     REFERENCE(I_TXT_OBJ) TYPE  TDOBJECT
*"     REFERENCE(I_SPRAS) TYPE  SPRAS
*"     REFERENCE(I_PROGRAM) TYPE  REPID
*"     REFERENCE(I_SET_MAIL) TYPE  CHAR1 OPTIONAL
*"     REFERENCE(I_SENDER_ADDRESS) TYPE  ADR6-SMTP_ADDR OPTIONAL
*"     REFERENCE(I_RECEPIENT_ADDRESS) TYPE  ADR6-SMTP_ADDR OPTIONAL
*"     REFERENCE(I_TITLE) TYPE  CHAR50
*"  TABLES
*"      T_VAR_NAME STRUCTURE  SOLI
*"      T_MESS STRUCTURE  BAPIRET2
*"      T_TEXT_LINES STRUCTURE  TLINE
*"  EXCEPTIONS
*"      TEXT_NOT_PRESENT
*"      OTHERS
*"      VARIABLE_NOT_FOUND
*"      EXTRA_VAR_FOUND
*"      INCORRECT_PARAM_FOR_MAIL
*"----------------------------------------------------------------------
  "Author - Harsh Sharma

  DATA: ls_text_lines     TYPE soli,
        lo_sender_mail    TYPE REF TO if_sender_bcs,
        lo_recepient_mail TYPE REF TO if_recipient_bcs,
        lt_doc            TYPE soli_tab,  " for mail text
        ls_doc            TYPE LINE OF soli_tab,
        lo_doc            TYPE REF TO cl_document_bcs.
*--> Initial  Validation
  SELECT SINGLE tdname FROM stxh
    WHERE tdid = @i_txt_id
    AND   tdobject = @i_txt_obj
    AND   tdspras = @i_spras
    INTO @DATA(lv_text_name).
  IF sy-subrc = 0 AND lv_text_name <> i_text_name.
    RAISE text_not_present.                        "first exception
  ELSEIF sy-subrc = 0.
    CALL FUNCTION 'READ_TEXT'                    "read the text
      EXPORTING
        id                      = i_txt_id
        language                = i_spras
        name                    = i_text_name
        object                  = i_txt_obj
      TABLES
        lines                   = t_text_lines
      EXCEPTIONS
        id                      = 1
        language                = 2
*       NAME                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc = 0.
      RAISE others.
      SEARCH t_text_lines FOR '&'.             "check if there are even text symbols used
      IF sy-subrc = 0.
*--> Read the table var name first and check if the text symbols are same.
        DATA(lt_text_lines) = t_text_lines[].
        DATA(lv_var_concat) = space.
        LOOP AT t_var_name INTO DATA(s_var_name).
          lv_var_concat = '&' && s_var_name-line && '&'.
          SEARCH lt_text_lines FOR lv_var_concat AND MARK.
          DATA(lv_tabix) = sy-tabix.
          IF sy-subrc = 0.
            READ TABLE lt_text_lines INTO ls_text_lines INDEX lv_tabix.
            IF sy-subrc = 0.
              REPLACE ALL OCCURRENCES OF lv_var_concat
              IN ls_text_lines WITH space.
              MODIFY lt_text_lines FROM ls_text_lines INDEX lv_tabix.
            ENDIF.
          ELSE.
            RAISE variable_not_found.
          ENDIF.
        ENDLOOP.
*--> Check if there is any extra text symbol other than mentioned in the table
        SEARCH lt_text_lines FOR '&'.
        IF sy-subrc = 0.
          RAISE extra_var_found.
        ENDIF.
*--> All text symbols have been verified.
        CALL FUNCTION 'SET_TEXTSYMBOL_PROGRAM' "calling the setting of program this will read the values
          EXPORTING
            program = i_program
            event   = 'OPEN_FORM'.
        IF sy-subrc = 0.
          DATA(lv_lines) = lines( t_text_lines ).
          CALL FUNCTION 'REPLACE_TEXTSYMBOL'
            EXPORTING
              endline          = lv_lines
              replace_program  = 'X'
              replace_standard = 'X'
              replace_system   = 'X'
              replace_text     = 'X'
              startline        = 1
            TABLES
              lines            = t_text_lines.
        ENDIF.
      ENDIF.
    ENDIF.
*--> mail logic
    IF i_set_mail IS NOT INITIAL.
      TRY.
          DATA(lo_send) = cl_bcs=>create_persistent( ).
        CATCH cx_send_req_bcs.    "
      ENDTRY.
      IF i_sender_address IS NOT INITIAL.
        lo_sender_mail ?=
               cl_cam_address_bcs=>create_internet_address(
                 i_address_string = i_sender_address ).
      ELSE.
        RAISE incorrect_param_for_mail.
      ENDIF.
      IF i_recepient_address IS NOT INITIAL.
        lo_recepient_mail ?= cl_cam_address_bcs=>create_internet_address(
                         i_address_string = i_recepient_address ).
      ELSE.
        RAISE incorrect_param_for_mail.
      ENDIF.
      MOVE-CORRESPONDING t_text_lines[] TO lt_doc[].
      lo_doc = cl_document_bcs=>create_document(
                      EXPORTING
                        i_type          =  'RAW'    " Code for Document Class
                        i_subject       =  i_title    " Short Description of Contents
                        i_text          =  lt_doc   " Content (Textual))
                        ).
      lo_send->set_document( i_document = lo_doc ).
      lo_send->send( ).
    ENDIF.
  ENDIF.
ENDFUNCTION.

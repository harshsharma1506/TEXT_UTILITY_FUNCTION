REPORT z_test_program.
DATA: lv_username TYPE string VALUE 'Harsh Sharma',
      lv_port     TYPE string VALUE 'Bandra',
      lv_carriage TYPE string VALUE '19908AB',
      lv_sender   TYPE string VALUE 'Rohit',
      var_name    TYPE STANDARD TABLE OF soli,
      ls_var      TYPE soli,
      lt_text     TYPE STANDARD TABLE OF tline,
      lt_mess     TYPE STANDARD TABLE OF bapiret2.

ls_var-line = 'LV_USERNAME'.
APPEND ls_var TO var_name.

ls_var-line = 'LV_PORT'.
APPEND ls_var TO var_name.

ls_var-line = 'LV_CARRIAGE'.
APPEND ls_var TO var_name.

ls_var-line = 'LV_SENDER'.
APPEND ls_var TO var_name.


CALL FUNCTION 'Z_TEXT_MAIL_UTILITY'
  EXPORTING
    i_text_name              = 'Z_TEST_NORMAL_TS'
    i_txt_id                 = 'ST'
    i_txt_obj                = 'TEXT'
    i_spras                  = 'E'
    i_program                = sy-repid
    i_set_mail               = 'X'
    i_sender_address         = 'xxx@gmail.com'
    i_recepient_address      = 'yyy@gmail.com'
    i_title                  = 'tst'
  TABLES
    t_var_name               = var_name
    t_mess                   = lt_mess
    t_text_lines             = lt_text
  EXCEPTIONS
    text_not_present         = 1
    others_issue             = 2
    variable_not_found       = 3
    extra_var_found          = 4
    incorrect_param_for_mail = 5.
IF sy-subrc <> 0.
  MESSAGE 'Check your exceptions' TYPE 'E'.
ENDIF.

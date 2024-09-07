# TEXT_UTILITY_FUNCTION
Following is an SO10 Text Mail and dynamic reading utility FM 
Recently while working on one file interface to AL11, I had to send mail as well, and the SO10 texts came with many text symbols so that is where the inspiration for this FM has been drawn from.

## Standard FMs used inside 
* READ_TEXT
* SET_TEXTSYMBOL_PROGRAM
* REPLACE_TEXTSYMBOL

## Mail Functionality 
* CL_BCS ( Business Communication Service )

## Few things to note and ramblings - 
   There is table for variables where we are mentioning Text Symbols already , it is just a scractch for my logic 
   building itch. So if you see the loop at line#69 , ideally you shall ignore it but it was fun.

   ```
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
   ```

   In ideal scenario this can translate as checking the text table we will be getting from READ_TEXT
   and then we can take this table and use our select from itab .

   ```
   SELECT SINGLE tdline FROM @t_text_lines AS a
   WHERE tdline LIKE '%&%'
   INTO @DATA(ls_rem_text).
   ```
   After this we must save a warning message in MESS_TAB so that the user can check if there's any variable left
   at times people use '&' for 'and' so warning is fine.


   

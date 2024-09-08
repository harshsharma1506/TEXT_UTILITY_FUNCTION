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

   ```abap
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

   ```abap
   SELECT SINGLE tdline FROM @t_text_lines AS a
   WHERE tdline LIKE '%&%'
   INTO @DATA(ls_rem_text).
   ```
   After this we must save a warning message in MESS_TAB so that the user can check if there's any variable left
   at times people use '&' for 'and' so warning is fine.

### Issues - 1 

Added one perfect fix to the issue of offsets :) 

```abap
      LOOP AT lt_doc ASSIGNING FIELD-SYMBOL(<fs>).
        DATA(ls_var)  = find_any_of( val = <fs>-line sub = '*=/:' ).
        IF ls_var <> -1.
          ls_var = ls_var + 1.
          DATA(ls_var_temp) = ls_var - 1.
          REPLACE ALL OCCURRENCES OF <fs>-line+ls_var_temp(ls_var) IN <fs>-line WITH space.
          CONDENSE <fs>-line.
        ENDIF.
        CONDENSE <fs>-line.
      ENDLOOP.
```

### SO10 text to be used for testing 
```
*	 	Hello &lv_username&,
*	 	Your order has been shipped from port &lv_port& , it is being carried
=	 	via carriage: &lv_carriage&. Please visit www.testdata.com/orders
=	 	for further details.
*	 	Thanks,
*	 	&lv_sender&
__	_	________________________________________________________________________
```

### Debugging Screenshots

1. Read Text -
![image](https://github.com/user-attachments/assets/478cd6fb-723d-4cf3-9e70-58d08e3e3ac9)

2. SET Program - ( Before that we scratched that itch )
![image](https://github.com/user-attachments/assets/f7c890c1-2667-4e94-bfd2-ebce5b763cbb)
![image](https://github.com/user-attachments/assets/a3c03743-fa33-4263-b100-0161bd1e8fb6)

4. Replace and magic :)
![image](https://github.com/user-attachments/assets/9f28da69-375c-4373-b67a-026e99e60f8b)

5. Mail Indicator -
![image](https://github.com/user-attachments/assets/006988dd-c9ec-4ef0-8ff0-232b29986fca)







   

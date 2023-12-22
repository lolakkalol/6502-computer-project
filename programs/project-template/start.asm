; Author: Alexander Stenlund
; Description: This file is used for all code needed to 
; initilize/start the program in ROM. It has two main 
; responsibilities: 1) load the data in the DATA section 
; into RAM and 2) Set the reset vector in ROM.

.import __CODE_RUN__

.import __LOAD_RUN__

.import __DATA_LOAD__
.import __DATA_RUN__
.import __DATA_SIZE__

;  +----------------+
;  |  LOAD SEGMENT  |
;  +================+

.segment "LOAD"

; Add code to load DATA section

jmp __CODE_RUN__


;  +----------------+
;  |  RESET VECTOR  |
;  +================+

.segment "PC_START"
.WORD __LOAD_RUN__
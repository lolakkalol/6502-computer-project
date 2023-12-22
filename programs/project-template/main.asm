; Author: Alexander Stenlund
; Description: This is a project template for easy creation 
; of 6502 applications

; imports
.import add_two

;  +----------------+
;  |  DATA SEGMENT  |
;  +================+
;
; Description: Add initilized read/write data here. This 
; data will be copied into RAM at startup, use labes as 
; usual.
.segment "DATA"
Number: .byte $12, $34, $56

;  +------------------+
;  |  RODATA SEGMENT  |
;  +==================+
;
; Description: Add static data here. This data will be
; located inside the ROM.
.segment "RODATA"
RONumber: .byte $AB, $CD, $EF

;  +----------------+
;  |  CODE SEGMENT  |
;  +================+
;
; Description: This section contains all of the "main" code,
; this will be the first executable code (After the copy of
; DATA into RAM in LOAD section).
.segment "CODE"

; Load number from RAM
LDA Number
JSR add_two

; Store calculated value in RAM
STA Number

; Stop the program from progressing further
END_: JMP END_
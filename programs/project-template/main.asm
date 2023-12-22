; Author: Alexander Stenlund
; Description: This is a project template for easy creation 
; of 6502 applications

; imports
.import add_two

.segment "CODE"

LDA #100
JSR add_two

; Stop the program from progressing further
END_: JMP END_
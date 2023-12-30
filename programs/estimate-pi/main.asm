; Author: Alexander Stenlund
; Description: This is a project template for easy creation 
; of 6502 applications

;  +-----------+
;  |  IMPORTS  |
;  +===========+
;.import LSR32A
;.import LDA32I
.import FADD32A
.import LF32A
.import LF32B

;  +-----------+
;  |  EXPORTS  |
;  +===========+
.export A32, B32, A16, FLOAT_A, FLOAT_B

;  +----------------+
;  |  DATA SEGMENT  |
;  +================+
;
; Description: Add initilized read/write data here. This 
; data will be copied into RAM at startup, use labes as 
; usual.
.segment "DATA"

;  +----------------+
;  |   ZP SEGMENT   |
;  +================+
;
; Description: The zero page of memory in SRAM, will be 
; initilized.
.zeropage
A32:  .DWORD $41200000
B32:  .DWORD $C1300000
A16:  .WORD 0
; Unpacked 32 bit float
; | 3 Bytes mantissa | 1 Byte exponent | 1 Byte sign (+/-) |
FLOAT_A: .BYTE 0, 0, 0, 0, 0
FLOAT_B: .BYTE 0, 0, 0, 0, 0

; Exception flags for IEEE754
; These flags are only lowered by the request of the user
; and raised by the floating point operations.
; | LSB <--------------------------- Bits --------------------------> MSB |
; | Invalid operation | Division by zero | Overflow | Underflow | Inexact |
FLOAT_STATUS: .BYTE $00

;  +------------------+
;  |  RODATA SEGMENT  |
;  +==================+
;
; Description: Add static data here. This data will be
; located inside the ROM.
.segment "RODATA"

;  +----------------+
;  |  CODE SEGMENT  |
;  +================+
;
; Description: This section contains all of the "main" code,
; this will be the first executable code (After the copy of
; DATA into RAM in LOAD section).
.segment "CODE"

; MAIN SEGMENT :D

LDA #A32
JSR LF32A
LDA #B32
JSR LF32B
JSR FADD32A

; Stop the program from progressing further
END_: JMP END_
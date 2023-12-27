; Description: This is an example file demonstrating how
; libraries can be constructed in CA65 assembler.

;  +-----------+
;  |  IMPORTS  |
;  +===========+

; 32 bit general registers, stored in RAM (ZP)
.importzp A32, B32

; 8 bit general register, stored in RAM (ZP)
.importzp A16, FLOAT_A, FLOAT_B

;  +---------------------+
;  |  LF32A SUB-ROUTINE  |
;  +=====================+
; DESC  : Loads a 32 bit float steam into a unpacked format 
;         in FLOAT_A.
; INPUT : ZP address in Accumalator
; OUTPUT: FLOAT_A
;
; The expected Float data format
; Address : low ------------------------------------ high :
; Data    : 23 bit mantissa : 8 bit exponent : 1 bit sign :
;

.export LF32A
.proc LF32A

STA A16

PHA
TYA
PHA

LDY #0

; Load mantissa into the float register
LDA (A16), Y
STA FLOAT_A
INY

LDA (A16), Y
STA FLOAT_A+1
INY

LDA (A16), Y
STA FLOAT_A+2
INY
SMB7 FLOAT_A+2 ; Set MSB as it belongs to the exponent and 
               ; can be used for the implicit bit.

; Load exponent into the float register
AND #$80
CLC
ROL
ROL
STA FLOAT_A+3

LDA (A16), Y
INY
ASL
ORA FLOAT_A+3
STA FLOAT_A+3

; Load Sign
LDA #0
ROL ; Get the bit we shifted out
STA FLOAT_A+4

PLA
TAY
PLA

RTS
.endproc

;  +---------------------+
;  |  LF32B SUB-ROUTINE  |
;  +=====================+
; DESC  : Loads a 32 bit float steam into a unpacked format 
;         in FLOAT_B.
; INPUT : ZP address in Accumalator
; OUTPUT: FLOAT_B
;
; The expected Float data format
; Address : low ------------------------------------ high :
; Data    : 23 bit mantissa : 8 bit exponent : 1 bit sign :
;

.export LF32B
.proc LF32B

STA A16

PHA
TYA
PHA

LDY #0

; Load mantissa into the float register
LDA (A16), Y
STA FLOAT_B
INY

LDA (A16), Y
STA FLOAT_B+1
INY

LDA (A16), Y
STA FLOAT_B+2
INY
SMB7 FLOAT_B+2 ; Set MSB as it belongs to the exponent and 
               ; can be used for the implicit bit.

; Load exponent into the float register
AND #$80
CLC
ROL
ROL
STA FLOAT_B+3

LDA (A16), Y
INY
ASL
ORA FLOAT_B+3
STA FLOAT_B+3

; Load Sign
LDA #0
ROL ; Get the bit we shifted out
STA FLOAT_B+4

PLA
TAY
PLA

RTS
.endproc

;  +-----------------------+
;  |  MLSR32A SUB-ROUTINE  |
;  +=======================+
; DESC  : Right shift the mantissa of A32.
; INPUT : None.
; OUTPUT: A32[0-2] inclusive = A32[0-2] inclusive >> 1

.export MLSR32A
.proc MLSR32A

ROR A32 + 2
ROR A32 + 1
ROR A32

RTS
.endproc

;  +----------------------+
;  | FADD32A SUB-ROUTINE  |
;  +======================+
; DESC  : Adds FLOAT_A and FLOAT_B togheter
; INPUT : None.
; OUTPUT: FLOAT_A = FLOAT_A + FLOAT_B. Destroys FLOAT_B
;
; The packed Float data format
; Address : low ------------------------------------ high :
; Data    : 23 bit mantissa : 8 bit exponent : 1 bit sign :
;
; The expected Float data format (Unpacked) 
; Adr  : low --------------------------------------- high :
; Data : 3 bytes mantissa : 1 byte exponent : 1 byte sign :

.export FADD32A
.proc FADD32A
PHA

LDA FLOAT_A + 3 ; FLOAT_A - FLOAT_B; checks which is larger
SEC
SBC FLOAT_B + 3
BEQ MANTIS_SHIFT_END
BPL B_SMALLER

A_SMALLER:    ; Float_A was smaller, shift mantis until the 
LSR FLOAT_A+2 ; same exponent as FLOAT_B can be used.
ROR FLOAT_A+1
ROR FLOAT_A
INC FLOAT_A+3
INC
BNE A_SMALLER
JMP MANTIS_SHIFT_END

B_SMALLER:
; Float_B was smaller
LSR FLOAT_B+2
ROR FLOAT_B+1
ROR FLOAT_B
INC FLOAT_B+3
DEC
BNE B_SMALLER

MANTIS_SHIFT_END:

LDA FLOAT_A+4 ; If signs are the same, skipp two's 
EOR FLOAT_B+4 ; complement.
BEQ ADD_AB

LDA FLOAT_A+4
BEQ FLOAT_A_POS ; Take two's complement of FLOAT_A
LDA FLOAT_A
EOR #$FF
CLC
ADC #1
STA FLOAT_A
LDA FLOAT_A+1
EOR #$FF
ADC #0
STA FLOAT_A+1
LDA FLOAT_A+2
EOR #$FF
ADC #0
STA FLOAT_A+2
FLOAT_A_POS:

LDA FLOAT_B+4   ; Test sign bit
BEQ FLOAT_B_POS ; Take two's complement of FLOAT_B
LDA FLOAT_B
EOR #$FF
CLC
ADC #1
STA FLOAT_B
LDA FLOAT_B+1
EOR #$FF
CLC
ADC #1
STA FLOAT_B+1
LDA FLOAT_B+2
EOR #$FF
ADC #0
STA FLOAT_B+2
FLOAT_B_POS:

ADD_AB:
CLC
LDA FLOAT_A   ; Add A+B
ADC FLOAT_B
STA FLOAT_A

LDA FLOAT_A+1
ADC FLOAT_B+1
STA FLOAT_A+1

LDA FLOAT_A+2
ADC FLOAT_B+2
STA FLOAT_A+2

LDA FLOAT_A+4 ; Skip sign change if equal
EOR FLOAT_B+4
BEQ SAME

BCC NEG   ; If not CARRY, when sign not same, final sign negative
LDA #0        ; Set FLOAT_A (result) Possitive
STA FLOAT_A+4
JMP DONE

NEG:
LDA #1
STA FLOAT_A+4
SEC
LDA FLOAT_A
SBC #1
EOR #$FF
STA FLOAT_A
LDA FLOAT_A+1
SBC #0
EOR #$FF
STA FLOAT_A+1
LDA FLOAT_A+2
SBC #0
EOR #$FF
STA FLOAT_A+2
JMP DONE

SAME:
BCC DONE      ; Check if addition overflowed and if, right 
ROR FLOAT_A+2 ; shift as to keep the MSB which was shifted
ROR FLOAT_A+1 ; out.
ROR FLOAT_A
INC FLOAT_A+3

DONE:
LDA FLOAT_A    ; Check if result was zero and set exponent 
BNE Normalize  ; to zero if that is the case, then jump
LDA FLOAT_A+1  ; to end.
BNE Normalize
LDA FLOAT_A+2
BNE Normalize
STA FLOAT_A+3
JMP DONE2

Normalize:
LDA FLOAT_A+2 ; Moves the highest 1 to bit 7 of +3 if needed
AND #$80
BNE DONE2
ASL FLOAT_A   ; This needs to be tested
ROL FLOAT_A+1
ROL FLOAT_A+2
DEC FLOAT_A+3
JMP Normalize

DONE2:

PLA
RTS
.endproc
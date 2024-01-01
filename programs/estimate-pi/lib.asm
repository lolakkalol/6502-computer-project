;  +-----------+
;  |  IMPORTS  |
;  +===========+

; 32 bit general registers, stored in RAM (ZP)
.importzp A32, B32

; 8 bit general register, stored in RAM (ZP)
.importzp A16, FLOAT_A, FLOAT_B

;  +-----------+
;  |  DEFINES  |
;  +===========+
; These variables define up the byte positions of the 
; bifferent parts of the unpacked float.
m0=0
m1=1
m2=2
m3=3
e0=4
s0=5

;  +---------------------------+
;  |  !! FLOAT INFORMATION !!  |
;  +===========================+
;
; This file contains a bunch of sub-routines aiming for 
; compliance with a significant portion of IEEE754 excluding
; the default handling of signal NaNs, these signal NaNs are
;  treated as normal quite NaNs. The only type of NaN use in
; this implementation if the quire NaN.
;
; --- Float format ---
; The only fully suported float format is the binary32 
; format, however conversion to some kind of decimal 
; reprecentation is a goal.
; The routines act on two different types of float, one is 
; the packed variant (as specified in IEEE754 and below), but
; also an unpacked variant for ease of writing the routines
; and performance. The routines do not automatically 
; convert between these formats and a seperate routine must
; be called before hand to prepare for an operand. This 
; seperation of unpacking the float saves us some cycles as 
; we do not need to unpack and pack between different 
; operations and can do all calculations in the unpacked 
; form and then once finished pack it. To know when the 
; format is unpacked, the unpacking routines always unpack 
; to one of the float accumalators, currently FLOAT_A and 
; FLOAT_B these accumalators can be assumed to be in an 
; unpacked format. The binary format of the different
;
; The packed binary32 float per IEEE754.
; Address : low ------------------------------------ high :
; Data    : 23 bit mantissa : 8 bit exponent : 1 bit sign :
;
; Unpacked binary32 float, no implicit bit, but we still 
; normalise the leading '1' to the MSB.
; Address : low --------------------------------------- high :
; Data    : 4 bytes mantissa : 1 byte exponent : 1 byte sign :

;  +-------------------------------+
;  |  roundTiesToEven SUB-ROUTINE  |
;  +===============================+
; DESC  : Rounds the FLOAT_A float accumalator mantissa from
; 32 to 24 bits  by, if no possible ambiguity, to its closes
; equivalent, if that is not possible it rounds to the 
; closest event number that the 24 bit mantissa can 
; represent. The extra byte is the last byte in the unpacked
; format.
; INPUT : FLOAT_A
; OUTPUT: FLOAT_A
;

.export roundTiesToEven
.proc roundTiesToEven
PHA
LDA FLOAT_A+m0
SEC
SBC #128
BMI ROUND_DOWN ; Extra byte > 128
BNE ROUND_UP   ; Extra byte < 128

LDA FLOAT_A+m2 ; Extra byte MSb set
AND #1
BEQ ROUND_DOWN

ROUND_UP:
CLC            ; Add 1 to mantissa (Except extra byte)
LDA FLOAT_A+m1
ADC #1
STA FLOAT_A+m1
LDA FLOAT_A+m2
ADC #0
STA FLOAT_A+m2
LDA FLOAT_A+m3
ADC #0
STA FLOAT_A+m3

BCC ROUND_DOWN ; Last add carried
ROR FLOAT_A+m0 ; Right shift mantissa
ROR FLOAT_A+m1
ROR FLOAT_A+m2

INC FLOAT_A+e0 ; Increment exponent

ROUND_DOWN:
LDA #0         ; Set extra byte = 0
STA FLOAT_A+m0

PLA
RTS
.endproc

;  +---------------------+
;  |  LF32A SUB-ROUTINE  |
;  +=====================+
; DESC  : Loads a 32 bit float steam into a unpacked format 
;         in FLOAT_A.
; INPUT : ZP address in Accumalator
; OUTPUT: FLOAT_A
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
;  +-----------+
;  |  IMPORTS  |
;  +===========+

; 32 bit general registers, stored in RAM (ZP)
.importzp A32, B32

; 8 bit general register, stored in RAM (ZP)
.importzp A16, FLOAT_A, FLOAT_B, FLOAT_STATUS

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

;  +-------------------------------+
;  |  ADD_STAGED_FLOATS SUB-ROUTINE  |
;  +===============================+
; DESC  : Add the two unpacked floats, FLOAT_A and FLOAT_B. 
; Is able to handle negative floats.
; INPUT : FLOAT_A, FLOAT_B
; OUTPUT: FLOAT_A = FLOAT_A + FLOAT_B
;

.export ADD_STAGED_FLOATS
.proc ADD_STAGED_FLOATS
PHA

; --- Check for invalid and inf operations ---
LDA FLOAT_A+e0     ; FLOAT_A exponent == $FF
CMP #$FF
BNE FLOAT_A_NORMAL

LDA FLOAT_A+m0     ; FLOAT_A == +/-Inf
BNE INVALID_OP
LDA FLOAT_A+m1
BNE INVALID_OP
LDA FLOAT_A+m2
BNE INVALID_OP
LDA FLOAT_A+m3
BNE INVALID_OP

; FLOAT_B exponent != $FF OR (FLOAT_B == (+/-) inf && FLOAT_B sign == FLOAT_A)
LDA FLOAT_B+e0 ; Check exponent is $FF
CMP #$FF
BNE RETURN_A_INF
LDA FLOAT_B+m0 ; Check mantissa is $00
BNE INVALID_OP
LDA FLOAT_B+m1
BNE INVALID_OP
LDA FLOAT_B+m2
BNE INVALID_OP
LDA FLOAT_B+m3
BNE INVALID_OP
LDA FLOAT_B+s0
SEC
SBC FLOAT_A+s0 ; Check if signs are the same
BNE INVALID_OP
JMP RETURN_A_INF

FLOAT_A_NORMAL:
LDA FLOAT_B+e0     ; FLOAT_B exponent == $FF
CMP #$FF
BNE FLOAT_B_NORMAL

LDA FLOAT_B+m0      ; FLOAT_B == +/-Inf
BNE INVALID_OP
LDA FLOAT_B+m1
BNE INVALID_OP
LDA FLOAT_B+m2
BNE INVALID_OP
LDA FLOAT_B+m3
BNE INVALID_OP

; Set Float_A to INF with sign eq to FLOAT_B
LDA #0
STA FLOAT_A+m0
STA FLOAT_A+m1
STA FLOAT_A+m2
STA FLOAT_A+m3
LDA #$FF
STA FLOAT_A+e0
LDA FLOAT_B+s0
STA FLOAT_A+s0
JMP RETURN_A_INF


INVALID_OP:
LDA #0          ; Set Invalid OP flag Set FLOAT_A to qNan
STA FLOAT_A+m0
STA FLOAT_A+m1
STA FLOAT_A+m2
STA FLOAT_A+s0
LDA #$40
STA FLOAT_A+m3
LDA #$FF
STA FLOAT_A+e0
LDA FLOAT_STATUS ; Set Invalid OP flag
EOR #1
STA FLOAT_STATUS

RETURN_A_INF:
PLA
RTS

FLOAT_B_NORMAL:

; --- Shift routine ---
LDA FLOAT_A+e0 ; FLOAT_A exponent == FLOAT_B exponent ; Might be able to subtract instead to later save a few cycles
CMP FLOAT_B+e0
BEQ TO_ADDITION

; FLOAT_A exponent - FLOAT_B exponent >=32
SEC
SBC FLOAT_B+e0
SBC #32
BMI SHIFT_LOGIC; Branch if FALSE

; FLOAT_A exponent - FLOAT_B exponent IS possitive
ADC #32
BMI ADD_STAGED_FLOATS_RET
JSR MOV_FLOAT_B_TO_A ; Move FLOAT_B to FLOAT_A
JMP ADD_STAGED_FLOATS_RET

SHIFT_LOGIC:
ADC #32 ; Get back difference between FLOAT_A expo and FLOAT_B
SHIFT_LOGIC_LOOP:
BMI FLOAT_A_Smaller

; FLOAT_B smaller
LSR FLOAT_B+m3 ; Right shift FLOAT_B mantissa
ROR FLOAT_B+m2
ROR FLOAT_B+m1
ROR FLOAT_B+m0
DEC A
JMP SHIFT_LOGIC_LOOP_END

; FLOAT_A smaller
FLOAT_A_Smaller:
LSR FLOAT_A+m3 ; Right shift FLOAT_A mantissa
ROR FLOAT_A+m2
ROR FLOAT_A+m1
ROR FLOAT_A+m0
INC FLOAT_A+e0
INC A

; FLOAT_A exponent == FLOAT_B exponent
SHIFT_LOGIC_LOOP_END:
BNE SHIFT_LOGIC_LOOP


; --- Addition logic ---
TO_ADDITION:
LDA FLOAT_A+s0 ; FLOAT_A sign == FLOAT_B
EOR FLOAT_B+s0
BEQ END_TWO_COMPLEMENT

; FLOAT_A is negative
LDA FLOAT_A+s0
BEQ FLOAT_B_COMP
CLC
LDA FLOAT_A+m0
EOR #$FF
ADC #1
STA FLOAT_A+m0
LDA FLOAT_A+m1
EOR #$FF
ADC #0
STA FLOAT_A+m1
LDA FLOAT_A+m2
EOR #$FF
ADC #0
STA FLOAT_A+m2
LDA FLOAT_A+m3
EOR #$FF
ADC #0
STA FLOAT_A+m3

FLOAT_B_COMP:
; FLOAT_B is negative
LDA FLOAT_B+s0
BEQ END_TWO_COMPLEMENT
CLC
LDA FLOAT_B+m0
EOR #$FF
ADC #1
STA FLOAT_B+m0
LDA FLOAT_B+m1
EOR #$FF
ADC #0
STA FLOAT_B+m1
LDA FLOAT_B+m2
EOR #$FF
ADC #0
STA FLOAT_B+m2
LDA FLOAT_B+m3
EOR #$FF
ADC #0
STA FLOAT_B+m3

END_TWO_COMPLEMENT:
; FLOAT_A mantissa += FLOAT_B mantissa
CLC
LDA FLOAT_A+m0
ADC FLOAT_B+m0
LDA FLOAT_A+m1
ADC FLOAT_B+m1
LDA FLOAT_A+m2
ADC FLOAT_B+m2
LDA FLOAT_A+m3
ADC FLOAT_B+m3

; --- Post calculation checks ---
BCS MANTISSA_ADD_CARRIED ; Float mantissa addition carried

LDA FLOAT_A+s0 ; FLOAT_A sign == FLOAT_B sign
CMP FLOAT_B+s0
BEQ ROUND_FLOAT

; Negate two's complement
SEC
LDA FLOAT_A+m0
EOR #$FF
SBC #1
STA FLOAT_A+m0
LDA FLOAT_A+m1
EOR #$FF
SBC #0
STA FLOAT_A+m1
LDA FLOAT_A+m2
EOR #$FF
SBC #0
STA FLOAT_A+m2
LDA FLOAT_A+m3
EOR #$FF
SBC #0
STA FLOAT_A+m3
JMP ROUND_FLOAT

MANTISSA_ADD_CARRIED:
LDA FLOAT_A+s0 ; FLOAT_A sign == FLOAT_B sign
CMP FLOAT_B+s0
BEQ FLOAT_OVERFLOWED

; FLOAT_A leading bit == 1
CHECK_LEADING_BIT:
BIT FLOAT_A+m3
BMI ROUND_FLOAT

; Is exponent 1? (Biased)
LDA FLOAT_A+e0
CMP #0
BEQ SUB_NORMAL_RESULT
ASL FLOAT_A+m0
ROL FLOAT_A+m1
ROL FLOAT_A+m2
ROL FLOAT_A+m3
DEC FLOAT_A+e0
JMP CHECK_LEADING_BIT

FLOAT_OVERFLOWED:
; Right sfhift mantissa with carry (Carry in the carry bit)
ROR FLOAT_A+m3
ROR FLOAT_A+m2
ROR FLOAT_A+m1
ROR FLOAT_A+m0

; Increment FLOAT_A exponent
INC FLOAT_A+e0

; (Float exponent == $FE && Float mantissa == 7FFFFF) || Float exponent == $FF
LDA FLOAT_A+e0
CMP #$FF
BEQ RESULT_INF
CMP #$FF 
BNE ROUND_FLOAT
LDA FLOAT_A+m3
CMP #$FF
BNE ROUND_FLOAT
LDA FLOAT_A+m2
CMP #$FF
BNE ROUND_FLOAT
LDA FLOAT_A+m1
CMP #$FE
BMI ROUND_FLOAT ; Will branch if A is < $FE

RESULT_INF:
; SET FLOAT_A to inf
LDA #$FF
STA FLOAT_A+e0
STZ FLOAT_A+m0
STZ FLOAT_A+m1
STZ FLOAT_A+m2
STZ FLOAT_A+m3

SUB_NORMAL_RESULT:
LDA #0          ; Set FLOAT_A exponent 0
STA FLOAT_A+e0

ROUND_FLOAT:
JSR roundTiesToEven

ADD_STAGED_FLOATS_RET:
PLA
RTS
.endproc

;  +-------------------------------+
;  | MOV_FLOAT_B_TO_A SUB-ROUTINE  |
;  +===============================+
; DESC  : Moves the unpacked Float_B to float A's staging area
; INPUT : Float_B
; OUTPUT: FLOAT_A = FLOAT_B
;

.export MOV_FLOAT_B_TO_A
.proc MOV_FLOAT_B_TO_A
PHA

; Move sign
LDA FLOAT_B+s0
STA FLOAT_A+s0

; Move exponent
LDA FLOAT_B+e0
STA FLOAT_A+e0

; Move mantissa
LDA FLOAT_B+m0
STA FLOAT_A+m0
LDA FLOAT_B+m1
STA FLOAT_A+m1
LDA FLOAT_B+m2
STA FLOAT_A+m2
LDA FLOAT_B+m3
STA FLOAT_A+m3

PLA
RTS
.endproc
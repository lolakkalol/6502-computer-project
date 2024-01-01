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
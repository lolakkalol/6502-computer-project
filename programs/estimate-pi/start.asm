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

.import __ZEROPAGE_LOAD__
.import __ZEROPAGE_RUN__
.import __ZEROPAGE_SIZE__

;  +----------------+
;  |  LOAD SEGMENT  |
;  +================+
;
; Description: Loads the DATA segment into RAM. Currently 
; only handels one page of memory, i.e. $FF.
.segment "LOAD"

; :------------------------------:
; :----: LOAD DATA INTO RAM :----:
; :------------------------------:

LDX #.LOBYTE(__DATA_SIZE__)
LDA #.HIBYTE(__DATA_SIZE__)

; Stop execution if DATA section is over 255 bytes
inf: BNE inf

; Skip copying if low byte is zero
CPX #$0
BEQ DATA_LOAD_END

; Copy DATA in rom to DATA in RAM
data_cp_loop:
    DEX
    LDA __DATA_LOAD__, X  ; Loads the DATA at DATA_ROM + X
    STA __DATA_RUN__, X   ; Stores the DATA at DATA_RAM + X
    CPX #$0
    BNE data_cp_loop

DATA_LOAD_END:

; :----------------------------:
; :----: LOAD ZP INTO RAM :----:
; :----------------------------:

LDX #.LOBYTE(__ZEROPAGE_SIZE__)
LDA #.HIBYTE(__ZEROPAGE_SIZE__)

; Stop execution if ZP section is over 255 bytes
BNE inf

; Skip copying if low byte is zero
CPX #$0
BEQ LOAD_END

; Copy DATA in rom to DATA in RAM
zp_cp_loop:
    DEX
    LDA __ZEROPAGE_LOAD__, X  ; Loads the DATA at DATA_ROM + X
    STA __ZEROPAGE_RUN__, X   ; Stores the DATA at DATA_RAM + X
    CPX #$0
    BNE zp_cp_loop

; Jump to main code
LOAD_END: jmp __CODE_RUN__


;  +----------------+
;  |  RESET VECTOR  |
;  +================+

.segment "PC_START"
.WORD __LOAD_RUN__
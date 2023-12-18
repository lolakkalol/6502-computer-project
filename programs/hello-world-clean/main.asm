; Author: Alexander Stenlund
; Description: Writes the text "Hello, world!" to an LCD screen. It does this 
; though a memory mapped 65c22 VIA using both ports A and B. The LCD is 
; initilised to 8 bit mode and communicated with in a parallell bus on 
; port A and B.

.segment "CODE"

; Text to write to LCD
strHello: .asciiz "Hello, world!"
lenHello: .byte .STRLEN("Hello, world!")

; VIA Register addresses
DDRA = $6003
DDRB = $6002
IORA = $6001
IORB = $6000

; LCD Instruction codes
CLEAR  = $01
;RETURN = $02
DISDCB = $0E

; **************
; *   SET UP   *
; **************
start:
; Set PA and PB to OUTPUT
LDA #$FF
STA DDRA
STA DDRB

; Set PA0 HIGH
LDA #$01
STA IORA

; Clear outputs
LDA #$00
STA IORA
STA IORB

; Clear display
LDA #CLEAR
STA IORB

JSR toggle_e
JSR delay

; Set display modes
LDA #DISDCB
STA IORB

JSR toggle_e
JSR delay

; *******************
; * Write to screen *
; *******************

LDX #0

; Write string strHello to screen
writeLoop:
    LDA strHello, X ; Load the character at address acc + X
    STA IORB
    JSR toggle_e_CG
    JSR delay
    INX
    CPX lenHello
    BNE writeLoop

inf_loop: JMP inf_loop ; If at end we loop

; *******************
; *   Sub-routines  *
; *******************

toggle_e:
PHA
LDA #$20 ; E pin
STA IORA
LDA #$00 ; E pin
STA IORA
PLA
RTS

toggle_e_CG:
PHA
LDA #$60 ; E pin
STA IORA
LDA #$40 ; E pin
STA IORA
PLA
RTS

delay:
PHA ; Save the acumalator
TXA ; Save index X in acumalator

LDX #$FF      ; 2
    loop:
    DEX       ; 2
    CPX #$0   ; 2
    BNE loop  ; 2

TAX ; Transer index X from acumalator
PLA ; Pull acumalator from stack
RTS

.segment "PC_START"
.WORD start
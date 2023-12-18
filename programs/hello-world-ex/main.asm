.segment "CODE"

; VIA Register addresses

DDRA = $6003
DDRB = $6002
IORA = $6001
IORB = $6000

; LCD Instruction codes
CLEAR  = $01
;RETURN = $02
DISDCB = $0E

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

; Write H to the screen
LDA #'H'
STA IORB
JSR toggle_e_CG
JSR delay

LDA #'E'
STA IORB
JSR toggle_e_CG
JSR delay

LDA #'L'
STA IORB
JSR toggle_e_CG
JSR delay

LDA #'L'
STA IORB
JSR toggle_e_CG
JSR delay

LDA #'O'
STA IORB
JSR toggle_e_CG
JSR delay

LDA #','
STA IORB
JSR toggle_e_CG
JSR delay

LDA #' '
STA IORB
JSR toggle_e_CG
JSR delay

LDA #'W'
STA IORB
JSR toggle_e_CG
JSR delay

LDA #'O'
STA IORB
JSR toggle_e_CG
JSR delay

LDA #'R'
STA IORB
JSR toggle_e_CG
JSR delay

LDA #'L'
STA IORB
JSR toggle_e_CG
JSR delay

LDA #'D'
STA IORB
JSR toggle_e_CG
JSR delay

LDA #'!'
STA IORB
JSR toggle_e_CG
JSR delay

inf_loop: JMP inf_loop ; If at end we loop

toggle_e:
LDA #$20 ; E pin
STA IORA
LDA #$00 ; E pin
STA IORA
RTS

toggle_e_CG:
LDA #$60 ; E pin
STA IORA
LDA #$40 ; E pin
STA IORA
RTS

delay:
LDX #$FF      ; 2
    loop:
    DEX       ; 2
    CPX #$0   ; 2
    BNE loop  ; 2
RTS

.segment "PC_START"
.WORD $8000
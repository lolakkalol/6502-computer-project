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
;DDRA = $6003
DDRB = $6002
;IORA = $6001
IORB = $6000

; *************************
; *   SET UP 4-bit mode   *
; *************************
start:

; Set DDRB to output
LDA #$FF
STA DDRB

; Function set
LDA #$20 ; pin PB5
JSR command_LCD

; Function set
JSR command_LCD ; Repeat previous
JSR command_LCD ; Repeat previous

; Display on/off control
LDA #$00
JSR command_LCD

LDA #$E0 ; pins PB5 PB6 PB7
JSR command_LCD

; Entry mode set
LDA #$00
JSR command_LCD

LDA #$60 ; pins PB5 PB6
JSR command_LCD


; *******************
; * Write to screen *
; *******************

; Loop index
LDX #0

; Write string strHello to screen
writeLoop:
    ; Send first half of command (Upper char bytes)
    LDA strHello, X ; Load the character at address acc + X
    AND #$F0 ; Set all lower bits to zero
    ORA #$02 ; Set RS pin
    JSR command_LCD

    ; Send first half of command (Lower char bytes)
    LDA strHello, X ; Load the character at address acc + X
    ASL ; Shift the lower 4 bits up to the higher 4
    ASL
    ASL
    ASL
    ORA #$02 ; Set RS pin
    JSR command_LCD

    INX
    CPX lenHello
    BNE writeLoop

inf_loop: JMP inf_loop ; If at end we loop

; *******************
; *   Sub-routines  *
; *******************

; This sub-routine sends whatever data is in the 
; accumalator to the LCD.
command_LCD:
PHA

STA IORB ; Might be able to remove this instruction, test!
ORA #$08 ; pin E
STA IORB
LDA #$00 ; Setting all data to 0 should be fine...
STA IORB

PLA

JSR delay

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

; 1  2  4  8 10  20  40  80
; NC RS RW E PB4 PB5 PB6 PB7

; Sets 6502 zeroflag if the busy flag from the LCD is set
; Not working :(
get_LCD_BF:

; Set data pins to inputs zero their register
LDA #$0F
STA DDRB
LDA #$4 ; Set pin RW

; Read busy flag
LDA IORB ; Will also get that pin RW is SET!!
AND #$80 ; PB7
CMP #$80 

; Set zero flag if BF set


; Set data on bus to zero

; Change PB4-7 to output

RTS

.segment "PC_START"
.WORD start
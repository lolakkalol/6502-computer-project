.segment "CODE"

.import add_two

START_:
LDA #100
JSR add_two

END_: JMP END_


.segment "PC_START"
.WORD START_
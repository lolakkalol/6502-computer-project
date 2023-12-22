; Description: This is an example file demonstrating how
; libraries can be constructed in CA65 assembler.

;  +-----------------------+
;  |  ADD_TWO SUB-ROUTINE  |
;  +=======================+
;
; INPUT : Accumulator, value to add two to
; OUTPUT: Accumulator, the value increamented by two
.export add_two
.proc add_two
    INC A
    INC A
    RTS
.endproc
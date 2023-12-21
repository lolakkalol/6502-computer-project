; Description: 
; INPUT : Accumulator, value to add two to
; OUTPUT: Accumulator, the value increamented by two
.export add_two
.proc add_two
    INC A
    INC A
    RTS
.endproc
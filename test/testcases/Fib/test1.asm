addiu t1 r0 0x3
addiu t2 r0 0x1
addiu t3 r0 0x1
addu t2 t2 t3
bne t1 r0 0x3
addiu t1 t1 0xffff
jr r0
addu v0 t2 r0
addu t3 t2 t3
bne t1 r0 0xfff9
addiu t1 t1 0xffff
jr r0
addu v0 t3 r0

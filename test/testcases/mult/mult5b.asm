lui v0 0x7FFF
lui v1 0x7FFF
addiu t2 r0 0xffff
addiu t3 r0 0xffff
addu v0 v0 t2
addu v1 v1 t3
mult v0 v1
jr r0
mfhi v0

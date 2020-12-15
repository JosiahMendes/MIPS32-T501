lui v0 0x7FFF
lui v1 0x7FFF
addiu $14 r0 0xffff
addiu $15 r0 0xffff
mult v0 v1
jr r0
mfhi v0

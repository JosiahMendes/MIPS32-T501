addiu v0 r0 0x2
addiu v1 r0 0xffff
mult v0 v1
mfhi v0
jr r0
mflo v0

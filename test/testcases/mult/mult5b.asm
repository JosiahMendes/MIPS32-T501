lui v0 0xffff
srl v0 v0 16
lui t2 0x7fff
addu v0 v0 t2
lui v1 0xffff
srl v1 v1 16
lui t3 0x7fff
addu v1 v1 t3
mult v0 v1
jr r0
mfhi v0

addiu $14 $0 0xf0f0
sll $14 $14 0x10
addiu $15 $0 0x0f0f
sll $15 $15 0x10
jr $0
or v0 $14 $15

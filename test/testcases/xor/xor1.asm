addiu $14 $0 0xf003
sll $14 $14 0x10
addiu $15 $0 0x0f50f
sll $15 $15 0x10
jr $0
xor v0 $14 $15

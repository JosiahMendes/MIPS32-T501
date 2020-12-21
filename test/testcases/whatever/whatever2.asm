lui $8 0x0004
lui $9 0x0000
addiu $19 $0 0xffff
lui $12 0xabcd
mult $19 $12
div $12 $19
ori $8 $8 0xabcd
ori $9 $9 0x2345
addu $10 $8 $0
divu $12 $19
subu $10 $10 $9
bgez $10 0x2
sll $0 $0 0x0
beq $0 $0 0x3
sll $0 $0 0x0
beq $0 $0 0xfffa
addiu $11 $11 0x1
addu $10 $10 $9
addu $2 $2 $11
sll $2 $2 0x10
jr $0
addu $2 $10 $2

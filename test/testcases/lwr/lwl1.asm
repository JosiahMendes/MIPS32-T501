lui $8, 0xbfc0
addiu $9 $9 0xabcd
sw $9, 0x20($8)
lwl $2, 0x20($8)
jr $0
sll $0 $0 0x0
.globl main 
.text

main: lui $8, 0xbcf0
addiu $9 $9 0xbcd
sw $9, 0x20($8)
lwl $2, 0x20($8)

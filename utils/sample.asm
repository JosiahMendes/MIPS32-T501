addiu $0 $2 25		
lw $3 9($2)		
addu $4 $2 $3	
subu $5 $2 $3	
sw $5 10($5)	#testhkhkhk
j BFC00000
data:
BFC00025 : 0a 
BFC00032 : 79
BFC00034 : 11
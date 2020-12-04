addiu $0 $2 25		
lw $3 26($2)		
addu $4 $2 $3	
subu $5 $2 $3	
sw $5 10($5)	#testhkhkhk
j 0xBFC00002
j 3217031170
data:
0xBFC00025 : 0xfff 
0xBFC00032 : 79
0xBFC00034 : 11
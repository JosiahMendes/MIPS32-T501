lui v0 0x7FFF
lui v1 0x7FFF
addiu v2 r0 0x0001
addiu v3 r0 0x1
add v0 v0 v2
add v1 v1 v3
multu v0 v1
jr r0
mfhi v0
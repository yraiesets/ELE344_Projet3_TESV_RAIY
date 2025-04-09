main:
	addi	$3, $0, 1
	addi	$7, $3, 11
	and	$2, $3, $7
	sw	$7, 8192($2)
	add	$5, $2, $3
	lw	$2, 8191($5)
To:
	beq	$2, $3, next
	addi	$0, $0, 0
	addi	$0, $0, 0
	addi	$3, $3, 11
	j	To
	addi	$0, $0, 0
	
next:
	slt 	$4, $5, $7
	beq	$4, $2, around
	addi	$0, $0, 0
	addi	$0, $0, 0
	sw   	$5, 8191($4)
	
around:
	slt	$4, $7, $2
	or	$4, $3, $2
	addi	$7, $3, -1
	sub	$7, $7, $2
	lw	$2, 8180($3)
	sw	$7, 8180($4)
	add  	$3, $0, $5       
	beq  	$5, $3, main
	addi	$0, $0, 0
	addi	$0, $0, 0

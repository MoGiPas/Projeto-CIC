HEALTHBAR:	# Receives the current health in a0 and return the correct image adress in a0.
	li t0, 20
	bge a0, t0, RANGE_20_40
	li t0, 10
	bge a0, t0, RANGE_10_19
	li t0, 5
	bge a0, t0, RANGE_5_9
	li t0, 3
	bge a0, t0, RANGE_3_4
	li t0, 0
	beq a0, t0, LIFE_0
	li t0, 1
	beq a0, t0, LIFE_1
	j LIFE_2
   RANGE_3_4:
   	li t0, 3
   	beq a0, t0, LIFE_3
   	j LIFE_4
   	
   LIFE_0:
	la a0, life_0
	j HEALTHBAR_END
   LIFE_1:
	la a0, life_1
	j HEALTHBAR_END
   LIFE_2:
	la a0, life_2
	j HEALTHBAR_END
   LIFE_3:
	la a0, life_3
	j HEALTHBAR_END 
   HEALTHBAR_END:
   	ret
   	
LEVEL_NUM:	# Receives the current level number in a0 and return the correct image adress in a0.
	li t0, 1
	beq a0, t0, LVL_1
	li t0, 2
	beq a0, t0, LVL_2	
   LVL_1:
   	la a0 lvl1
   	j LEVEL_NUM_END
   LVL_2:
   	la a0 lvl2
	j LEVEL_NUM_END
   LVL_3:
   	la a0 lvl3
   	j LEVEL_NUM_END
   LVL_4:
   	la a0 lvl4
   	j LEVEL_NUM_END
   LVL_5:
   	la a0 lvl5
   	j LEVEL_NUM_END    	
   LEVEL_NUM_END:
   	ret

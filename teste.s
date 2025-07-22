# Universidade de Brasília
# Introdução aos Sistemas Computacionais – 2021.1
# Projeto final
.data
	
# Map data
	.include "maps/level1.data"
# Interface
	.include "img/title.data"
	.include "img/game_over.data"
# Map tiles
	.include "img/planks.data"
	.include "img/brick.data"
	.include "img/wall.data"
	.include "img/cobblestone.data"
	.include "img/lava.data"
	.include "maps/levelMutable.data"
# Steve
	.include "img/steve_walk1.data"
	.include "img/steve_walk2.data"
	.include "img/steve_walk3.data"
	.include "img/steve_walk4.data"
	.include "img/life_0.data"
	.include "img/life_1.data"
	.include "img/life_2.data"
	.include "img/life_3.data"
# Creeper
	.include "img/creeper1.data"
	.include "img/creeper2.data"
	.include "img/creeper3.data"
	.include "img/creeper4.data"
# Zombie
	.include "img/zombie1.data"
	.include "img/zombie2.data"
	.include "img/zombie3.data"
	.include "img/zombie4.data"
# Skeleton
	.include "img/skeleton1.data"
	.include "img/skeleton2.data"
	.include "img/skeleton3.data"
	.include "img/skeleton4.data"
# Items
	.include "img/bomb.data"
# Game Over
	.include "img/ending.data"
# Songs
	.include "songs/songs.data"
PLAYER_POS:  .byte 1, 1 # Two bytes representing the current position of the player (X, Y)
PLAYER_LIFE: .byte 40   # How many "steps" the player has left in the level
CURR_LEVEL:  .byte 1    # Which level the player is currenly on
IS_BOMB_ACTIVE: .word 0 	# 0 = inactive, 1 = active
BOMB_POS: .word 0 		# Bomb's position
BOMB_TIMER: .word 0 		# Time in which the bomb was placed
 
.text
# s7 = unix time (in ms) of last animation frame change
# s8 = current animation frame
	li s6 0
	li s7 0 	# set current time to 0
	li s8 1	    # set animation frame to 1

TITLE_SCREEN:
    # Title screen image
	la a0, title
	call PRINT
	
TITLE_SCREEN_SONG.LOOP:
	# Music info (MINECRAFT song)
	li s7,0			# notes count = 0
	la s0,LENGTH_MINECRAFT	
	lw s1,0(s0)		# number of notes
	la s0,NOTES_MINECRAFT	# notes adress
	li a3,100		# volume

    # Waits for user to press space so that the game can begin
    TITLE_SCREEN.AWAIT:
    	# Play note
	beq s7,s1,TITLE_SCREEN_SONG.LOOP
	lw a0,0(s0)		# read note
	lw a1,4(s0)		# note length
	li a2,88 		# instrument
	li a7,31		# ecall = 31
	ecall			# play sound
	mv a0,a1		# move length of note to a0(a0 ms of pause)
	li a7,32		# ecall = 32
	ecall			# stop for a0 ms
	addi s0,s0,8		# next note
	addi s7,s7,1		# add 1 to notes count
	
        li t1 0xFF200000
        lw t0 0(t1)
        andi t0 t0 1
        beqz t0 TITLE_SCREEN.AWAIT 	# Nothing pressed -> Loop back
        lw t2 4(t1)  			
        li t0 ' '
        bne t2 t0 TITLE_SCREEN.AWAIT	# No Space pressed -> Loop back
START_GAME:
    j SETUP_LEVEL.1
  		
# SETUP_LEVEL.X
# - Loads the level's map information into respective registers
# - Initializes the position of players, keys
# - Initializes player HP
SETUP_LEVEL.1:
	la s9 level1

    la t1 PLAYER_POS
    li t0 0x040a        # Initial Player Position (0x(yx))
    sh t0 0(t1)
	la t1 PLAYER_LIFE
	li t0 3	        # Initial Player HP
	sb t0 0(t1)
	la t1 CURR_LEVEL
	li t0 1		        # Sets the current level
	sb t0 0(t1)

	j SETUP_MAP

# Resets the map to its original form
SETUP_MAP:
	la s5 levelMutable
	li t0 0
	li t1 240
SETUP_MAP.LOOP:
	lb t6 0(s9)	
	sb t6 0(s5)	
	addi s5 s5 1
	addi s9 s9 1	
	addi t0 t0 1 	
	blt t0 t1 SETUP_MAP.LOOP
   	li t2 -1
   	mul t1 t1 t2
	add s5 s5 t1
	

GAME_LOOP:
    # Switches frame
	li t0 0xFF200604
	sw s6 0(t0)

    # If player has no lives left -> GAME_OVER
	lb t0, PLAYER_LIFE
	blez t0, GAME_OVER

    # Flips frame
	xori s6 s6 1

    # Checks for input and processes it if needed
	call GET_INPUT
	
	# Verifies bomb logic
	la t0 IS_BOMB_ACTIVE
	lw t1 0(t0)
	beqz t1 .SKIP_BOMB_LOGIC
	
	# Checks timer
	li a7 30
	ecall
	la t2 BOMB_TIMER
	lw t3 0(t2)
	sub t4 a0 t3
	li t5 2000	# 2 seconds until bomb explodes
	blt t4 t5 .SKIP_BOMB_LOGIC
	
	# Time's up! Explode the bomb and deactivate it
	call EXPLODE_BOMB
	sw zero 0(t0) # IS_BOMB_ACTIVE = 0
	
	.SKIP_BOMB_LOGIC:
	

# Updates the current animation frame (s8)
ANIMATION.UPDATE:
    # syscall that saves unix time in milisseconds in a0
	li a7 30 
	ecall
	li t0 250		# Intended delay between frames (in milisseconds)
	sub t1 a0 s7    # Milisseconds passed since last frame change
	# If time passed is less than the delay, do not change animation frame
	bltu t1 t0 ANIMATION.UPDATE.END
ANIMATION.UPDATE.INCREMENT:
	mv s7 a0		# Set last frame change time
	addi s8 s8 1    # Increment animation frame
	li t2 4
	ble s8 t2 ANIMATION.UPDATE.END	# if frame number <= 4, continue
	li s8 1		                    # else, set frame back to 1 
ANIMATION.UPDATE.END:


PRINT_UI:
	lb a0 PLAYER_LIFE
	call HEALTHBAR	# returns in a0 the address of the correct health bar image
	mv a1 zero
	mv a2 zero
	mv a3 s6
	call PRINT
	
	lb a0 CURR_LEVEL
	#call LEVEL_NUM	# returns in a0 the address of the current level indicator image
	li a1 288
	mv a2 zero
	mv a3 s6
	call PRINT

# Loops through all the tiles, printing each one
PRINT_TILE.SETUP:
	mv s0 zero	# Current x
	mv s1 zero	# Current y
	li s2 16	# width (in tiles)
	li s3 15	# height (in tiles)
	mv s4 s5	# Current position in map
PRINT_TILE:
	lb t0 0(s4)
	addi s4 s4 1
	# Put the correct tile address on a0
    PRINT_TILE.GET_SPRITE:
        li t1 0
        beq t0 t1 SPRITE.PLANK
        	li t1 1
        beq t0 t1 SPRITE.BRICK
        	li t1 2
        beq t0 t1 SPRITE.ENEMY
		li t1 4
        beq t0 t1 SPRITE.LAVA
		li t1 5
        beq t0 t1 SPRITE.ZOMBIE
		li t1 7
        beq t0 t1 SPRITE.SKELETON
		li t1 8
        SPRITE.PLANK:
            la a0 planks
            j PRINT_TILE.GET_SPRITE.END
        SPRITE.BRICK:
            la a0 brick
            j PRINT_TILE.GET_SPRITE.END
        SPRITE.ENEMY:
            # Sets the correct enemy animation frame according to s8 (1 - 4)
            li t0 1
            beq t0 s8 SPRITE.ENEMY.1
            li t0 2
            beq t0 s8 SPRITE.ENEMY.2
            li t0 3
            beq t0 s8 SPRITE.ENEMY.3
            j SPRITE.ENEMY.4
            
            SPRITE.ENEMY.1:
                la a0 creeper1
                j PRINT_TILE.GET_SPRITE.END
            SPRITE.ENEMY.2:
                la a0 creeper2
                j PRINT_TILE.GET_SPRITE.END
            SPRITE.ENEMY.3:
                la a0 creeper3
                j PRINT_TILE.GET_SPRITE.END
            SPRITE.ENEMY.4:
                la a0 creeper4
                j PRINT_TILE.GET_SPRITE.END
		SPRITE.LAVA:
            la a0 lava
            j PRINT_TILE.GET_SPRITE.END
            
		SPRITE.ZOMBIE:
            # Sets the correct enemy animation frame according to s8 (1 - 4)
            li t0 1
            beq t0 s8 SPRITE.ZOMBIE.1
            li t0 2
            beq t0 s8 SPRITE.ZOMBIE.2
            li t0 3
            beq t0 s8 SPRITE.ZOMBIE.3
            j SPRITE.ZOMBIE.4
            SPRITE.ZOMBIE.1:
                la a0 zombie1
                j PRINT_TILE.GET_SPRITE.END
            SPRITE.ZOMBIE.2:
                la a0 zombie2
                j PRINT_TILE.GET_SPRITE.END
            SPRITE.ZOMBIE.3:
                la a0 zombie3
                j PRINT_TILE.GET_SPRITE.END
            SPRITE.ZOMBIE.4:
                la a0 zombie4
                j PRINT_TILE.GET_SPRITE.END
                
		SPRITE.SKELETON:
            # Sets the correct enemy animation frame according to s8 (1 - 4)
            li t0 1
            beq t0 s8 SPRITE.SKELETON.1
            li t0 2
            beq t0 s8 SPRITE.SKELETON.2
            li t0 3
            beq t0 s8 SPRITE.SKELETON.3
            j SPRITE.SKELETON.4
            SPRITE.SKELETON.1:
                la a0 skeleton1
                j PRINT_TILE.GET_SPRITE.END
            SPRITE.SKELETON.2:
                la a0 skeleton2
                j PRINT_TILE.GET_SPRITE.END
            SPRITE.SKELETON.3:
                la a0 skeleton3
                j PRINT_TILE.GET_SPRITE.END
            SPRITE.SKELETON.4:
                la a0 skeleton4
                j PRINT_TILE.GET_SPRITE.END
        
    PRINT_TILE.GET_SPRITE.END:

    # Position of the (x, y) tile is (16 * x + 32, 16 * y)
    # The offset to the x position is due to the interface
    PRINT_TILE.PRINT:
        slli a1 s0 4
        addi a1 a1 32
        slli a2 s1 4
        mv a3 s6
        call PRINT

    # Loop back to the next column
	addi s0 s0 1
	blt s0 s2 PRINT_TILE

    # Loop back to the next line
	addi s1 s1 1
	mv s0 zero
	blt s1 s3 PRINT_TILE

PRINT_PLAYER:
    # Put the correct sprite for the player on a0
    PRINT_PLAYER.GET_SPRITE:
        li t1, 1
        beq t1, s8, SPRITE.WALK.1
        li t1, 2
        beq t1, s8, SPRITE.WALK.2
        li t1, 3
        beq t1, s8, SPRITE.WALK.3
        li t1, 4
        beq t1, s8, SPRITE.WALK.4
        SPRITE.WALK.1:
            la a0, steve_walk1
            j PRINT_PLAYER.GET_SPRITE.END
        SPRITE.WALK.2:
            la a0, steve_walk2
            j PRINT_PLAYER.GET_SPRITE.END
        SPRITE.WALK.3:
            la a0, steve_walk3
            j PRINT_PLAYER.GET_SPRITE.END
        SPRITE.WALK.4:
            la a0, steve_walk4
            j PRINT_PLAYER.GET_SPRITE.END
				
PRINT_PLAYER.GET_SPRITE.END:

    la t3 PLAYER_POS
    lb a1 0(t3)
    slli a1 a1 4
    addi a1 a1 32
    lb a2 1(t3)
    slli a2 a2 4
    mv a3 s6
    call PRINT
DRAW_BOMB:
	la t0 IS_BOMB_ACTIVE
	lw t1 0(t0)
	beqz t1 DRAW_BOMB_END
	
	#Loads bomb position
	la t2 BOMB_POS
	lw t3 0(t2) 		# t3 = 0x00YYXX
	andi t4 t3 0xFF 	# t4 = X
	srli t5 t3 8 		# t5 = Y
	
	# Screen coordinates
	slli a1 t4 4 		# x * 16
	addi a1 a1 32 		# interface offset
	slli a2 t5 4 		# y * 16
	
	# PRINT arguments
	la a0 bomb
	mv a3 s6 			# Current frame
	call PRINT
	
	DRAW_BOMB_END:
	ret


# Function which prints an image according to the following arguments
# a0 = &image
# a1 = x
# a2 = y
# a3 = frame (0 or 1)
PRINT:
    # Frame 0: 0xFF00 0000
    # Frame 1: 0xFF10 0000
	# t0 = &frame
	li t0 0xFF0
	add t0 t0 a3
	slli t0 t0 20

	# t0 += x + y * 320
	add t0 t0 a1
	li t1 320
	mul t1 t1 a2
	add t0 t0 t1
	
	# t1 = &image + 8 <- two first words are dimensions of image
	addi t1 a0 8
	
	mv t2 zero     # t2 = line index
	mv t3 zero     # t3 = col index

	lw t4 0(a0)    # t4 = image width
	lw t5 4(a0)    # t5 = image height
	
    PRINT.LINE:
        # Prints 4 pixels
        # *t0 = *t1
        lw t6 0(t1)
        sw t6 0(t0)
        
        # move ahead
        addi t0 t0 4
        addi t1 t1 4
        addi t3 t3 4

        # If not at the end of line loop back
        blt t3 t4 PRINT.LINE
        
        # Else move down one line
        addi t0 t0 320
        sub t0 t0 t4
        mv t3 zero
        addi t2 t2 1
        
        # If there are lines left loop back
        bgt t5 t2 PRINT.LINE
	ret

GET_INPUT:
	li t1 0xFF200000	        # KDMMIO Adress
	lw t0 0(t1)		            # Keyboard control bit
	andi t0 t0 1		        # LSB
	bne t0 zero PROCESS_INPUT	# If something has been pressed
    ret

PROCESS_INPUT:
	# t2 = letter pressed
	lw t2 4(t1)

	# Load player's current position
	la t3 PLAYER_POS
	lb t4 0(t3)
	lb t5 1(t3)

	li t0 'w'
	beq t2 t0 MOVE.UP
	li t0 'a'
	beq t2 t0 MOVE.LEFT
	li t0 's'
	beq t2 t0 MOVE.DOWN
	li t0 'd'
	beq t2 t0 MOVE.RIGHT
	li t0 '1'
	beq t2 t0 SETUP_LEVEL.1
	#li t0 '2'
	#beq t2 t0 SETUP_LEVEL.2
	li t0 'b'
	beq t2 t0 PLACE_BOMB
	li t0 'r'
	beq t2 t0 RESPAWN
	#li t0 'z'
	#beq t2 t0 CRAFT
	ret
	
	PLACE_BOMB:
	la t0 IS_BOMB_ACTIVE
	lw t1 0(t0)
	bnez t1 PLACE_BOMB_END
	
	#Activate bomb
	li t1 1
	sw t1 0(t0)
	
	# Current player position will be the bomb's position
	la t2 PLAYER_POS
	lb t3 0(t2) 	# x
	lb t4 1(t2) 	# y
	slli t4 t4 8 	# pos = y << 8
	or t5 t4 t3 	# pos = pos | x (0x00YYXX) format
	la t6 BOMB_POS
	sw t5 0(t6)
	
	# Updates bomb timer
	li a7 30
	ecall
	la t6 BOMB_TIMER
	sw a0 0(t6)
	
	PLACE_BOMB_END:
    
    ret

	# Sets player's desired position
    MOVE.UP:
        addi t5 t5 -1	# Player Y -= 1
        addi t1 t5 -1	# t1 = Player Y - 2
        mv t0 t4	    # t0 = Player X
        j PROCESS
    MOVE.LEFT:
        addi t4 t4 -1	# Player X -= 1
        addi t0 t4 -1	# t0 = Player X - 2
        mv t1 t5	    # t1 = Player Y
        j PROCESS
    MOVE.DOWN:
        addi t5 t5  1	# Player Y += 1
    	addi t1 t5  1	# t1 = Player Y + 2
    	mv t0 t4	    # t0 = Player X
        j PROCESS
    MOVE.RIGHT:
        addi t4 t4  1	# Player X += 1
        addi t0 t4  1	# t0 = Player X + 2
        mv t1 t5	    # t1 = Player Y
        j PROCESS

# Processes the player's desired position
PROCESS:

	# If destination is the table position and any key was not collected, treat it as a wall.	
	mv t6 t5
	slli t6 t6 8
	add t6 t6 t4
	j CHECK_TILE		
		PRECHECK_KEYS:
			li t6 0x0101
			bne s10 t6 PROCESS.WALL
	
CHECK_TILE:
	# t6 = Address of tile in desired position (16 * y + x + &map)
	li t6 16
	mul t6 t6 t5
	add t6 t6 t4
	add t6 t6 s5
	
	# Check what tile is in desired position
	lb s10 0(t6)
	li s11 0
	beq s10 s11 PROCESS.PATH
	li s11 1
	beq s10 s11 PROCESS.WALL
	li s11 2
	beq s10 s11 PROCESS.BLOCK
	li s11 3
	beq s10 s11 PROCESS.ENEMY
	li s11 4
	beq s10 s11 PROCESS.LAVA

PROCESS.PATH:
    # Save new position
	sb t4 0(t3)
	sb t5 1(t3)

    SOUND.MOVEMENT:
        li a0 10	# note
	li a1 700	# duration
	li a2 5		# instrument
	li a3 60	# volume
	li a7 31	# ecall
	ecall							
		NEXT_LEVEL:
			SOUND.NEXT_LEVEL:
			li a0 50	# note
			li a1 600	# duration
			li a2 10	# instrument
			li a3 100	# volume
			li a7 31	# ecall
			ecall
			la t2 CURR_LEVEL
			lb t1 0(t2)
			addi t1 t1 1
			sb t1 0(t2)
			j RESPAWN

PROCESS.WALL:
    SOUND.WALL:
	li a0 15	# note
	li a1 500	# duration
	li a2 5		# instrument
	li a3 100	# volume
	li a7 31	# ecall
	ecall
    j PROCESS.END

PROCESS.ENEMY:
   	# t2 = Which tile is behind the enemy
   	li t2 16 
    mul t2 t2 t1
	add t2 t2 t0
    add t2 t2 s5
    	
    # If it's not a path, kill enemy
    lb s10 0(t2)
    bne s10 zero PROCESS.ENEMY.KILL
    	
    PROCESS.ENEMY.PUSH:
    	li t0 3
    	sb t0 0(t2)
    	sb zero 0(t6)
        SOUND.ENEMY.PUSH:
            li a0 20	# note
	    li a1 800	# duration
	    li a2 10	# instrument
	    li a3 60	# volume
	    li a7 31	# ecall
	    ecall
    	
    	
    PROCESS.ENEMY.KILL:
        sb zero 0(t6)
        SOUND.ENEMY.KILL:
            li a0 20	# note
	    li a1 700	# duration
	    li a2 127	# instrument
	    li a3 80	# volume
	    li a7 31	# ecall
		ecall
        
    
PROCESS.BLOCK:     	 
    SOUND.BLOCK:
        li a0 15	# note
	li a1 200	# duration
	li a2 50	# instrument
	li a3 127	# volume
	li a7 31	# ecall
	ecall
	
	# t2 = Which tile is behind the block
	li t2 16
    mul t2 t2 t1
	add t2 t2 t0
    add t2 t2 s5
	
	# if it's lava, block can move
    lb s10 0(t2)
    li t0 4
    beq s10 t0 BLOCK_CAN_MOVE
	
	# If it's not a path, don't move
    bne s10 zero DECREMENT_HP
    
	BLOCK_CAN_MOVE:
		BLOCK.GET_MAP:
		# Saves on a9 the address of the immutable map of the current level
			lb s10, CURR_LEVEL
			li t0, 1
			beq t0, s10, LOAD_LEVEL.1
			#li t0, 2
			#beq t0, s10, LOAD_LEVEL.2
			LOAD_LEVEL.1:
				la s9 level1
				j BLOCK.GET_TERRAIN
			#LOAD_LEVEL.2:
				#la s9 level2
				#j BLOCK.GET_TERRAIN
			
		
		BLOCK.GET_TERRAIN:
		# Get from immutable map what terrain is under the block
			li t0 16
			mul t0 t0 t5
			add t0 t0 t4
			add t0 t0 s9	# t0 = address of tile under the block   	
			lb t0 0(t0)		# t0 = tile under the block
		
		# Check if the block is over lava
		li s10 4
     	bne t0 s10 SAVE_PATH	# if block is not over lava, save regular path
      	sb s10 0(t6)			# else, save lava (4) at the position 
		j SAVE_BLOCK
		
		# Move block
		SAVE_PATH:
			sb zero 0(t6)
		
		SAVE_BLOCK:
			li t0 2
			sb t0 0(t2)

    
	
PROCESS.LAVA:
	SOUND.LAVA:
		li a0 79	# note
		li a1 500	# duration
		li a2 127	# instrument
		li a3 60	# volume
		li a7 31	# ecall
		ecall
	
	# Save position
	sb t4 0(t3)
	sb t5 1(t3)
	
DECREMENT_HP:
   	# Calculate the amount of damage (1 if not on fire; 2 if on fire)
	li t0, -1
	sub t0, t0, t4
	
	# Apply damage to player health
   	la t4, PLAYER_LIFE
   	lb t5, 0(t4)
   	add t5, t5, t0
   	sb t5, 0(t4)
	j PROCESS.END

PROCESS.END:
	ret
	
EXPLODE_BOMB:	
	addi sp sp -4
	sw ra 0(sp)
	# Get bomb's position
	la t0 BOMB_POS
	lw t1 0(t0) 		# t1  = 0x00YYXX
	andi t2 t1 0xFF 	# t2 = X
	srli t3 t1 8 		# t3 = Y
	
	# Explosion sound
	li a0, 64
	li a1, 300
	li a2, 122
	li a3, 127
	li a7, 31
	ecall
	
	# Tests 5 positions
	# Center
	mv t4 t2 
	mv t5 t3
	call EXPLODE_TILE	
	# Up
	mv t4 t2 
	addi t5 t3 -1 
	call EXPLODE_TILE
	# Down
	mv t4 t2 
	addi t5 t3 1 
	call EXPLODE_TILE
	# Left
	addi t4 t2 -1 
	mv t5 t3 
	call EXPLODE_TILE
	# Right
	addi t4 t2 1 
	mv t5 t3 
	call EXPLODE_TILE
	
	lw ra 0(sp)
	addi sp sp 4
	ret

EXPLODE_TILE:
	# Arguments: t4 = x, t5 = y
	# Checks if coordinate is inside the map
	li t0 0
	blt t4 t0 EXPLODE_TILE_END
	li t0 16 
	bge t4 t0 EXPLODE_TILE_END
	li t0 0 
	blt t5 t0 EXPLODE_TILE_END
	li t0 15 
	bge t5 t0 EXPLODE_TILE_END
	
	li t0 16
	mul t1 t5 t0
	add t1 t1 t4
	add t6 s5 t1 	# t6 = final tile address
	
	lb t2 0(t6) 	# t2 = current tile type
	
	# Do not explode walls(type 1)
	li t3 1
	beq t2 t3 EXPLODE_TILE_END
	
	# If the tile is a brick(Type 1)
	li t3 1
	bne t2 t3 EXPLODE_TILE_DAMAGE_CHECK
	
	# Turn into a floor
	li t4 0
	sb t4 0(t6)
	
EXPLODE_TILE_DAMAGE_CHECK:

EXPLODE_TILE_END:
	ret
GAME_OVER:
	la a0, game_over
	mv a1, zero
	mv a2, zero
	mv a3, s6
	call PRINT

GAME_OVER_SONG.LOOP:
	# Music info (SWEDEN song)
	li s7,0			# notes count = 0
	la s0,LENGTH_SWEDEN	
	lw s1,0(s0)		# number of notes
	la s0,NOTES_SWEDEN	# notes adress
	li a3,100		# volume

    # Waits for user to press either Esc or Space
    GAME_OVER.AWAIT:   
	# Play note
		beq s7,s1,GAME_OVER_SONG.LOOP
		lw a0,0(s0)		# read note
		lw a1,4(s0)		# note length
		li a2,88 		# instrument
		li a7,31		# ecall = 31
		ecall			# play sound
		mv a0,a1		# move length of note to a0(a0 ms of pause)
		li a7,32		# ecall = 32
		ecall			# stop for a0 ms
		addi s0,s0,8		# next note
		addi s7,s7,1		# add 1 to notes count
	
        li t1 0xFF200000
        lw t0 0(t1)	
        andi t0 t0 1
        beqz t0 GAME_OVER.AWAIT
        lw t2 4(t1)  			
        li t0 ' '
        beq t2 t0 RESPAWN
        li t0 27
        beq t2 t0 QUIT
        j GAME_OVER.AWAIT
	
RESPAWN:
   	lb t0, CURR_LEVEL
   	li t1, 1
   	beq t0, t1, SETUP_LEVEL.1
   	li t1, 2
   	beq t0, t1, ENDING

ENDING:
	la a0 ending
	mv a1 zero
	mv a2 zero
	mv a3 s6
	call PRINT
	
	# Switches frame
	li t0 0xFF200604
	sw s6 0(t0)
	
	ENDING.AWAIT:   
        li t1 0xFF200000
        lw t0 0(t1)	
        andi t0 t0 1
        beqz t0 ENDING.AWAIT
        lw t2 4(t1)  			
        li t0 ' '
        beq t2 t0 SETUP_LEVEL.1
        li t0 27
        beq t2 t0 QUIT
        j ENDING.AWAIT
QUIT:
   	li a7, 10
   	ecall
   	

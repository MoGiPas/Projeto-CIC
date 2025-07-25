########################## PROJETO BOMBERMAN #################################
# Universidade de Brasilia - Introducao aos Sistemas Computacionais - Turma 01
# Prof Marcus Vinicius Lamar
# Felipe Machado - 251000107
# Moises Gibson - 251025966
# Marcos Lopes - 251001140
##########################################################################
.data

# Maps
	.include "img/telaInicio.data"
	.include "maps/level1.data"
	.include "maps/level2.data"
	.include "maps/level3.data"
	.include "maps/levelMutable.data"

# Tiles
	.include "img/exterior.data"
	.include "img/floor.data" 				# 0 = chao
	.include "img/wall.data"          		# 1 = parede
	.include "img/brick.data"         		# 2 = bloco quebravel
	.include "img/goal.data"				# 4 = Objetivo
	.include "img/player.data"        		# jogador
	.include "img/bannerPreto.data"
	.include "img/specialBrick.data"

# Bomb
	.include "img/bomb.data"
	.include "img/explosionMiddle.data"
# Enemies
	.include "img/goomba.data"
	.include "img/koopa1.data"
	.include "img/koopa2.data"
# Mario
	.include "img/mario_idle.data"
	.include "img/mario_walk1.data"
	.include "img/mario_walk2.data"
	.include "img/mario_walk3.data"
	.include "img/mario_walk4.data"
# Powers
	.include "img/flower.data" 			
	.include "img/mushroom.data"		# 3 = Power Up increases life
# Game Over OU Vitoria
	.include "img/game_over.data"
	.include "img/telaVitoria.data"
# Songs
	.include "songs/musica-0.data"
	.include "songs/musica-1.data"
	.include "songs/musica-2.data"
	.include "songs/musica-3.data"
# HUD
	.include "img/bannerMario.data"
	.include "img/life.data"
	.include "img/FASE1.data"
	.include "img/FASE2.data"
	.include "img/FASE3.data"

ENEMY_POS: .word 0
ENEMY_LIFE: .byte 0

GOOMBA_POS: .word 0
GOOMBA_LIFE: .byte 0

KOOPA_POS: .word 0
KOOPA_LIFE: .byte 0

GOOMBA_TIMER: .word 0
KOOPA_TIMER: .word 0

GOOMBA_DIRECTION: .byte 0 # 0 = left 1 = right
KOOPA_DIRECTION: .byte 0 # 0 = down 1 = up

PLAYER_POS: .byte 1, 1
PLAYER_LIFE: .byte 3
BOMB_RADIUS: .byte 1
CURR_LEVEL: .byte 1
IS_MOVING: .byte 0
LAST_MOVE_TIME: .word 0
IS_BOMB_ACTIVE: .word 0 		# 0 = inactive / 1 = active
BOMB_POS: .word 0 				# Bomb's Position
BOMB_TIMER: .word 0 			# Bomb's timer
IS_EXPLOSION_ACTIVE: .word 0 	# 0 = not active / 1  = active
EXPLOSION_TIMER: .word 0 		# Time in which the explosion started

# Fire coordinates
# Space for 1 center + 4 directions * 4 of radius =  17 tiles * 2 bytes/coord = 34 bytes
EXPLOSION_DATA: .space 34
EXPLOSION_SIZE: .word 0 	# How many fire coordinates are in the array



.text 
# s6 = current frame (0 or 1)
# s7 = last animation time
# s8 = animation frame(1 to 4)
# s10 = music note index
	li s6 0
	li s7 0
	li s8 1
	li s10 0
	la s11,MELODIA_0
	
	TITLE_SCREEN:
    # Title screen image
	la a0, telaInicio
	call PRINT

	TITLE_SCREEN_SONG.LOOP:
	# Music info (MINECRAFT song)
	li s7,0			# notes count = 0
	la s0,TAMANHO_0	
	lw s1,0(s0)		# number of notes
	la s0,MELODIA_0	# notes adress
	li a3,100			# volume

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
	j SETUP_LEVEL_1
# SETUP_LEVEL.X
# - Loads the level's map information
# - Initializes the position of players, keys
# - Initializes player HP
SETUP_LEVEL_1:
	la s9 level1
	
	la t1 PLAYER_POS
	li t0,0x0401	 # Initial Player Position(0x(yx))
	sh t0, 0(t1)

	la t1 PLAYER_LIFE
	li t0 3	 		# Initial Player HP
	sb t0 0(t1)

	la t1 GOOMBA_POS
	li t0 0xb01
	sh t0 0(t1)

	la t1 GOOMBA_LIFE
	li t0 1 		# Initial enemy hp(in this case, goomba)
	sb t0 0(t1)

	la t1 KOOPA_LIFE	
	li t0 1
	sb t0 0(t1)

	la t1 KOOPA_POS
	li t0 0xa01
	sh t0 0(t1)

	la t1 CURR_LEVEL
	li t0 1	 		# Sets the current level'
	sb t0 0(t1)

	j SETUP_MAP

SETUP_LEVEL_2:
	la s9 level2

	la t1 PLAYER_POS
	li t0, 0x101
	sh t0, 0(t1)

	la t1 PLAYER_LIFE
	li t0 3
	sb t0 0(t1)

	la t1 GOOMBA_POS
	li t0 0x909
	sh t0 0(t1)

	la t1 GOOMBA_LIFE
	li t0 1 		# Initial enemy hp(in this case, goomba)
	sb t0 0(t1)

	la t1 KOOPA_LIFE	
	li t0 1
	sb t0 0(t1)

	la t1 KOOPA_POS
	li t0 0xa03
	sh t0 0(t1)

	la t1 CURR_LEVEL
	li t0 2
	sb t0 0(t1)
	
	j SETUP_MAP

SETUP_LEVEL_3:
	la s9 level3

	la t1 PLAYER_POS
	li t0, 0x101
	sh t0, 0(t1)

	la t1 PLAYER_LIFE
	li t0 3
	sb t0 0(t1)

	la t1 GOOMBA_POS
	li t0 0x309
	sh t0 0(t1)

	la t1 GOOMBA_LIFE
	li t0 1 		# Initial enemy hp(in this case, goomba)
	sb t0 0(t1)

	la t1 KOOPA_LIFE	
	li t0 1
	sb t0 0(t1)

	la t1 KOOPA_POS
	li t0 0xa01
	sh t0 0(t1)

	la t1 CURR_LEVEL
	li t0 3
	sb t0 0(t1)
	
	j SETUP_MAP

# Resets the map to its original form
SETUP_MAP:
	li t2 1
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
	# Switch frame
	li t0 0xFF200604
	sw s6 0(t0)
	
	 # Flip frame
   	xori s6 s6 1

    # Music (one note per loop)
    	bge s10 s0 GAME_LOOP.MUSIC_DONE
    	lw a0 0(s11)	# note
    	lw a1 4(s11)     # length
    	li a2 1              	# instrument
    	li a3 40             # volume
    	li a7 31
    	ecall

		addi s11 s11 8       # next note address
		addi s10 s10 1       # increment index

GAME_LOOP.MUSIC_DONE:

    # Process input
    call GET_INPUT

	# Show enemy
	call DRAW_ENEMY
	DRAW_ENEMY.END:
	
	# Check if bomb is active
	la t0, IS_BOMB_ACTIVE
	lw t1, 0(t0)
	beqz t1 GAME_LOOP.CONTINUE  	# If the bomb is not active, jump
	
	# Check if time has passed
	li a7, 30
	ecall                    				# a0 = current time (ms)
	la t2, BOMB_TIMER
	lw t3, 0(t2)              				# Register which time the bomb was placed
	sub t4, a0, t3
	li t5, 2000               				# 2000ms = 2 segundos
	blt t4, t5, GAME_LOOP.CONTINUE 			# Not enough time -> jump

	
	# EXPLODE BOMB!
	call EXPLODE_BOMB
	EXPLODE.BOMB.END:
	
	# Deactivate bomb
	la t0 IS_BOMB_ACTIVE
	li t6 0
	sw t6 0(t0)  	# IS_BOMB_ACTIVE <- 0
GAME_LOOP.CONTINUE:
	
# Update the current animation frame (s8)
ANIMATION.UPDATE:
	# syscall that saves unix time in milisseconds in a0
	li a7 30
	ecall
	li t0 250		 # Delay between frames (in milisseconds)
	sub t1 a0 s7	#  Milisseconds passed since last frame change
	# If time passed is less than the delay, keep animation frame
	bltu t1 t0 ANIMATION.UPDATE.END
	
	# Check if the character should stop moving
	li a7, 30
	ecall
	la t0, LAST_MOVE_TIME
	lw t1, 0(t0)
	sub t2, a0, t1
	li t3, 500
	blt t2, t3, PRINT_UI     # Not enough time to stop moving just yet
	la t4, IS_MOVING
	sb zero, 0(t4)           # Stop moving
ANIMATION.UPDATE.INCREMENT:
	mv s7 a0		# Set the last frame change time
	addi s8 s8 1	# Increment animation frame
	li t2, 4
	ble s8 t2 ANIMATION.UPDATE.END	# If frame num <= 4, continue
	li s8 1
ANIMATION.UPDATE.END:

PRINT_UI:
	la a0 bannerMario
	li a1 0 		# x0 
	li a2 0 		# y0
	mv a3 s6  		# frame
	call PRINT
	la a0 bannerPreto
	li a1 288 		# x0 
	li a2,0 		# y0
	mv a3 s6  		# frame
	call PRINT

	la t0,CURR_LEVEL
	lb t1,0(t0)
	li t2,1
	beq t1,t2,PRINTA_FASE_1
	li t2,2
	beq t1,t2,PRINTA_FASE_2
	li t2,3
	beq t1,t2,PRINTA_FASE_3

	PRINTA_FASE_FIM:

	la t0,PLAYER_LIFE
	lb t1,0(t0)
	li t2,0
	beq t1,t2,GAME_OVER
	li t2,1
	beq t1,t2,PRINTA_1_VIDA
	li t2,2
	beq t1,t2,PRINTA_2_VIDAS
	li t2,3
	beq t1,t2,PRINTA_3_VIDAS
	li t2,4
	beq t1,t2,PRINTA_4_VIDAS
	li t2,5
	beq t1,t2,PRINTA_5_VIDAS

	PRINTA_VIDA_FIM:

	j PRINT_TILE.SETUP

PRINTA_FASE_1:
	la a0 FASE1
	li a1 288
	li a2 0
	mv a3 s6
	call PRINT
	j PRINTA_FASE_FIM

PRINTA_FASE_2:
	la a0 FASE2
	li a1 288
	li a2 0
	mv a3 s6
	call PRINT
	j PRINTA_FASE_FIM

PRINTA_FASE_3:
	la a0 FASE3
	li a1 288
	li a2 0
	mv a3 s6
	call PRINT
	j PRINTA_FASE_FIM

PRINTA_1_VIDA:
	la a0 life
	li a1 296
	li a2 40
	mv a3 s6
	call PRINT
	j PRINTA_VIDA_FIM

PRINTA_2_VIDAS:
	la a0 life
	li a1 296
	li a2 40
	mv a3 s6
	call PRINT

	la a0 life
	li a1 296
	li a2 60
	mv a3 s6
	call PRINT
	j PRINTA_VIDA_FIM

PRINTA_3_VIDAS:
	la a0 life
	li a1 296
	li a2 40
	mv a3 s6
	call PRINT

	la a0 life
	li a1 296
	li a2 60
	mv a3 s6
	call PRINT
	
	la a0 life
	li a1 296
	li a2 80
	mv a3 s6
	call PRINT
	j PRINTA_VIDA_FIM

PRINTA_4_VIDAS:
	la a0 life
	li a1 296
	li a2 40
	mv a3 s6
	call PRINT

	la a0 life
	li a1 296
	li a2 60
	mv a3 s6
	call PRINT
	
	la a0 life
	li a1 296
	li a2 80
	mv a3 s6
	call PRINT

	la a0 life
	li a1 296
	li a2 100
	mv a3 s6
	call PRINT
	j PRINTA_VIDA_FIM

PRINTA_5_VIDAS:
	la a0 life
	li a1 296
	li a2 40
	mv a3 s6
	call PRINT

	la a0 life
	li a1 296
	li a2 60
	mv a3 s6
	call PRINT
	
	la a0 life
	li a1 296
	li a2 80
	mv a3 s6
	call PRINT

	la a0 life
	li a1 296
	li a2 100
	mv a3 s6
	call PRINT

	la a0 life
	li a1 296
	li a2 120
	mv a3 s6
	call PRINT
	j PRINTA_VIDA_FIM

PRINT_TILE.SETUP:
	mv s0 zero	# Current X
	mv s1 zero 	# Current Y
	li s2 16 		# Width  (in tiles)
	li s3 15 		# Height (in tiles)
	mv s4 s5 		# Current position in map
PRINT_TILE:
	lb t0 0(s4)
	addi s4 s4 1
	# Insert the correct tile address on a0
	PRINT_TILE.GET_SPRITE:
		li t1 0
		beq t0 t1 SPRITE.FLOOR
		li t1 1
		beq t0 t1 SPRITE.WALL
		li t1 2
		beq t0 t1 SPRITE.BRICK
		li t1 3
		beq t0 t1 SPRITE.POWERUP_MUSHROOM
		li t1 4
		beq t0 t1 SPRITE.GOAL
		li t1 5 # Special brick(has a MUSHROOM in it)
		beq t0 t1 SPRITE.SPECIAL_BRICK
		li t1 6 
		beq t0 t1 SPRITE.GOOMBA
		li t1 7
		beq t0 t1 SPRITE.KOOPA
		li t1 8
		beq t0 t1 SPRITE.EXTERIOR
		SPRITE.FLOOR:
			la a0 floor
			j PRINT_TILE.GET_SPRITE.END
		SPRITE.WALL:
			la a0 exterior
			j PRINT_TILE.GET_SPRITE.END
		SPRITE.BRICK:
			la a0 brick
			j PRINT_TILE.GET_SPRITE.END
		SPRITE.POWERUP_MUSHROOM:
			slli a1 s0 4
			addi a1 a1 32
			slli a2 s1 4
			mv a3 s6
			# First draw floor
			la a0 floor
			call PRINT
			# Draw MUSHROOM over floor
			la a0 mushroom
			call PRINT
			j PRINT_TILE.LOOP_CONTINUE
		SPRITE.SPECIAL_BRICK:
			la a0 specialBrick
			j PRINT_TILE.GET_SPRITE.END
		SPRITE.GOAL:                        
			la a0 goal
			j PRINT_TILE.GET_SPRITE.END
		SPRITE.GOOMBA:
			la a0 goomba
			j PRINT_TILE.GET_SPRITE.END
		SPRITE.KOOPA:
			li a7 30 
			ecall
			li t0 1000 # time (in ms)	
			rem t0 a0 t0
			li t1 500
			blt t0 t1 SPRITE.ENEMY.2 
			SPRITE.ENEMY.1:
			la a0 koopa1
			j PRINT_TILE.GET_SPRITE.END
			SPRITE.ENEMY.2:
			la a0 koopa2
			j PRINT_TILE.GET_SPRITE.END
		SPRITE.EXTERIOR:
			la a0 exterior
			j PRINT_TILE.GET_SPRITE.END
		

	PRINT_TILE.GET_SPRITE.END:
	# Position of the (x, y) tile is ( 16 * x + 32, 16 * y)
	# The offset to the x position is due to the interface
	PRINT_TILE.PRINT:
		slli a1 s0 4
		addi a1 a1 32
		slli a2 s1 4
		mv a3 s6
		call PRINT

	PRINT_TILE.LOOP_CONTINUE:
	
	# Loop back to the next column
	addi s0 s0 1
	blt s0 s2 PRINT_TILE
	
	# Loop back to the next line
	addi s1 s1 1
	mv s0 zero
	blt s1 s3 PRINT_TILE

	j DRAW_PLAYER
	# Function that prints an image according to the following arguments
	# a0 = &image
	# a1 = x
	# a2 = y
	# a3 = frame (0 or 1 )
DRAW_PLAYER:

	la t0 IS_MOVING
	lb t1 0(t0)
	beqz t1 DRAW_PLAYER.IDLE_ANIMATION
	
	# If player is moving, decide sprite based in s8
	li t0 1
	beq s8 t0 DRAW_PLAYER.WALK1
	li t0 2
	beq s8 t0 DRAW_PLAYER.WALK2
	li t0 3
	beq s8 t0 DRAW_PLAYER.WALK3
    # Qualquer outro frame volta para WALK4
DRAW_PLAYER.WALK4:
	    la a0 mario_walk4
	    j DRAW_PLAYER.PRINT
	
DRAW_PLAYER.WALK1:
	    la a0 mario_walk1
	    j DRAW_PLAYER.PRINT
	
DRAW_PLAYER.WALK2:
	    la a0 mario_walk2
	    j DRAW_PLAYER.PRINT
	
DRAW_PLAYER.WALK3:
	    la a0 mario_walk3
	    j DRAW_PLAYER.PRINT

DRAW_PLAYER.IDLE_ANIMATION:
	    la a0 mario_idle
	
DRAW_PLAYER.PRINT:
	    la t0 PLAYER_POS
	    lb t1 0(t0)          # x
	    lb t2 1(t0)          # y
	    slli a1 t1, 4        # x * 16
	    addi a1 a1 32        # Interface's offset
	    slli a2 t2, 4        # y * 16
	    mv a3 s6             # Current frame (para decidir se desenha no frame 0 ou 1)
	    call PRINT
	    j DRAW_BOMB
DRAW_BOMB:
	# Checks if bomb is active
	la t0, IS_BOMB_ACTIVE
	lw t1, 0(t0)
	beqz t1 GAME_LOOP       # If bomb is not active, jump to the next loop

	# Loads the bomb's position
	la t2, BOMB_POS
	lw t3, 0(t2)         # t3 = 0x00YYXX
	andi t4, t3, 0xFF    # t4 = X
	srli t5, t3, 8       # t5 = Y

	# Converts position to screen coordinates
	slli a1, t4, 4       # x * 16
	addi a1, a1, 32      # Interface offset
	slli a2, t5, 4       # y * 16

	# Sprite da bomba
	la a0, bomb
	mv a3, s6            # Frame atual
	call PRINT
	j GAME_LOOP
	
PRINT:
	# Frame 0: 0xFF00 0000
	# Frame 1: 0xFF10 0000
	li t0 0xFF0
	add t0 t0 a3
	slli t0 t0 20
	
	# t0 += x + y * 320
	add t0 t0 a1 
	li t1 320
	mul t1 t1 a2
	add t0 t0 t1
	
	# t1 = &image + 8 <- two first words are dimensions of the image
	addi t1 a0 8
	
	mv t2 zero 	# t2 = line index
	mv t3 zero 	# t3 = col index
	
	lw t4 0(a0) 	# t4 = image width
	lw t5 4(a0) 	# t5 = image height
	
	PRINT.LINE:
		# Prints 4 pixels
		# *t0 = *t1
		lw t6 0(t1)
		sw t6 0(t0)
		
		# Move ahead
		addi t0 t0 4
		addi t1 t1 4
		addi t3 t3 4
		
		# If not at the end of the line, loop back
		blt t3 t4 PRINT.LINE
		
		# Else move down one line
		addi t0 t0 320
		sub t0 t0 t4
		mv t3 zero
		addi t2 t2 1
		
		 # If the are any lines left, loop back
		 bgt t5 t2 PRINT.LINE
	ret
 GET_INPUT:
 	li t1 0xFF200000 			# KDMMIO Address
 	lw t0 0(t1)				# Keyboard control bit
 	andi t0 t0 1				# LSB
 	bne t0 zero PROCESS_INPUT	# If something has been pressed
 	ret
PROCESS_INPUT:
	# t2 = KEY pressed
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
	li t0 'b'
	beq t2 t0 PLACE_BOMB
	# If no key was pressed, IS_MOVING <- 0
	la t3 IS_MOVING
	li t4 0
	sb t4 0(t3)
	ret
	
	# Sets player's  desired posiition
	MOVE.UP:
		addi t5 t5 -1 	# Player Y -= 1
		addi t1 t5 -1	# t1 = Y - 2
		mv t0 t4 		# t0 = Player X
		j PROCESS
	MOVE.LEFT:
		addi t4 t4 -1 	# Player X -= 1
		addi t0 t4 -1 	# t1= X - 2
		mv t0 t4 		# t0 = Y
		j PROCESS
	MOVE.DOWN:
		addi t5 t5 1 	# Player Y += 1
		addi t1 t5 1 	# t1  = Y + 2
		mv t0 t4 		# t0 = X
		j PROCESS
	MOVE.RIGHT:
		addi t4 t4 1 	# Player X += 1
		addi t0 t4 1 	# t0 = X + 2
		mv t1 t5 		# t1 = Y
		j PROCESS
	PLACE_BOMB:
	# Can only activate the bomb if there is no active bomb 
	la t0 IS_BOMB_ACTIVE
	lw t1 0(t0)
	bnez t1 PROCESS.END  # Already has a bomb? Do nothing.
	
	# Save the player's position as (y << 8) | x
	la t2 PLAYER_POS
	lb t3 0(t2)       # x
	lb t4 1(t2)       # y
	slli t4 t4, 8
	or t5 t4 t3      # pos = 0x00YX
	la t6 BOMB_POS
	sw t5 0(t6)
	
	# Save current time
	li a7 30
	ecall
	la t6 BOMB_TIMER
	sw a0 0(t6)
	
	# Activate bomb
	li t1 1
	la t0 IS_BOMB_ACTIVE 
	sw t1 0(t0)
	
	j PROCESS.END

	# Processes the player's desired position
PROCESS:

	# If destination is the goal position treat it as a wall.
	mv t6 t5
	slli t6 t6 8
	add t6 t6 t4
	j CHECK_TILE

CHECK_TILE:
	# t6 = Address of tile in desired position (16 * y + x + &map)
	li t6 16
	mul t6 t6 t5
	add t6 t6 t4
	add t6 t6 s5
	
	#Check what tile is in desired position
	lb s10 0(t6)
	li s11 0
	beq s10 s11 PROCESS.PATH
	li s11 1
	beq s10 s11 PROCESS.WALL
	li s11 2
	beq s10 s11 PROCESS.BRICK
	li s11 3
	beq s10 s11 PROCESS.COLLECT_MUSHROOM # 3 -> Collects MUSHROOM powerup
	li s11 4                             # goal
    beq s10 s11 PROCESS.REACH_GOAL       # jump to handler
	li s11 5
	beq s10 s11 PROCESS.SPECIAL_BRICK
	li s11 6
	beq s10 s11 PROCESS.GOOMBA
	li s11 7
	beq s10 s11 PROCESS.KOOPA
    j PROCESS.PATH

PROCESS.COLLECT_MUSHROOM:
	la t0 PLAYER_LIFE
	lb t1 0(t0)
	addi t1 t1 1
	sb t1 0(t0)

	# Play powerup sound
	li a0, 84
	li a1, 200
	li a2, 34
	li a3, 120
	li a7, 31
	ecall

	# Turn powerup tile in a floor after being collected
	li t2 0 # Floor tile
	sb t2 0(t6)

	j PROCESS.PATH	

PROCESS.REACH_GOAL:
    # Play victory sound
    li a0 72   # Note
    li a1 1000 # Duration
    li a2 121  # Instrument 
    li a3 100  # Volume
    li a7 31   # Syscall play sound
    ecall
    
    # Verifies which level are we
    la t0, CURR_LEVEL
    lb t1, 0(t0)
    li t2, 1
    beq t1, t2, NEXT_LEVEL_2    # Se no nível 1, vai para 2
    li t2, 2
    beq t1, t2, NEXT_LEVEL_3        # Se no nível 2, vai para 3
	li t2, 3
	beq t1, t2 GAME_WIN
	
    j PROCESS.END

PROCESS.GOOMBA:
PROCESS.KOOPA:
	# Player got hit
    # Damage sound
    li a0, 47
    li a1, 150
    li a2, 65
    li a3, 120
    li a7, 31
    ecall
	# If Mario goes to goomba
	# Reduce life
    la t0, PLAYER_LIFE
    lb t1, 0(t0)
    addi t1, t1, -1
    sb t1, 0(t0)
    # Verifies if life == 0
    beqz t1, GAME_OVER
	j PROCESS.END

NEXT_LEVEL_2:
    # Updates to level 2
    li t3, 2
    sb t3, 0(t0)
    j SETUP_LEVEL_2

NEXT_LEVEL_3:
	li t3, 3
	sb t3, 0(t0)
	j SETUP_LEVEL_3
	
PROCESS.PATH:
	# Save new position
	sb t4 0(t3)
	sb t5 1(t3)
	# Variable to keep track if the character is moving or not
	la t2 IS_MOVING
	li t6 1
	sb t6 0(t2)
	
	# Keep track of last move
	li a7 30
	ecall
	la t3 LAST_MOVE_TIME
	sw a0 0(t3)
	
	j PROCESS.END

PROCESS.WALL:
	SOUND.WALL:
	li a0 15 	# note
	li a1 250 	# duration
	li a2 6 	# instrument
	li a3 120 	# volume
	li a7 31 	# ecall
	ecall
	j PROCESS.END

PROCESS.BRICK:

		li a0 20 		# note
		li a1 250 		# duration
		li a2 7 		# instrument
		li a3 127 		# volume
		li a7 31 		# ecall
		ecall
PROCESS.SPECIAL_BRICK:

		li a0 20 		# note
		li a1 250 		# duration
		li a2 7 		# instrument
		li a3 127 		# volume
		li a7 31 		# ecall
		ecall

PROCESS.END:
	ret
DRAW_ENEMY:
	DRAW_GOOMBA:
		
		# Checks if goomba is alive(GOOMBA_LIFE == 1)
		la t0, GOOMBA_LIFE
		lb t1, 0(t0)
		beqz t1 DRAW_GOOMBA.END       # If goomba is not alive, jump to the next loop

		li a7 30 	# current time goes to a0
		ecall
		la t2 GOOMBA_TIMER
		lw t0 0(t2) 	# time (in ms)	
		blt a0 t0 DRAW_GOOMBA.END
		addi t1 a0 250
		sw t1 0(t2)

		# Loads the bomb's position
		la t2, GOOMBA_POS
		lw t3, 0(t2)         # t3 = 0x00YYXX
		andi t4, t3, 0xFF    # t4 = X
		srli t5, t3, 8       # t5 = Y

		# Converts position to screen coordinates
		slli a1, t4, 4       # x * 16
		addi a1, a1, 32      # Interface offset
		slli a2, t5, 4       # y * 16
		# Calculates the map address: t6 = &map + 16 * y + x
			li t0 16
			mul t1 t5 t0 		# t6 = y * 16
			add t1 t1 t4		# t6 = y * 16 + x
			add t6 s5 t1 		# t6 = final tile's address
			
			sb zero 0(t6) 	# current tile
		DRAW_GOOMBA.GOOMBA_WALK:
			# Walk
			lb t0 GOOMBA_DIRECTION # 0 = left // 1 = right
			bnez t0 GOOMBA_MOVE.RIGHT
			GOOMBA_MOVE.LEFT:
			la t0 GOOMBA_POS
			lw t0 0(t0)
			addi t0 t0 -1
			la t1 ENEMY_POS
			sw t0 0(t1)
			addi t4 t4 -1 	# Player X -= 1
			j PROCESS.ENEMY
			GOOMBA_MOVE.RIGHT:
			la t0 GOOMBA_POS
			lw t0 0(t0)
			addi t0 t0 1
			la t1 ENEMY_POS
			sw t0 0(t1)
			addi t4 t4 1 	# Player X += 1
			j PROCESS.ENEMY
	PROCESS.ENEMY:
		mv t6 t5
		slli t6 t6 8
		add t6 t6 t4
	
		li t0 16
		mul t1 t5 t0 		# t6 = y * 16
		add t1 t1 t4		# t6 = y * 16 + x
		add t6 s5 t1 		# t6 = final tile's address
			
		lb t2 0(t6) 		# current tile
		# Collision
		li t3 1  	# Is it a wall?
		beq t2 t3 DRAW_GOOMBA.TURN
		li t3 2 	# Is it a brick? 
		beq t2 t3 DRAW_GOOMBA.TURN
		li t3 5 	# Is it a special brick?
		beq t2 t3 DRAW_GOOMBA.TURN
		
		la t1 PLAYER_POS
		lh t0 0(t1)
		la t1 ENEMY_POS
		lh t1 0(t1)
		beq t0 t1 DRAW_ENEMY.PROCESS_MARIO

		li t2 6
		sb t2 0(t6)
		la t1 GOOMBA_POS
		sb t4 0(t1)
		
		
		j DRAW_GOOMBA.END
		DRAW_GOOMBA.TURN:
			la t1 GOOMBA_DIRECTION
			lb t2 0(t1)
			beqz t2 DRAW_GOOMBA.FIX_LEFT # If it is going to the left, +1
			addi t6 t6 -1
			j DRAW_GOOMBA.FIX
			DRAW_GOOMBA.FIX_LEFT:
				addi t6 t6 1
			DRAW_GOOMBA.FIX:
				li t2 6
				sb t2 0(t6)
			lb t0 0(t1)
			xori t0 t0 1  	# Flip t0
			sb t0 0(t1)
		DRAW_GOOMBA.END:
		j DRAW_KOOPA
	DRAW_ENEMY.PROCESS_MARIO:
		# Player got hit
		# Damage sound
		li a0, 47
		li a1, 150
		li a2, 65
		li a3, 120
		li a7, 31
		ecall
		# If Mario goes to goomba
		# Reduce life
		la t0, PLAYER_LIFE
		lb t1, 0(t0)
		addi t1, t1, -1
		sb t1, 0(t0)
		# Verifies if life == 0
		beqz t1, GAME_OVER
		j DRAW_GOOMBA.TURN
	
	DRAW_KOOPA:
		# Checks if koopa is alive(KOOPA_LIFE == 1)
		la t0, KOOPA_LIFE
		lb t1, 0(t0)
		beqz t1 DRAW_KOOPA.END       # If koopa is not alive, jump to the next loop

		li a7 30 	# current time goes to a0
		ecall
		la t2 KOOPA_TIMER
		lw t0 0(t2) 	# time (in ms)	
		blt a0 t0 DRAW_KOOPA.END
		addi t1 a0 500
		sw t1 0(t2)

		# Loads the koopa's position
		la t2, KOOPA_POS
		lw t3, 0(t2)         # t3 = 0x00YYXX
		andi t4, t3, 0xFF    # t4 = X
		srli t5, t3, 8       # t5 = Y

		# Converts position to screen coordinates
		slli a1, t4, 4       # x * 16
		addi a1, a1, 32      # Interface offset
		slli a2, t5, 4       # y * 16
		# Calculates the map address: t6 = &map + 16 * y + x
			li t0 16
			mul t1 t5 t0 		# t6 = y * 16
			add t1 t1 t4		# t6 = y * 16 + x
			add t6 s5 t1 		# t6 = final tile's address
			
			sb zero 0(t6) 	# current tile
		DRAW_KOOPA.KOOPA_WALK:
			# Walk
			lb t0 KOOPA_DIRECTION # 0 = Up // 1 = Down
			bnez t0 KOOPA_MOVE.DOWN
			KOOPA_MOVE.UP:
			la t0 KOOPA_POS
			lw t0 0(t0)
			addi t0 t0 -256
			la t1 ENEMY_POS
			sw t0 0(t1)
			addi t5 t5 -1 	# Player Y -= 1
			j PROCESS.ENEMY_KOOPA
			KOOPA_MOVE.DOWN:
			la t0 KOOPA_POS
			lw t0 0(t0)
			addi t0 t0 256
			la t1 ENEMY_POS
			sw t0 0(t1)
			addi t5 t5 1 	# Player Y += 1
			j PROCESS.ENEMY_KOOPA
	PROCESS.ENEMY_KOOPA:
		mv t6 t5
		slli t6 t6 8
		add t6 t6 t4
	
		li t0 16
		mul t1 t5 t0 		# t6 = y * 16
		add t1 t1 t4		# t6 = y * 16 + x
		add t6 s5 t1 		# t6 = final tile's address
			
		lb t2 0(t6) 		# current tile
		# Collision
		li t3 1  	# Is it a wall?
		beq t2 t3 DRAW_KOOPA.TURN
		li t3 2 	# Is it a brick? 
		beq t2 t3 DRAW_KOOPA.TURN
		li t3 5 	# Is it a special brick?
		beq t2 t3 DRAW_KOOPA.TURN
		
		la t1 PLAYER_POS
		lh t0 0(t1)
		la t1 ENEMY_POS
		lh t1 0(t1)
		beq t0 t1 DRAW_ENEMY.PROCESS_MARIO_KOOPA

		li t2 7
		sb t2 0(t6)
		la t1 KOOPA_POS
		sb t5 1(t1)
		
		
		j DRAW_KOOPA.END
		DRAW_KOOPA.TURN:
			la t1 KOOPA_DIRECTION
			lb t2 0(t1)
			beqz t2 DRAW_KOOPA.FIX_LEFT # If it is going up, +1
			addi t6 t6 -16
			j DRAW_KOOPA.FIX
			DRAW_KOOPA.FIX_LEFT:
				addi t6 t6 16
			DRAW_KOOPA.FIX:
				li t2 7
				sb t2 0(t6)
				lb t0 0(t1)
				xori t0 t0 1  	# Flip t0
				sb t0 0(t1)
		DRAW_KOOPA.END:
		j DRAW_ENEMY.END
	DRAW_ENEMY.PROCESS_MARIO_KOOPA:
		# Player got hit
		# Damage sound
		li a0, 47
		li a1, 150
		li a2, 65
		li a3, 120
		li a7, 31
		ecall
		# If Mario goes to goomba
		# Reduce life
		la t0, PLAYER_LIFE
		lb t1, 0(t0)
		addi t1, t1, -1
		sb t1, 0(t0)
		# Verifies if life == 0
		beqz t1, GAME_OVER
		j DRAW_KOOPA.TURN
	
EXPLODE_BOMB:
	# Get the bomb's position
	la t0 BOMB_POS
	lw t1 0(t0) 			# t1 = 0x00YYXX
	andi t2 t1 0xFF     	# t2 = X
	srli t3 t1 8 			# t3 = Y
	
	# Tests 5 positions: center, up, down, left, riight
	
	# Center
	mv t4 t2
	mv t5 t3
	call EXPLODE_TILE
	mv a0, t4       # Passa coordenada X
    mv a1, t5       # Passa coordenada Y
    call CHECK_PLAYER_DAMAGE
	
	
	# Up
	la t0 BOMB_POS
	lw t1 0(t0) 		
	andi t2 t1 0xFF     	
	srli t3 t1 8 		
	mv t4 t2
	addi t5 t3 -1
	call EXPLODE_TILE
	mv a0, t4       # Passa coordenada X
    mv a1, t5       # Passa coordenada Y
    call CHECK_PLAYER_DAMAGE
	
	# Down
	la t0 BOMB_POS
	lw t1 0(t0) 		
	andi t2 t1 0xFF     	
	srli t3 t1 8 
	mv t4 t2
	addi t5 t3 1
	call EXPLODE_TILE
	mv a0, t4       # Passa coordenada X
    mv a1, t5       # Passa coordenada Y
    call CHECK_PLAYER_DAMAGE
	
	# Left
	la t0 BOMB_POS
	lw t1 0(t0) 		
	andi t2 t1 0xFF     	
	srli t3 t1 8
	addi t4 t2 -1
	mv t5 t3
	call EXPLODE_TILE
	mv a0, t4       # Passa coordenada X
    mv a1, t5       # Passa coordenada Y
    call CHECK_PLAYER_DAMAGE
	
	# Right
	la t0 BOMB_POS
	lw t1 0(t0) 		
	andi t2 t1 0xFF     	
	srli t3 t1 8
	addi t4 t2 1
	mv t5 t3
	call EXPLODE_TILE
	mv a0, t4       # Passa coordenada X
    mv a1, t5       # Passa coordenada Y
    call CHECK_PLAYER_DAMAGE
	
	j EXPLODE.BOMB.END	
EXPLODE_TILE:
	# t4 = x, t5 = y
	li t0 0
	blt t4 t0 EXPLODE_TILE.END
	blt t5 t0 EXPLODE_TILE.END
	li t0 16
	bge t4 t0 EXPLODE_TILE.END
	li t0 15
	bge t5 t0 EXPLODE_TILE.END
	
	# Calculates the map address: t6 = &map + 16 * y + x
	li t0 16
	mul t1 t5 t0 		# t6 = y * 16
	add t1 t1 t4		# t6 = y * 16 + x
	add t6 s5 t1 		# t6 = final tile's address
	
	lb t2 0(t6) 	# current tile

	li t3 1  		# Is it a wall?
	beq t2 t3 EXPLODE_TILE.END

	li t3 2 # Is it a brick? Normal or special?
	beq t2 t3 EXPLODE_TILE.BREAK_BRICK
	li t3 5
	beq t2 t3 EXPLODE_TILE.BREAK_BRICK

	j EXPLODE_TILE.CONTINUE
	
EXPLODE_TILE.END:
	li a0 1 	# return 1(stop explosion)
	ret
EXPLODE_TILE.BREAK_BRICK:
	# Explosion sound
	li a0 30
	li a1 350
	li a2 127
	li a3 120
	li a7 31
	ecall
	# Is it a special brick?
	li t3 5 					# floor
	beq t2 t3 REVEAL_MUSHROOM		# changes the current tile to a floor tile
	# If it wasnt special, then turn it in a floor tile

SPAWN_FLOOR:
	li t4 0
	sb t4 0 (t6)
	j EXPLODE_TILE.END_BREAK

REVEAL_MUSHROOM:
	li t4 3
	sb t4 0(t6)
EXPLODE_TILE.END_BREAK:
	li a0 1
	ret
EXPLODE_TILE.CONTINUE:
	li a0 0 	# return 0 (explosion continues)
	ret

# Verifies if player is inside explosion range
# Input: a0 = x, a1 = y (explosion coordinates)
CHECK_PLAYER_DAMAGE:
    # load player position
    la t0, PLAYER_POS
    lb t1, 0(t0)        # Player X
    lb t2, 1(t0)        # Player Y
    
    # Compare with explosion Pos
    bne a0, t1, NO_DAMAGE   # X different? No damage
    bne a1, t2, NO_DAMAGE   # Y different? No damage
    
    # Player got hit
    # Damage sound
    li a0, 47
    li a1, 150
    li a2, 65
    li a3, 120
    li a7, 31
    ecall
    
    # Reduce life
    la t0, PLAYER_LIFE
    lb t1, 0(t0)
    addi t1, t1, -1
    sb t1, 0(t0)
    
    # Verifica se vida chegou a zero
    beqz t1, GAME_OVER
    
    NO_DAMAGE:
        ret
 
GAME_OVER:
	la a0 game_over # load GAME_OVER screen
	mv a1 zero
	mv a2 zero
	mv a3 s6
	call PRINT
	
	# Switches frame
	li t0 0xFF200604
	sw s6 0(t0)

GAME_OVER_SONG.LOOP:
	# Music info (musica3)
	li s7,0				# notes count = 0
	la s0,TAMANHO_3	
	lw s1,0(s0)			# number of notes
	la s0,MELODIA_3	# notes adress
	li a3,70				# volume

	GAME_OVER.AWAIT:
	# Play note
		beq s7,s1,GAME_OVER_SONG.LOOP
		lw a0,0(s0)		# read note
		lw a1,4(s0)		# note length
		li a2,43 		# instrument
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
        beqz t0 GAME_OVER.AWAIT 	# Nothing pressed -> Loop back
        lw t2 4(t1)  			
        li t0 ' '
        beq t2 t0 RESPAWN	# space pressed -> RESPAWN
		li t0 27
		beq t2 t0 QUIT		# esc pressed -> Quit
		j GAME_OVER.AWAIT
RESPAWN:
    lb t0, CURR_LEVEL
    li t1, 1
    beq t0, t1, SETUP_LEVEL_1
    li t1, 2
    beq t0, t1, SETUP_LEVEL_2
	li t1, 3
	beq t0, t1, SETUP_LEVEL_3
    j SETUP_LEVEL_1  # Padrão para nível 1

GAME_WIN:
    la a0 telaVitoria
	mv a1 zero
	mv a2 zero
	mv a3 s6
	call PRINT
    j ENDING

ENDING:
	la a0 telaVitoria # carrega a tela de vitoria
	mv a1 zero
	mv a2 zero
	mv a3 s6
	call PRINT
	
	# Switches frame
	li t0 0xFF200604
	sw s6 0(t0)
	
	ENDING_SONG.LOOP:
	# Music info (SWEDEN song)
	li s7,0				# notes count = 0
	la s0,TAMANHO_1	
	lw s1,0(s0)			# number of notes
	la s0,MELODIA_1		# notes adress
	li a3,100				# volume
	ENDING.AWAIT:   
		# Play note
		beq s7,s1,ENDING_SONG.LOOP
		lw a0,0(s0)		# read note
		lw a1,4(s0)		# note length
		li a2,16 		# instrument
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
        beqz t0 ENDING.AWAIT 	# Nothing pressed -> Loop back
        lw t2 4(t1)  			
        li t0 ' '
        beq t2 t0 SETUP_LEVEL_1	# space pressed -> level 1
		li t0 27
		beq t2 t0 QUIT		# esc pressed -> Quit
		j ENDING.AWAIT
QUIT:
   	li a7, 10 		# termina o programa
   	ecall
   	

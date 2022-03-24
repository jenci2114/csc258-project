###################################################################################################
#
# CSC258H1S Winter 2022 Assembly Final Project
# University of Toronto, St. George
#
# Name: Jenci Wei
# Student Number: 1006670498
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base address for display: 0x10008000 ($gp)
#
# Milestone reached: 2a
# 
# Additional features implemented:
# - None
#
###################################################################################################

.data
displayAddress: 	.word 0x10008000
keyboardAddress: 	.word 0xffff0000

frogColour: 		.word 0x69db41

safeRegionColour: 	.word 0x8b1ad6
goalRegionColour: 	.word 0x4ea333
roadColour: 		.word 0x808080
waterColour:		.word 0x000044

logColour: 		.word 0xcf6f50
vehicleColour: 		.word 0x000000

frogPosX: 		.word 0x3	# From left to right, 0-based indexing
frogPosY: 		.word 0x7	# From top downwawrds, 0-based indexing

logTopSpace: 		.space 512	# Top Log
logBotSpace: 		.space 512 	# Bottom Log

vehicleTopSpace: 	.space 512 	# Top Vehicle
vehicleBotSpace: 	.space 512 	# Bottom Vehicle
	
.text

Init:
lw 	$s0, displayAddress 		# Set $s0 to hold displayAddress
addi 	$s1, $s0, 3632 			# Initialize frog position

la 	$a0, logTopSpace 		# $a0 = logTopSpace
li 	$a1, 0				# $a1 = 0
jal 	InitMem				# InitMem for logTopSpace

la 	$a0, logBotSpace 		# $a0 = logBotSpace
li 	$a1, 1				# $a1 = 1
jal 	InitMem				# InitMem for logBotSpace

la 	$a0, vehicleTopSpace 		# $a0 = vehicleTopSpace
li 	$a1, 1				# $a1 = 1
jal 	InitMem				# InitMem for vehicleTopSpace

la 	$a0, vehicleBotSpace 		# $a0 = vehicleBotSpace
li 	$a1, 0				# $a1 = 0
jal 	InitMem				# InitMem for vehicleBotSpace

Main:

jal 	DrawBackground	

add	$a0, $s1, $zero			# Draw frog in start region
jal 	DrawFrog 	

CheckKeyboardInput:
lw 	$t0, keyboardAddress 		# Load keyboard address into $t0
lw 	$t1, 0($t0) 			# Check whether key is pressed and store in $t1
beq 	$t1, 1, CheckKeyInput		# Proceed onto check which key it is if some key is pressed

Sleep:
li 	$v0, 32 			# Sleep
li 	$a0, 16 			# Sleep for 16 ms = 1/60 s
syscall

j Main

CheckKeyInput:
lw 	$t0, keyboardAddress
addi	$t0, $t0, 4			# Load key address to $t0

lw 	$t2, 0($t0) 			# Store the ascii of the pressed key into $t2
beq 	$t2, 0x77, RespondToW		# w is pressed
beq 	$t2, 0x61, RespondToA		# a is pressed
beq 	$t2, 0x73, RespondToS		# s is pressed
beq 	$t2, 0x64, RespondToD		# d is pressed

j Main 					# not one of wasd, go back

RespondToW:
lw 	$t1, frogPosY 			# Store the y-pos of the frog into $t1
beq 	$t1, 0, Main 			# Frog is in top row, go to Main
subi 	$t1, $t1, 1 			# Move frog up 1 row
sw 	$t1, frogPosY			# Save the move
j 	Main

RespondToA:
lw 	$t1, frogPosX 			# Store the x-pos of the frog into $t1
beq 	$t1, 0, Main 			# Frog is on the left edge, go to Main
subi 	$t1, $t1, 1 			# Move frog left by 1
sw 	$t1, frogPosX 			# Save the move
j 	Main

RespondToS:
lw 	$t1, frogPosY 			# Store the y-pos of the frog into $t1
beq 	$t1, 7, Main 			# Frog is in bottom row, go to Main
addi 	$t1, $t1, 1 			# Move frow down 1 row
sw 	$t1, frogPosY 			# Save the move
j 	Main

RespondToD:
lw 	$t1, frogPosX 			# Store the x-pos of the frog into $t1
beq 	$t1, 7, Main 			# Frog is on the right edge, go to Main
addi 	$t1, $t1, 1 			# Move frog right by 1
sw 	$t1, frogPosX 			# Save the move
j 	Main

# |--------------------------------| Function: InitMem |-----------------------------------------|

# Arguments: 		$a0: Address of memory to be initialized
# 			$a1: Initial value
# Return values: 	none

InitMem:
add	$t0, $a1, $zero			# $t0 = initial value
li	$t1, 0				# $t1 = 0, outer loop variable
add 	$t2, $a0, $zero			# $t2 = address of memory

StoreMem:
beq 	$t1, 4, StoreMemEnd		# Break if finish storing mem
li 	$t3, 0				# $t3 = 0, inner loop variable

StoreMemBlock:
beq 	$t3, 8, StoreMemBlockEnd	# Break if finish storing this block
sw	$t0, 0($t2)			# Store value of $t0 to the current pixel
sw 	$t0, 128($t2) 			# Do the same for row 2
sw 	$t0, 256($t2) 			# row 3
sw 	$t0, 384($t2) 			# row 4
addi 	$t2, $t2, 4 			# Increment pixel count
addi 	$t3, $t3, 1			# Increment inner loop variable
j 	StoreMemBlock 

StoreMemBlockEnd:
addi 	$t1, $t1, 1 			# Increment outer loop variable

beq 	$t0, 0, SetMemExistence 	# Check if $t0 == 0, branch if so
li 	$t0, 0				# If not, $t0 = 0
j 	StoreMem

SetMemExistence:
li 	$t0, 1 				# $t0 = 1
j 	StoreMem

StoreMemEnd:

jr 	$ra


# |----------------------------------------------------------------------------------------------|

# |----------------------------| Function: DrawBackground |--------------------------------------|

# Arguments: 		none
# Return values: 	none

DrawBackground:
lw 	$t0, displayAddress 		# $t0 = displayAddress;
li 	$t1, 0 				# $t1 = 0;
lw 	$t2, goalRegionColour		# $t2 = goalRegionColour;

DrawGoalRegion:
beq 	$t1, 1024, DrawGoalRegionEnd 	# while ($t1 != 1024) {
add 	$t3, $t0, $t1			#	$t3 = $t0 + $t1;	
sw 	$t2, 0($t3)			# 	*($t3) = $t2;
addi 	$t1, $t1, 4			# 	$t1 += 4;
j DrawGoalRegion			# }

DrawGoalRegionEnd:			# $t1 == 512 at this point

lw 	$t2, waterColour		# $t2 = waterColour;
la 	$t4, logTopSpace 		# $t4 = adddress of logTopSpace
lw 	$t5, logColour			# $t5 = logColour
li	$t6, 0 				# $t6 is how much we move from logTopSpace
				
DrawTopWater:
beq 	$t1, 1536, DrawTopWaterEnd 	# while ($t1 != 1536) {
add 	$t3, $t0, $t1			#	$t3 = $t0 + $t1;
add 	$t7, $t4, $t6			# 	$t7 is the current position relative to log
lw 	$t8, 0($t7) 			# 	$t8 = whether current pixel is log
beq 	$t8, 1, DrawTopLog 		# 	if ($t8) draw log	

sw 	$t2, 0($t3)			# 	*($t3) = $t2;
addi 	$t1, $t1, 4			# 	$t1 += 4;
addi 	$t6, $t6, 4 			# 	$t6 += 4;
j 	DrawTopWater			# }

DrawTopLog:
sw 	$t5, 0($t3) 			# 	*($t3) = $t5;
addi 	$t1, $t1, 4			# 	$t1 += 4;
addi 	$t6, $t6, 4 			# 	$t6 += 4;
j 	DrawTopWater			# }


DrawTopWaterEnd:			# $t1 == 1536 at this point

la 	$t4, logBotSpace 		# $t4 = adddress of logBotSpace
li	$t6, 0 				# $t6 is how much we move from logBotSpace

DrawBotWater:
beq 	$t1, 2048, DrawBotWaterEnd 	# while ($t1 != 2048) {
add 	$t3, $t0, $t1			#	$t3 = $t0 + $t1;	
add 	$t7, $t4, $t6			# 	$t7 is the current position relative to log
lw 	$t8, 0($t7) 			# 	$t8 = whether current pixel is log
beq 	$t8, 1, DrawBotLog 		# 	if ($t8) draw log	

sw 	$t2, 0($t3)			# 	*($t3) = $t2;
addi 	$t1, $t1, 4			# 	$t1 += 4;
addi 	$t6, $t6, 4 			# 	$t6 += 4;
j 	DrawBotWater			# }

DrawBotLog:
sw 	$t5, 0($t3) 			# 	*($t3) = $t5;
addi 	$t1, $t1, 4			# 	$t1 += 4;
addi 	$t6, $t6, 4 			# 	$t6 += 4;
j 	DrawBotWater			# }

DrawBotWaterEnd:			# $t1 == 2048 at this point

lw 	$t2, safeRegionColour 		# $t2 = safeRegionColour;

DrawSafeRegion:
beq 	$t1, 2560, DrawSafeRegionEnd 	# while ($t1 != 2560) {
add 	$t3, $t0, $t1			#	$t3 = $t0 + $t1;	
sw 	$t2, 0($t3)			# 	*($t3) = $t2;
addi 	$t1, $t1, 4			# 	$t1 += 4;
j 	DrawSafeRegion			# }

DrawSafeRegionEnd:			# $t1 == 2560 at this point

lw 	$t2, roadColour 		# $t2 = roadColour;
la 	$t4, vehicleTopSpace 		# $t4 = adddress of vehicleTopSpace
lw 	$t5, vehicleColour		# $t5 = vehicleColour
li	$t6, 0 				# $t6 is how much we move from vehicleTopSpace

DrawTopRoad:
beq 	$t1, 3072, DrawTopRoadEnd 	# while ($t1 != 3072) {
add 	$t3, $t0, $t1			#	$t3 = $t0 + $t1;	
add 	$t7, $t4, $t6			# 	$t7 is the current position relative to vehicle
lw 	$t8, 0($t7) 			# 	$t8 = whether current pixel is vehicle
beq 	$t8, 1, DrawTopVehicle 		# 	if ($t8) draw vehicle	

sw 	$t2, 0($t3)			# 	*($t3) = $t2;
addi 	$t1, $t1, 4			# 	$t1 += 4;
addi 	$t6, $t6, 4 			# 	$t6 += 4;
j 	DrawTopRoad			# }

DrawTopVehicle:
sw 	$t5, 0($t3) 			# 	*($t3) = $t5;
addi 	$t1, $t1, 4			# 	$t1 += 4;
addi 	$t6, $t6, 4 			# 	$t6 += 4;
j 	DrawTopRoad			# }

DrawTopRoadEnd:				# $t1 = 3072 at this point

la 	$t4, vehicleBotSpace 		# $t4 = adddress of vehicleBotSpace
li	$t6, 0 				# $t6 is how much we move from vehicleBotSpace

DrawBotRoad:
beq 	$t1, 3584, DrawBotRoadEnd 	# while ($t1 != 3584) {
add 	$t3, $t0, $t1			#	$t3 = $t0 + $t1;
add 	$t7, $t4, $t6			# 	$t7 is the current position relative to vehicle
lw 	$t8, 0($t7) 			# 	$t8 = whether current pixel is vehicle
beq 	$t8, 1, DrawBotVehicle 		# 	if ($t8) draw vehicle	
	
sw 	$t2, 0($t3)			# 	*($t3) = $t2;
addi 	$t1, $t1, 4			# 	$t1 += 4;
addi 	$t6, $t6, 4 			# 	$t6 += 4;
j 	DrawBotRoad			# }

DrawBotVehicle:
sw 	$t5, 0($t3) 			# 	*($t3) = $t5;
addi 	$t1, $t1, 4			# 	$t1 += 4;
addi 	$t6, $t6, 4 			# 	$t6 += 4;
j 	DrawBotRoad			# }

DrawBotRoadEnd:				# $t1 = 3584 at this point

lw 	$t2, safeRegionColour 		# $t2 = safeRegionColour;

DrawStartRegion:
beq 	$t1, 4096, DrawStartRegionEnd 	# while ($t1 != 4096) {
add 	$t3, $t0, $t1			#	$t3 = $t0 + $t1;	
sw 	$t2, 0($t3)			# 	*($t3) = $t2;
addi 	$t1, $t1, 4			# 	$t1 += 4;
j 	DrawStartRegion			# }

DrawStartRegionEnd:			# $t1 = 3584 at this point

jr 	$ra

# |-----------------------------------------------------------------------------------------------|


# |-----------------------------| Function: DrawFrog |--------------------------------------------|

# Arguments: 		none
# Return values:	none

DrawFrog:
lw 	$t0, displayAddress 	 	# Load displayAddress into $t0
lw 	$t1, frogPosX			# Load x-pos of the frog into $t1
lw 	$t2, frogPosY 			# Load y-pos of the frog into $t2

li 	$t3, 16 			# $t3 = 16, x-pos to byte conversion
mult 	$t1, $t3 			# $t4 = $t1 * 16
mflo	$t4 				
add 	$t0, $t0, $t4 			# Increment address with x-pos

li 	$t3, 512 			# $t3 = 512, y-pos to byte conversion
mult 	$t2, $t3 			# $t4 = $t2 * 512
mflo 	$t4
add 	$t0, $t0, $t4			# Increment address with y-pos

lw 	$t1, frogColour			# $t1 = frogColour;
add 	$t2, $zero, $zero 		# $t2 = 0;  // current row

DrawFrogConditional:
beq 	$t2, 0, DrawFrogExterior 	# Draw first row of the frog
beq 	$t2, 1, DrawFrogRow		# Draw second row of the frog
beq 	$t2, 2, DrawFrogInterior	# Draw third row of the frog
beq 	$t2, 3, DrawFrogRow		# Draw last row of the frog

jr 	$ra				# Finish drawing the frog

DrawFrogExterior:
sw 	$t1, 0($t0) 			# Draw the left front leg
sw 	$t1, 12($t0) 			# Draw the right front leg
addi 	$t0, $t0, 128			# Increment the display pointer to next row
addi 	$t2, $t2, 1 			# Update row number
j 	DrawFrogConditional

DrawFrogRow:
sw 	$t1, 0($t0) 			# Draw four pixels in the current row
sw 	$t1, 4($t0)
sw 	$t1, 8($t0)
sw 	$t1, 12($t0)
addi 	$t0, $t0, 128			# Increment the display pointer to next row
addi 	$t2, $t2, 1 			# Update row number
j 	DrawFrogConditional

DrawFrogInterior:
sw 	$t1, 4($t0) 			# Draw the left torso
sw 	$t1, 8($t0) 			# Draw the right torso
addi 	$t0, $t0, 128			# Increment the display pointer to next row
addi 	$t2, $t2, 1 			# Update row number
j	DrawFrogConditional

# |-----------------------------------------------------------------------------------------------|




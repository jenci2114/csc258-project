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
# Milestone reached: 3
# 
# Additional features implemented:
# - Display the number of lives remaining
#
###################################################################################################

.data
displayAddress: 	.word 0x10008000
keyboardAddress: 	.word 0xffff0000

frogColour: 		.word 0xffff54

safeRegionColour: 	.word 0x8b1ad6
goalRegionColour: 	.word 0x69db41
topRegionColour: 	.word 0xeb5628
roadColour: 		.word 0x808080
waterColour:		.word 0x000044

logColour: 		.word 0xba8c63
vehicleColour: 		.word 0x000000

frogPosX: 		.word 0x30	# From left to right, 0-based indexing, unit is in "bytes"
frogPosY: 		.word 0x7	# From top downwawrds, 0-based indexing, unit is in "frogheights"

frogStartPosX: 		.word 0x30
frogStartPosY: 		.word 0x7

logTopSpace: 		.space 512	# Top Log
logBotSpace: 		.space 512 	# Bottom Log

vehicleTopSpace: 	.space 512 	# Top Vehicle
vehicleBotSpace: 	.space 512 	# Bottom Vehicle

speedCountdown: 	.word 0x10 	# Speed of objects counting down based on refresh rate

livesRemaining:		.word 0x3 	# Number of lives left, starting from 3
lifeColour: 		.word 0xa2eddf 	# Colour of life heart
lifeLostColour: 	.word 0x282828 	# Colour of life heart when life is lost
	
.text

Init:
jal 	DrawStatusBar 			# Draw status bar

lw 	$s0, displayAddress 		# Set $s0 to hold displayAddress

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
jal 	DrawFrog

jal 	CheckWin 			# Check whether the player has won
beq 	$v0, 1, GameOver 		# The player wins, game is over
beq 	$v0, -1, LifeLost 		# The player loses a life

la 	$a0, vehicleTopSpace 		# Check collisions for top row vehicle
li 	$a1, 1 				# Presence of vehicle is fatal
li 	$a2, 5 				# Top vehicle is on row 5
jal 	CheckCollision
beq 	$v0, 1, LifeLost 		# Lose a life when there is vehicle collision

la 	$a0, vehicleBotSpace 		# Check collisions for bottom row vehicle
li 	$a1, 1 				# Presence of vehicle is fatal
li 	$a2, 6 				# Bottom vehicle is on row 6
jal 	CheckCollision
beq 	$v0, 1, LifeLost 		# Lose a life when there is vehicle collision

la 	$a0, logTopSpace 		# Check collisions for top row log
li 	$a1, 0 				# No presence of log is fatal
li 	$a2, 2 				# Top log is on row 2
jal 	CheckCollision
beq 	$v0, 1, LifeLost 		# Lose a life when there is vehicle collision

la 	$a0, logBotSpace 		# Check collisions for bottom row log
li 	$a1, 0 				# No presence of log is fatal
li 	$a2, 3 				# Bottom log is on row 3
jal 	CheckCollision 
beq 	$v0, 1, LifeLost 		# Lose a life when there is vehicle collision


CheckKeyboardInput:
lw 	$t0, keyboardAddress 		# Load keyboard address into $t0
lw 	$t1, 0($t0) 			# Check whether key is pressed and store in $t1
beq 	$t1, 1, CheckKeyInput		# Proceed onto check which key it is if some key is pressed

Sleep:
li 	$v0, 32 			# Sleep
li 	$a0, 16 			# Sleep for 16 ms = 1/60 s
syscall

lw	$t0, speedCountdown 		# $t0 = speedCountdown
beq 	$t0, 0, UpdateObjects 		# If countdown finishes, update positions of objects
subi 	$t0, $t0, 1			# Decrement countdown
sw 	$t0, speedCountdown 		# Save countdown
j Main

UpdateObjects:
la 	$a0, logTopSpace 		# $a0 = logTopSpace
jal 	MoveObjectLeft 			# Move the top log left

la	$a0, logBotSpace 		# $a0 = logBotSpace
jal 	MoveObjectRight			# Move the bottom log right

la 	$a0, vehicleTopSpace 		# $a0 = vehicleTopSpace
jal 	MoveObjectLeft 			# Move the top vehicle left

la 	$a0, vehicleBotSpace 		# $a0 = vehicleBotSpace
jal 	MoveObjectRight 		# Move the bottom vehicle right

addi	$t0, $zero, 16			# Reset speed countdown
sw 	$t0, speedCountdown 		# Save countdown	

jal 	MoveFrogWithLog	
beq 	$v0, 1, LifeLost 		# If frog is moved out of bound, lose a life

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
ble 	$t1, 16, MoveToLeftEnd 		# Frog is near the left edge, move to the left edge
subi 	$t1, $t1, 16 			# Move frog left by 16 bytes
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
bge 	$t1, 96, MoveToRightEnd 	# Frog is near the right edge, move to the right edge
addi 	$t1, $t1, 16 			# Move frog right by 16 bytes
sw 	$t1, frogPosX 			# Save the move
j 	Main

MoveToLeftEnd:
li 	$t1, 0 				# $t1 = 0, byte value of left edge
sw 	$t1, frogPosX 			# Move frog to left edge
j 	Main

MoveToRightEnd:
li 	$t1, 112 			# $t1 = 112, byte value of right edge
sw 	$t1, frogPosX 			# Move frog to right edge
j 	Main

LifeLost:
lw 	$t0, livesRemaining 		# Store the lives remaining in $t0
subi 	$t0, $t0, 1 			# Lives remaining -1
sw 	$t0, livesRemaining 		# Update lives remaining
beq 	$t0, 0, GameOver		# No more lives remaining, game is over
jal 	Respawn
jal 	DrawStatusBar
j 	Main

GameOver:
jal 	DrawBackground	
jal 	DrawFrog 			# Reflect where the frog is when game is over
jal 	DrawStatusBar
li $v0, 10
syscall

###################################################################################################
#                                      # Functions #                                              #
###################################################################################################


# |---------------------------------| Function: InitMem |-----------------------------------------|

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


# |-----------------------------------------------------------------------------------------------|

# |-----------------------------| Function: DrawBackground |--------------------------------------|

# Arguments: 		none
# Return values: 	none

DrawBackground:
lw 	$t0, displayAddress 		# $t0 = displayAddress;
li 	$t1, 512 			# $t1 = 512;
lw 	$t2, topRegionColour		# $t2 = topRegionColour;

DrawTopLeftRegion:
beq 	$t1, 560, DrawTopLeftRegionEnd 	# while ($t1 != 544) {
add 	$t3, $t0, $t1 			# $t3 is destination location
sw 	$t2, 0($t3) 			# Fill row 1
sw 	$t2, 128($t3) 			# row 2
sw 	$t2, 256($t3) 			# 3
sw 	$t2, 384($t3) 			# 4
addi 	$t1, $t1, 4			# 	$t1 += 4;
j 	DrawTopLeftRegion

DrawTopLeftRegionEnd:

lw 	$t2, goalRegionColour 		# Set $t2 to goal region colour

DrawGoalRegion:
beq 	$t1, 592, DrawGoalRegionEnd 	# while ($t1 != 592) {
add 	$t3, $t0, $t1 			# $t3 is destination location
sw 	$t2, 0($t3) 			# Fill row 1
sw 	$t2, 128($t3) 			# row 2
sw 	$t2, 256($t3) 			# 3
sw 	$t2, 384($t3) 			# 4
addi 	$t1, $t1, 4			# 	$t1 += 4;
j 	DrawGoalRegion

DrawGoalRegionEnd:

lw 	$t2, topRegionColour 		# Set $t2 to top region colour

DrawTopRightRegion:
beq 	$t1, 640, DrawTopRightRegionEnd # while ($t1 != 640) {
add 	$t3, $t0, $t1 			# $t3 is destination location
sw 	$t2, 0($t3) 			# Fill row 1
sw 	$t2, 128($t3) 			# row 2
sw 	$t2, 256($t3) 			# 3
sw 	$t2, 384($t3) 			# 4
addi 	$t1, $t1, 4			# 	$t1 += 4;
j 	DrawTopRightRegion

DrawTopRightRegionEnd:

li 	$t1, 1024 			# Set $t1 to the correct location (row 2)

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


# |----------------------------| Function: DrawStatusBar |----------------------------------------|
 
# Arguments: 		none
# Return value: 	none

DrawStatusBar:
lw 	$t0, displayAddress 		# $t0 = displayAddress;
li 	$t1, 0 				# $t1 = 512;
lw 	$t2, topRegionColour		# $t2 = topRegionColour;

DrawTopRegion:
beq 	$t1, 512, DrawTopRegionEnd 	# while ($t1 != 512) {
add 	$t3, $t0, $t1			#	$t3 = $t0 + $t1;	
sw 	$t2, 0($t3)			# 	*($t3) = $t2;
addi 	$t1, $t1, 4			# 	$t1 += 4;
j DrawTopRegion				# }

DrawTopRegionEnd:			# $t1 == 512 at this point

lw 	$t2, lifeColour			# $t2 = lifeColour
lw 	$t3, lifeLostColour 		# $t3 = lifeLostColour
lw 	$t4, livesRemaining 		# Store the number of lives remaining, available life accumulator
lw 	$t0, displayAddress 		# Explicitly initialize $t0 to displayAddress
li 	$t6, 0 				# Life accumulator, draw life

DrawLife:
beq 	$t6, 3, DrawLifeEnd		# Already drew all lives
sw 	$t3, 0($t0)			# Draw border
sw 	$t3, 4($t0) 
sw 	$t3, 8($t0)
sw 	$t3, 12($t0)
sw 	$t3, 128($t0)
sw 	$t3, 140($t0)
sw 	$t3, 256($t0)
sw 	$t3, 268($t0)
sw 	$t3, 384($t0)
sw 	$t3, 388($t0)
sw 	$t3, 392($t0)
sw 	$t3, 396($t0)

bgt 	$t4, 0, DrawRemainingLife 	# If there is life remaining, fill heart with colour
add 	$t5, $t3, $zero 		# Else set colour to grey
j 	DrawLifeInterior

DrawRemainingLife:
add 	$t5, $t2, $zero 		# Set colour to red
subi 	$t4, $t4, 1 			# Deduct available life accumulator by 1

DrawLifeInterior:
sw 	$t5, 132($t0) 			# Draw life interior
sw 	$t5, 136($t0)
sw 	$t5, 260($t0)
sw 	$t5, 264($t0)

addi 	$t0, $t0, 16 			# Increment location to 4 pixels after
addi 	$t6, $t6, 1 			# Increment life accumulator
j 	DrawLife 			# Loop back

DrawLifeEnd:
jr 	$ra


# |-----------------------------------------------------------------------------------------------|


# |-----------------------------| Function: DrawFrog |--------------------------------------------|

# Arguments: 		none
# Return values:	none

DrawFrog:
lw 	$t0, displayAddress 	 	# Load displayAddress into $t0
lw 	$t1, frogPosX			# Load x-pos of the frog into $t1
lw 	$t2, frogPosY 			# Load y-pos of the frog into $t2
			
add 	$t0, $t0, $t1 			# Increment address with x-pos

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

# |---------------------------| Function: MoveObjectLeft |----------------------------------------|
 
# Arguments: 		$a0: Address of object to be operated
# Return value: 	none

MoveObjectLeft:

add 	$t0, $a0, $zero 			# Store address of object into $t0
lw 	$t1, 0($t0) 				# Store content of $t0 into $t1
li 	$t3, 0					# $t3 = 0, counts how many operations of fill-unfill is performed
add 	$t4, $t1, $zero 			# $t4 = 0, flag for wrapping

beq 	$t4, 1, MoveObjectLeftSearchZero 	# Leftmost pixel is filled, unfill first

MoveObjectLeftSearchOne: 			# Notice that $t1 is appropriately set at this point
beq 	$t1, 1, MoveObjectLeftSearchOneEnd	# Iterate until we have reached a filled pixel
addi 	$t0, $t0, 4 				# Increment address
lw 	$t1, 0($t0) 				# Update address content
j 	MoveObjectLeftSearchOne

MoveObjectLeftSearchOneEnd: 			# Found the first filled pixel
subi 	$t0, $t0, 4 				# Decrement address to prepare for filling
li 	$t2, 1	 				# $t2 = 1
sw 	$t2, 0($t0) 				# Fill pixel
sw 	$t2, 128($t0) 				# Fill second row
sw 	$t2, 256($t0) 				# third row
sw 	$t2, 384($t0) 				# fourth

MoveObjectLeftSearchZero: 			# Notice that $t1 is appropriately set at this point
beq 	$t1, 0, MoveObjectLeftSearchZeroEnd	# Iterate until we have reached an unfilled pixel
addi 	$t0, $t0, 4 				# Increment address
lw 	$t1, 0($t0) 				# Update address content
j 	MoveObjectLeftSearchZero

MoveObjectLeftSearchZeroEnd: 			# Found the first unfilled pixel
subi 	$t0, $t0, 4 				# Decrement address to prepare for filling
li 	$t2, 0					# $t2 = 0
sw 	$t2, 0($t0) 				# Fill pixel
sw 	$t2, 128($t0) 				# Fill second row
sw 	$t2, 256($t0) 				# third row
sw 	$t2, 384($t0) 				# fourth

addi 	$t3, $t3, 1 				# ++$t3 since we have performed a fill-unfill operation
beq 	$t3, 2, MoveObjectLeftEnd 		# If two ops are performed, we're done
j 	MoveObjectLeftSearchOne			# Else we repeat the fill-unfill operation

MoveObjectLeftEnd:

beq 	$t4, 1, MoveObjectLeftWrap		# Wrap flag is on, perform wrap
jr 	$ra 					# Else we're done

MoveObjectLeftWrap:

MoveObjectLeftSearchWrap: 			# Notice that $t1 == 0 at this point
sub 	$t5, $t0, $a0 				# Store offset between $t0 and $a0 in $t5
beq 	$t1, 1, MoveObjectLeftSearchWrapEnd 	# Break if found the first filled pixel
beq 	$t5, 128, MoveObjectLeftSearchWrapEnd 	# Also break if reached end of row
addi 	$t0, $t0, 4 				# Increment address
lw 	$t1, 0($t0) 				# Update address content
j 	MoveObjectLeftSearchWrap

MoveObjectLeftSearchWrapEnd:
subi 	$t0, $t0, 4 				# Found the first filled pixel
li 	$t2, 1					# $t2 = 1
sw 	$t2, 0($t0) 				# Fill pixel
sw 	$t2, 128($t0) 				# Fill second row
sw 	$t2, 256($t0) 				# third row
sw 	$t2, 384($t0) 				# fourth

jr 	$ra

# |-----------------------------------------------------------------------------------------------|

# |---------------------------| Function: MoveObjectRight |---------------------------------------|
 
# Arguments: 		$a0: Address of object to be operated
# Return value: 	none

MoveObjectRight:

add 	$t0, $a0, $zero 			# Store address of object into $t0
lw 	$t1, 0($t0) 				# Store content of $t0 into $t1
li 	$t3, 0					# $t3 = 0, counts how many operations of unfill-fill is performed

lw 	$t4, 124($t0)				# Store last pixel in $t1
beq 	$t4, 0, MoveObjectRightSearchOne 	# If last pixel is unfilled, proceed to main algorithm

MoveObjectRightFirstSearch:			# Else there might be three disjoint boxes
beq 	$t1, 0, MoveObjectRightSearchOne	# If left-most pixel not filled, proceed to algorithm
addi 	$t0, $t0, 4 				# Else do nothing, increment address
lw 	$t1, 0($t0) 				# Update address content
j 	MoveObjectRightFirstSearch

MoveObjectRightSearchOne: 			# Notice that $t1 is appropriately set at this point
beq 	$t1, 1, MoveObjectRightSearchOneEnd	# Iterate until we have reached a filled pixel
addi 	$t0, $t0, 4 				# Increment address
lw 	$t1, 0($t0) 				# Update address content
j 	MoveObjectRightSearchOne

MoveObjectRightSearchOneEnd: 			# Found the first filled pixel
li 	$t2, 0					# $t2 = 0
sw 	$t2, 0($t0) 				# Unfill pixel
sw 	$t2, 128($t0) 				# Unfill second row
sw 	$t2, 256($t0) 				# third row
sw 	$t2, 384($t0) 				# fourth

MoveObjectRightSearchZero: 			# Notice that $t1 is appropriately set at this point
sub 	$t4, $t0, $a0 				# Store the offset between $t0 and $a0 into $t4
beq 	$t1, 0, MoveObjectRightSearchZeroEnd	# Iterate until we have reached an unfilled pixel
beq 	$t4, 124, MoveObjectRightWrap		# Since no unfilled spot is found on the right edge, wrap around
addi 	$t0, $t0, 4 				# Increment address
lw 	$t1, 0($t0) 				# Update address content
j 	MoveObjectRightSearchZero

MoveObjectRightSearchZeroEnd: 			# Found the first unfilled pixel
li 	$t2, 1					# $t2 = 1
sw 	$t2, 0($t0) 				# Fill pixel
sw 	$t2, 128($t0) 				# Fill second row
sw 	$t2, 256($t0) 				# third row
sw 	$t2, 384($t0) 				# fourth

addi 	$t3, $t3, 1 				# ++$t3 since we have performed a unfill-fill operation
beq 	$t3, 2, MoveObjectRightEnd 		# If two ops are performed, we're done
j 	MoveObjectRightSearchOne		# Else we repeat the fill-unfill operation

MoveObjectRightEnd:

jr 	$ra 					# Else we're done

MoveObjectRightWrap:
add 	$t0, $a0, $zero 			# Store address of object into $t0
lw 	$t1, 0($t0) 				# Store content of $t0 into $t1

MoveObjectRightSearchWrap:
beq 	$t1, 0, MoveObjectRightSearchWrapEnd 	# Break if found unfilled pixel
addi 	$t0, $t0, 4 				# Increment address
lw 	$t1, 0($t0) 				# Update address content
j MoveObjectRightSearchWrap

MoveObjectRightSearchWrapEnd:			# Found the first unfilled pixel
li 	$t2, 1					# $t2 = 1
sw 	$t2, 0($t0) 				# Fill pixel
sw 	$t2, 128($t0) 				# Fill second row
sw 	$t2, 256($t0) 				# third row
sw 	$t2, 384($t0) 				# fourth

jr 	$ra

# |-----------------------------------------------------------------------------------------------|

# |-----------------------------------| Function: Respawn |---------------------------------------|
 
# Arguments: 		$a0: none
# Return value: 	$v0: none

Respawn:
lw 	$t0, livesRemaining 			# livesRemaining is expected to be updated

lw 	$t1, frogStartPosX 			# Load the starting x-pos of frog in $t1
sw	$t1, frogPosX 				# Reset x-pos of frog
lw 	$t2, frogStartPosY			# Load the starting y-pos of frog in $t2
sw 	$t2, frogPosY 				# Reset y-pos of frog

jr 	$ra

# |-----------------------------------------------------------------------------------------------|

# |-------------------------------| Function: CheckCollision |------------------------------------|
 
# Arguments: 		$a0: Memory of object in which collision is checked
# 			$a1: The value of the object that is considered a (fatal) collision
# 			$a2: The row in which the object is located (unit is frog-height)
# Return value: 	$v0: Whether there is collision

CheckCollision:
lw 	$t0, frogPosY 				# Load y-pos of frog to $t0
bne 	$t0, $a2, CollisionNotDetected 		# Not even in the same row

lw 	$t0, frogPosX 				# Load x-pos of frog (left side) to $t0
add 	$t1, $a0, $t0				# Address of frog w.r.t. object
lw 	$t2, 0($t1) 				# Check content of this address
beq 	$t2, $a1, CollisionDetected 		# There is a collision

addi 	$t0, $t0, 12 				# Change $t0 to the right side of the frog
add 	$t1, $a0, $t0				# Address of frog w.r.t. object
lw 	$t2, 0($t1) 				# Check content of this address
beq 	$t2, $a1, CollisionDetected 		# There is a collision

j 	CollisionNotDetected 			# No collision for both left and right sides of the frog

CollisionDetected:
li 	$v0, 1 					# Collision
jr 	$ra 					# Return 1

CollisionNotDetected:
li 	$v0, 0 					# No collision
jr 	$ra					# Return 0

# |-----------------------------------------------------------------------------------------------|

# |------------------------------| Function: MoveFrogWithLog |------------------------------------|
 
# Arguments: 		none
# Return value: 	$v0: whether frog is moved out of bound

MoveFrogWithLog:
lw 	$t0, frogPosX 				# Load the x-pos of the frog into $t0
lw 	$t1, frogPosY 				# Load the y-pos of the frog into $t1
beq 	$t1, 2, MoveFrogLeftWithLog		# Frog on top log, move left
beq 	$t1, 3, MoveFrogRightWithLog		# Frog on bottom log, move right

FrogNotOutOfBound:
li 	$v0, 0 					# Return 0
jr 	$ra

MoveFrogLeftWithLog:
beq 	$t0, 0, FrogOutOfBound			# Check whether frog is on the left edge
subi 	$t0, $t0, 4 				# Subtract frog x-pos by 4 (bytes)
sw 	$t0, frogPosX 				# Update frog x-pos
j 	FrogNotOutOfBound

MoveFrogRightWithLog:
beq 	$t0, 112, FrogOutOfBound 		# Check whether frog is on the right edge
addi 	$t0, $t0, 4 				# Add frog x-pos by 4 (bytes)
sw 	$t0, frogPosX 				# Update frog x-pos
j 	FrogNotOutOfBound

FrogOutOfBound:
li 	$v0, 1 					# Return 1
jr 	$ra

# |-----------------------------------------------------------------------------------------------|

# |---------------------------------| Function: CheckWin |----------------------------------------|
 
# Arguments: 		none
# Return value: 	$v0: 1 if player won, 0 if player did not win, -1 if player lost

CheckWin:
lw 	$t0, frogPosY 				# Store the y-pos of the frog in $t0
lw 	$t1, frogPosX 				# Store the x-pos of the frog in $t1
bne 	$t0, 1, CheckWinFails 			# Frog not on row 1, did not win
blt 	$t1, 48, CheckWinLoses 			# Frog is to the left of goal region, which is a fatal region
bgt 	$t1, 64, CheckWinLoses 			# Frog is to the right of goal region, which is a fatal region

li 	$v0, 1					# Else the player wins!
jr 	$ra					# Return 1

CheckWinFails:
li 	$v0, 0 					# Return 0
jr 	$ra 

CheckWinLoses:
li 	$v0, -1 				# Return -1
jr 	$ra

# |-----------------------------------------------------------------------------------------------|













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
# Milestone reached: 1b
# 
# Additional features implemented:
# - None
#
###################################################################################################

.data
displayAddress: 	.word 0x10008000

frogColour: 		.word 0x69db41

safeRegionColour: 	.word 0x8b1ad6
goalRegionColour: 	.word 0x4ea333
roadColour: 		.word 0x808080
waterColour:		.word 0x000044

logColour: 		.word 0xcf6f50
vehicleColour: 		.word 0x000000
	
.text

jal 	DrawBackground

lw 	$s0, displayAddress 		# Set $s0 to hold displayAddress		

addi 	$a0, $s0, 1056			# Top water row, 1/4 position
addi	$a1, $zero, 8 			# Length of log is 8
jal 	DrawLog			

addi 	$a0, $s0, 1120			# Top water row, 3/4 position
addi	$a1, $zero, 8 			# Length of log is 8
jal 	DrawLog				

addi 	$a0, $s0, 1536			# Bot water row, leftmost position
addi	$a1, $zero, 8 			# Length of log is 8
jal 	DrawLog				

addi 	$a0, $s0, 1600			# Bot water row, centre position
addi	$a1, $zero, 8 			# Length of log is 8
jal 	DrawLog 			

addi 	$a0, $s0, 2560 			# Top road row, leftmost position
addi 	$a1, $zero, 8 			# Length of vehicle is 8
jal 	DrawVehicle 		

addi 	$a0, $s0, 2624 			# Top road row, centre position
addi 	$a1, $zero, 8 			# Length of vehicle is 8
jal 	DrawVehicle 		

addi 	$a0, $s0, 3104 			# Bot road row, 1/4 position
addi 	$a1, $zero, 8 			# Length of vehicle is 4
jal 	DrawVehicle 	

addi 	$a0, $s0, 3168 			# Bot road row, 3/4 position
addi 	$a1, $zero, 8 			# Length of vehicle is 4
jal 	DrawVehicle 		

addi 	$a0, $s0, 3632			# Draw frog in start region
jal 	DrawFrog 	

Exit:
li $v0, 10
syscall

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
				
DrawWater:
beq 	$t1, 2048, DrawWaterEnd 	# while ($t1 != 2048) {
add 	$t3, $t0, $t1			#	$t3 = $t0 + $t1;	
sw 	$t2, 0($t3)			# 	*($t3) = $t2;
addi 	$t1, $t1, 4			# 	$t1 += 4;
j 	DrawWater			# }

DrawWaterEnd:				# $t1 == 2048 at this point

lw 	$t2, safeRegionColour 		# $t2 = safeRegionColour;

DrawSafeRegion:
beq 	$t1, 2560, DrawSafeRegionEnd 	# while ($t1 != 2560) {
add 	$t3, $t0, $t1			#	$t3 = $t0 + $t1;	
sw 	$t2, 0($t3)			# 	*($t3) = $t2;
addi 	$t1, $t1, 4			# 	$t1 += 4;
j 	DrawSafeRegion			# }

DrawSafeRegionEnd:			# $t1 == 2560 at this point

lw 	$t2, roadColour 		# $t2 = roadColour;

DrawRoad:
beq 	$t1, 3584, DrawRoadEnd 		# while ($t1 != 3584) {
add 	$t3, $t0, $t1			#	$t3 = $t0 + $t1;	
sw 	$t2, 0($t3)			# 	*($t3) = $t2;
addi 	$t1, $t1, 4			# 	$t1 += 4;
j 	DrawRoad			# }

DrawRoadEnd:				# $t1 = 3584 at this point

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


# |--------------------------| Function: DrawLog |------------------------------------------------|

# Arguments: 		$a0: memory location of the upper-left corner of the log
#			$a1: length of the log in pixels
# Return values:	none

DrawLog:
add 	$t0, $a0, $zero 		# $t0 = $a0;
lw 	$t1, logColour			# $t1 = logColour;
add 	$t2, $zero, $zero 		# $t2 = 0;  // inner loop pixel counter
add 	$t3, $zero, $zero 		# $t3 = 0;  // outer loop loop variable
add 	$t4, $zero, $zero 		# $t4 = 0;  // increment to row number by address

DrawLogMultiRow: 			# for ($t3 = 0; $t3 < 4; ++$t3) {
beq 	$t3, 4, DrawLogMultiRowEnd	# 	breaks loop when $t3 == 4

DrawLogRow:
beq 	$t2, $a1, DrawLogRowEnd 	# 	while ($t2 != $a1) {
sw 	$t1, 0($t0) 			# 		*($t0) = $t1;  // draw
addi 	$t0, $t0, 4 			# 		$t0 += 4;  // increment pointer to display
addi 	$t2, $t2, 1 			# 		++$t2;  // increment loop variable
j	DrawLogRow			# 	}

DrawLogRowEnd:

addi 	$t4, $t4, 128 			# 	$t4 += 128;
add 	$t0, $a0, $t4 			# 	$t0 = $a0 + $t4;  // next row
add 	$t2, $zero, $zero 		# 	$t2 = 0;
addi 	$t3, $t3, 1 			# 	increment $t3 in each iteration

j DrawLogMultiRow			# }

DrawLogMultiRowEnd:
jr 	$ra

# |-----------------------------------------------------------------------------------------------|

# |--------------------------| Function: DrawVehicle |--------------------------------------------|

# Arguments: 		$a0: memory location of the upper-left corner of the vehicle
#			$a1: length of the vehicle in pixels
# Return values:	none

DrawVehicle:
add 	$t0, $a0, $zero 		# $t0 = $a0;
lw 	$t1, vehicleColour		# $t1 = vehicleColour;
add 	$t2, $zero, $zero 		# $t2 = 0;  // inner loop pixel counter
add 	$t3, $zero, $zero 		# $t3 = 0;  // outer loop loop variable
add 	$t4, $zero, $zero 		# $t4 = 0;  // increment to row number by address

DrawVehicleMultiRow: 			# for ($t3 = 0; $t3 < 4; ++$t3) {
beq 	$t3, 4, DrawVehicleMultiRowEnd	# 	breaks loop when $t3 == 4

DrawVehicleRow:
beq 	$t2, $a1, DrawVehicleRowEnd 	# 	while ($t2 != $a1) {
sw 	$t1, 0($t0) 			# 		*($t0) = $t1;  // draw
addi 	$t0, $t0, 4 			# 		$t0 += 4;  // increment pointer to display
addi 	$t2, $t2, 1 			# 		++$t2;  // increment loop variable
j	DrawVehicleRow			# 	}

DrawVehicleRowEnd:

addi 	$t4, $t4, 128 			# 	$t4 += 128;
add 	$t0, $a0, $t4 			# 	$t0 = $a0 + $t4;  // next row
add 	$t2, $zero, $zero 		# 	$t2 = 0;
addi 	$t3, $t3, 1 			# 	increment $t3 in each iteration

j DrawVehicleMultiRow			# }

DrawVehicleMultiRowEnd:
jr 	$ra

# |-----------------------------------------------------------------------------------------------|

# |-----------------------------| Function: DrawFrog |--------------------------------------------|

# Arguments: 		$a0: memory location of the upper-left corner of the frog
# Return values:	none

DrawFrog:
add 	$t0, $a0, $zero 		# $t0 = $a0;
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




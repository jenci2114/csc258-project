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
# Milestone reached: 1a
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

addi 	$a0, $s0, 512			# $a0 = $s0 + 512
addi	$a1, $zero, 8 			# $a1 = 8
jal 	DrawLog 			# row 1 log 1

addi 	$a0, $s0, 576			# $a0 = $s0 + 576
addi	$a1, $zero, 8 			# $a1 = 8
jal 	DrawLog				# row 1 log 2

addi 	$a0, $s0, 1056			# $a0 = $s0 + 1056
addi	$a1, $zero, 8 			# $a1 = 8
jal 	DrawLog				# row 2 log 1

addi 	$a0, $s0, 1120			# $a0 = $s0 + 1120
addi	$a1, $zero, 8 			# $a1 = 8
jal 	DrawLog				# row 2 log 2

addi 	$a0, $s0, 1536			# $a0 = $s0 + 1536
addi	$a1, $zero, 8 			# $a1 = 8
jal 	DrawLog				# row 3 log 1

addi 	$a0, $s0, 1600			# $a0 = $s0 + 1600
addi	$a1, $zero, 8 			# $a1 = 8
jal 	DrawLog 			# row 3 log 2


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
beq 	$t1, 512, DrawGoalRegionEnd 	# while ($t1 != 512) {
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
sw 	$t1, 0($t0) 			# 		*($t0) = $t1;
addi 	$t0, $t0, 4 			# 		$t0 += 4;
addi 	$t2, $t2, 1 			# 		++$t2;
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




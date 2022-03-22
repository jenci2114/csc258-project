###########################################################
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
# Milestone reached: 0
# 
# Additional features implemented:
# - None
#
###########################################################

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

lw $t0, displayAddress 			# $t0 = displayAddress;
li $t1, 0 				# $t1 = 0;
lw $t2, goalRegionColour		# $t2 = goalRegionColour;

DrawGoalRegion:
beq $t1, 512, DrawGoalRegionEnd 	# while ($t1 != 512) {
add $t3, $t0, $t1			#	$t3 = $t0 + $t1	
sw $t2, 0($t3)				# 	*($t3) = $t2;
addi $t1, $t1, 4			# 	$t1 += 4;
j DrawGoalRegion			# }

DrawGoalRegionEnd:			# $t1 == 512 at this point

lw $t2, waterColour			# $t2 = waterColour
				
DrawWater:
beq $t1, 2048, DrawWaterEnd 		# while ($t1 != 2048) {
add $t3, $t0, $t1			#	$t3 = $t0 + $t1	
sw $t2, 0($t3)				# 	*($t3) = $t2;
addi $t1, $t1, 4			# 	$t1 += 4;
j DrawWater				# }

DrawWaterEnd:				# $t1 == 2048 at this point

lw $t2, safeRegionColour 		# $t2 = safeRegionColour

DrawSafeRegion:
beq $t1, 2560, DrawSafeRegionEnd 	# while ($t1 != 2560) {
add $t3, $t0, $t1			#	$t3 = $t0 + $t1	
sw $t2, 0($t3)				# 	*($t3) = $t2;
addi $t1, $t1, 4			# 	$t1 += 4;
j DrawSafeRegion			# }

DrawSafeRegionEnd:			# $t1 == 2560 at this point

lw $t2, roadColour 			# $t2 = roadColour

DrawRoad:
beq $t1, 3584, DrawRoadEnd 		# while ($t1 != 3584) {
add $t3, $t0, $t1			#	$t3 = $t0 + $t1	
sw $t2, 0($t3)				# 	*($t3) = $t2;
addi $t1, $t1, 4			# 	$t1 += 4;
j DrawRoad				# }

DrawRoadEnd:				# $t1 = 3584 at this point

lw $t2, safeRegionColour 		# $t2 = safeRegionColour

DrawStartRegion:
beq $t1, 4096, DrawStartRegionEnd 	# while ($t1 != 4096) {
add $t3, $t0, $t1			#	$t3 = $t0 + $t1	
sw $t2, 0($t3)				# 	*($t3) = $t2;
addi $t1, $t1, 4			# 	$t1 += 4;
j DrawStartRegion				# }

DrawStartRegionEnd:			# $t1 = 3584 at this point

Exit:
li $v0, 10
syscall




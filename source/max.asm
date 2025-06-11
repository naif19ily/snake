#                  _        
#  ___ _ __   __ _| | _____ 
# / __| '_ \ / _` | |/ / _ \
# \__ \ | | | (_| |   <  __/
# |___/_| |_|\__,_|_|\_\___|
#
# Contains the ASCII art string to tell the player reached the max score.
#

.section .rodata

	.s1: .string "\x1b[5m.--------.---.-.--.--.   .-----.----.-----.----.-----|  |\n"
	.s2: .string "|        |  _  |_   _|   |__ --|  __|  _  |   _|  -__|__|\n"
	.s3: .string "|__|__|__|___._|__.__|   |_____|____|_____|__| |_____|__|\n\x1b[0m"

 	MaxScore:
		.quad	.s1
		.quad	.s2
		.quad	.s3
	
	.globl MaxScore

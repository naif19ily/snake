#                  _        
#  ___ _ __   __ _| | _____ 
# / __| '_ \ / _` | |/ / _ \
# \__ \ | | | (_| |   <  __/
# |___/_| |_|\__,_|_|\_\___|
#
# Contains the ASCII art string to tell the player just died.
#

.section .rodata
	.s1: .string "\x1b[5m _______                              _______                      _ _\n"
	.s2: .string "|     __|.---.-..--------..-----.    |       |.--.--..-----..----.|  |\n"
	.s3: .string "|    |  ||  _  ||        ||  -__|    |   -   ||  |  ||  -__||   _||__|\n"
	.s4: .string "|_______||___._||__|__|__||_____|    |_______| \\___/ |_____||__|  |__|\n\x1b[0m"

	GameOver:
		.quad	.s1
		.quad	.s2
		.quad	.s3
		.quad	.s4

	Gfmt: .string "\x1b[%d;%dH%s"

	.globl GameOver
	.globl Gfmt

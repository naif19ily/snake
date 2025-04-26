.section .data

.section .rodata
        # ~~~~~~~~~~~~~~~~~~~~~~~ min window dimenions ~~~~~
	minocols: .word 102                                #
	minorows: .word 52                                 #
	.globl minorows                                    #
	.globl minocols                                    #
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        # ~~~~~~~~~~~~~~~~~~~~~~~ frame bounds ~~~~~~~~~~~~~
        framewidth:  .word 100                             #
        frameheight: .word 50                              #
        .globl framewidth                                  #
        .globl frameheight                                 #
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        # ~~~~~~~~~~~~~~~~~~~~~~~ ansi scape codes ~~~~~~~~~
        fp_init_game: .string "\x1b[H\x1b[2J\x1b[?25l"     #
        fp_fini_game: .string "\x1b[H\x1b[2J\x1b[?25h"     #
        .globl fp_init_game                                #
        .globl fp_fini_game                                #
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        frame_b0: .string "+----------------------------------------------------------------------------------------------------+\n"
        frame_b1: .string "|                                                                                                    |\n"
        .globl frame_b0
        .globl frame_b1



.section .bss
	# unsigned short ws_row
	# unsigned short ws_col
	# unsigned short ws_xpixel
	# unsigned short ws_ypixel
	.lcomm winsize, 8
	.globl winsize

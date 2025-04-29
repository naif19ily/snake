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
        fp_display:   .string "\x1b[%d;%dH%c"              # 
        .globl fp_init_game                                #
        .globl fp_fini_game                                #
        .globl fp_display                                  #
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        # ~~~~~~~~~~~~~~~~~~~~~~~ snake maximum length ~~~~#
        snake_max_len: .word 100                           #
        .globl snake_max_len                               #
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

        # ~~~~~~~~~~~~~~~~~~~~~~~ snake maximum length ~~~~#
        snake_chunk_size: .quad 4                          #
        .globl snake_chunk_size                            #
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

        # ~~~~~~~~~~~~~~~~~~~~~~~ delay settings ~~~~~~~~~~#
	timespec:                                          #
		.quad 0                                    #
		.quad 50000000                             #
        .globl timespec                                    #
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

        frame_b0: .string "+----------------------------------------------------------------------------------------------------+\n"
        frame_b1: .string "|                                                                                                    |\n"
        .globl frame_b0
        .globl frame_b1

	util_length: .string "\x1b[56;2Hlength: %d\n"
	.globl util_length

	util_coords: .string "\x1b[55;2Hcoords: %d %d\n"
	.globl util_coords

.section .bss
        # ~~~~~~~~~~~~~~~~~~~~~~~ winsize structre ~~~~~~~~#
	# unsigned short ws_row                            #
	# unsigned short ws_col                            #
	# unsigned short ws_xpixel                         #
	# unsigned short ws_ypixel                         #
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	.lcomm winsize, 8
	.globl winsize

        # ~~~~~~~~~~~~~~~~~~~~~~~ termios structure ~~~~~~~#
	# tcflag_t c_iflag                                 #
	# tcflag_t c_oflag                                 #
	# tcflag_t c_cflag                                 #
	# tcflag_t c_lflag                                 #
	# cc_t     c_cc[NCCS]                              #
	# int      c_ispeed                                #
	# int      c_ospeed                                #
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
        .lcomm termios, 60
        .globl termios

        # ~~~~~~~~~~~~~~~~~~~~~~~ snake chunk structure ~~~#
        # short x                                          #
        # short y                                          #
        .lcomm snake, 4 * 100                              #
        .globl snake                                       #
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

        # ~~~~~~~~~~~~~~~~~~~~~~~ food spawn structure ~~~~#
        # short x                                          #
        # short y                                          #
        # bool  eaten                                      #
        .lcomm food, 6                                     #
        .globl food                                        #
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

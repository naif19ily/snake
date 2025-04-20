.section .rodata

        #
        # Constants
        #
	SCREEN_WIDTH:  .word 102
	SCREEN_HEIGHT: .word 102

	.globl	SCREEN_WIDTH
	.globl	SCREEN_HEIGHT

        SNAKE_MAX_LEN: .quad 40
        .globl SNAKE_MAX_LEN


        #
        # Error messages
        #
        ERR_MSG_SMALL_WIN: .string "\n  snake: your window is too small to play\n\n"
        ERR_LEN_SMALL_WIN: .quad   44

        .globl ERR_MSG_SMALL_WIN
        .globl ERR_LEN_SMALL_WIN

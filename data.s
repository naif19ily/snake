.section .rodata

        #
        # Constants
        #
	SCREEN_WIDTH:  .word 100
	SCREEN_HEIGHT: .word 100

	.globl	SCREEN_WIDTH
	.globl	SCREEN_HEIGHT

        #
        # Error messages
        #
        ERR_MSG_SMALL_WIN: .string "\n  snake: your window is too small to play\n\n"
        ERR_LEN_SMALL_WIN: .quad   44

        .globl ERR_MSG_SMALL_WIN
        .globl ERR_LEN_SMALL_WIN


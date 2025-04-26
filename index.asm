.section .rodata
	#
	# Refer to the total amount of lines and columns
	# the game is going to use
	#
	.ROWS_USED: .word 52
	.COLS_USED: .word 102

	#
	# Snake related
	#
	.SNAKE_MAX_LEN: .word 30
	.SNAKE_PORTION_SIZE: .word 8

	#
	# Refer to the number of rows and columns
	# the snake has available to go through
	#
	.Y_MAX: .word 50
	.X_MAX: .word 100

	#
	# ANSI scape codes
	#
	.ansi_start_game:     .string "\x1b[H\x1b[2J\x1b[?25l"
	.ansi_end_game:       .string "\x1b[H\x1b[2J\x1b[?25h"
	.ansi_snake_is_here:  .string "\x1b[%d;%dH*"
	.ansi_snake_was_here: .string "\x1b[%d;%dH "

	#
	# Use to draw the game's frame
	#
	.board_up_bottom:  .string "+----------------------------------------------------------------------------------------------------+\n"
	.board_sides:      .string "|                                                                                                    |\n"

	#
	# Error message: current window size is too small to play
	#
	.small_window_msg: .string "\n  snake: window is too small\n\n"
	.small_window_len: .quad   31

	#
	# timespec struct to handle time, this is constant
	# since the snake moves at the same speed throughout the game
	#
	.timespec:
		.quad  0
		.quad  40000000

.section .bss
	# struct winsize {
	#   unsigned short ws_row;
	#   unsigned short ws_col;
	#   unsigned short ws_xpixel;
	#   unsigned short ws_ypixel;
	# };
	.lcomm .termsz, 8

	# struct termios {
	#   tcflag_t   c_iflag;
	#   tcflag_t   c_oflag;
	#   tcflag_t   c_cflag;
	#   tcflag_t   c_lflag;
	#   cc_t       c_cc[NCCS];
	#   int        c_ispeed;
	#   int        c_opssed;
	# }
	.lcomm .termiosettings, 60

	# struct {
	#   unsigned short x, y;
	#   unsigned short prevx, prevy;
	# } snake[SNAKE_MAX_LENGTH];
	.lcomm .snake, 30 * 8

	#
	# Input buffer, only one byte is needed
	#
	.lcomm .input, 1

.section .text

.macro EXIT a
	movq	\a, %rdi
	movq	$60, %rax
	syscall
.endm

.macro BPRINTF a, b
	movq	\b, %rsi
	leaq	\a, %rdi
	call	fpx86
.endm

.macro ERRMSG a, b
	movq	\a, %rsi
	movq	\b, %rdx
	movq	$2, %rdi
	movq	$1, %rax
	syscall
.endm

.macro  SNAKE_IS_HERE
        xorq    %rax, %rax
        #
        # Getting x-coord
        #
        movw    (%r15), %ax
        addw    $2, %ax
        movw    %ax, 4(%r15)
        pushq   %rax
        #
        # Getting y-coord
        #
        movw    2(%r15), %ax
        addw    $2, %ax
        movw    %ax, 6(%r15)
        pushq   %rax
        #
        # Printing
        #
        leaq    .ansi_snake_is_here(%rip), %rdi
        movq    $1, %rsi
        call    fpx86
        popq    %rax
        popq    %rax
.endm

.macro  SNAKE_WAS_HERE
        xorq    %rax, %rax
        #
        # Getting x-coord
        #
        movw    4(%r15), %ax
        pushq   %rax
        #
        # Getting x-coord
        #
        movw    6(%r15), %ax
        pushq   %rax
        #
        # Printing
        #
        leaq    .ansi_snake_was_here(%rip), %rdi
        movq    $1, %rsi
        call    fpx86
        popq    %rax
        popq    %rax
.endm

.globl _start

_start:
	pushq	%rbp
	movq	%rsp, %rbp
        subq    $32, %rsp
	#
	# Stack distribution
	#  -2(%rbp):      snake's length
	#  -6(%rbp):      default fd configuration
	#  -14(%rbp):     last label visited
	#
	movw	$1, -2(%rbp)
	movl	$0, -6(%rbp)
	#
	# Snake starts going downwards 'snake_down'
	#
	leaq	.snake_down(%rip), %rax
	movq	%rax, -14(%rbp)
	#
	# Getting terminal dimensions
	#
	movq	$16, %rax
	movq	$0, %rdi
	movq	$21523, %rsi
	movq	$.termsz, %rdx
	syscall
	#
	# Making sure terminal dimensions are big enough
	#
	movw	(.termsz), %ax
	cmpw	.ROWS_USED(%rip), %ax
	jb	.fatal_small_window
	movw	(.termsz + 2), %ax
	cmpw	.COLS_USED(%rip), %ax
	jb	.fatal_small_window
	#
	# Drawing game's frame
	#
	BPRINTF	.ansi_start_game(%rip), $1
	BPRINTF	.board_up_bottom(%rip), $1
	movw	$0, %r15w

.frame_loop:
	cmpw	.Y_MAX(%rip), %r15w
	je	.finish_game_set_up
	BPRINTF	.board_sides(%rip), $1
	incw	%r15w
	jmp	.frame_loop

.finish_game_set_up:
	BPRINTF	.board_up_bottom(%rip), $1
	#
	# Getting default terminal settings
	#
	movq	$16, %rax
	movq	$0, %rdi
	movq	$21505, %rsi
	movq	$.termiosettings, %rdx
	syscall
	#
	# Setting no canonical mode
	#
	andw	$-11, (.termiosettings + 12)
	movq	$16, %rax
	movq	$0, %rdi
	movq	$21506, %rsi
	movq	$.termiosettings, %rdx
	syscall
	#
	# Allowing the program to keep executing instructions
	# even if no input has given (snake must keep moving)
	# 
	andw	$72, %ax
	movq	$0, %rdi
	movq	$0, %rsi
	movq	$0, %rdx
	syscall
	movl	%eax, -6(%rbp)
	orl	$2048, %eax
	cltq
	movq	%rax, %rdx
	movq	$72, %rax
	movq	$0, %rdi
	movq	$4, %rsi
	syscall
        #
        # Snake's head is stored into r15
        #
	leaq	.snake(%rip), %r15
        #
        # Printing snake's head
        #
        SNAKE_IS_HERE
.game:
	movq	$0, %rax
	movq	$0, %rdi
	movq	$.input, %rsi
	movq	$1, %rdx
	syscall
	movb	(.input), %al
	#
	# Leave the game (the correct way) by pressing 'q'
	#
	cmpb	$'q', %al
	je	.end_game
        cmpb    $'w', %al
        je      .snake_up
        cmpb    $'a', %al
        je      .snake_left
        cmpb    $'s', %al
        je      .snake_down
        cmpb    $'d', %al
        je      .snake_right
        movq    -14(%rbp), %rax
	jmp	*%rax

.snake_down:
        movw    2(%r15), %ax
        cmpw    .Y_MAX(%rip), %ax
        je      .game_over
        incw    2(%r15)
        jmp     .continue
.snake_up:
        movw    2(%r15), %ax
        cmpw    $-1, %ax
        je      .game_over
        decw    2(%r15)
        jmp     .continue
.snake_left:
        movw    0(%r15), %ax
        cmpw    $-1, %ax
        je      .game_over
        decw    0(%r15)
        jmp     .continue
.snake_right:
        movw    0(%r15), %ax
        cmpw    .X_MAX(%rip), %ax
        je      .game_over
        movw    2(%r15), %ax
        incw    0(%r15)
        jmp     .continue
.continue:
        #
        # Adding delay
        #
        leaq    .timespec(%rip), %rdi
        movq    $0, %rsi
        movq    $35, %rax
        syscall
        movw    -2(%rbp), %di
        call    .__make_snake_move_0
        jmp     .game

.game_over:

.end_game:
	#
	# Setting default fd back again
	#
	movl	-6(%rbp), %eax
	cltq
	movq	%rax, %rdx
	movq	$72, %rax
	movq	$0, %rdi
	movq	$4, %rsi
	syscall
	#
	# Setting default terminal conf
	#
	orw	$10, (.termiosettings + 12)
	movq	$16, %rax
	movq	$0, %rdi
	movq	$21506, %rsi
	movq	$.termiosettings, %rdx
	syscall
	BPRINTF	.ansi_end_game(%rip), $1
	EXIT	$0

.__make_snake_move_0:
        pushq   %rbp
        movq    %rsp, %rbp
        subq    $4, %rsp
        movw    %di, -2(%rbp)
        movw    $0, -4(%rbp)
.__0_chunk_loop:
        movw    -4(%rbp), %ax
        cmpw    %ax, -2(%rbp)
        je      .__0_fini
        SNAKE_WAS_HERE
        SNAKE_IS_HERE
        movq    .SNAKE_PORTION_SIZE(%rip), %rax
        addq    %rax, %r15
        incw    -4(%rbp)
        jmp     .__0_chunk_loop
.__0_fini:
        #
        # Put snake's head back into r15
        #
        leaq    .snake(%rip), %r15
        leave
        ret

.fatal_small_window:
	ERRMSG .small_window_msg(%rip), .small_window_len(%rip)
	EXIT	$-1

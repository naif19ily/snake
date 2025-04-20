.section .rodata
	#
	# +----------------------+
	# +                      + *
	# +                      +  |_ rows starts here * and
	# +                      +  |  ends there %
	# +                      + %
	# +----------------------+
	#  |____________________|
	#   this are the columns
	#
	BOARD_ROWS: .word 50
	BOARD_COLS: .word 100

	SNAKE_MAX_LEN: .word 30
	SNAKE_PART_SIZE: .quad 8

	#
	# Ansi scape codes before running the game
	# and after running the game
	#
	ansi_init_screen: .string "\x1b[H\x1b[2J\x1b[?25l"
	ansi_term_screen: .string "\x1b[H\x1b[2J\x1b[?25h"
	ansi_print_body:  .string "\x1b[%d;%dH#"
	ansi_print_space: .string "\x1b[%d;%dH "

	board_up_bottom:  .string "+----------------------------------------------------------------------------------------------------+\n"
	board_sides:      .string "+                                                                                                    +\n"

	smallwindow_msg: .string "\n  snake: window too small\n\n"
	smallwindow_len: .quad   28

	w: .string "w\n"
	a: .string "a\n"
	s: .string "s\n"
	d: .string "d\n"

	timespec:
		.quad	1
		.quad	500000000


.section .bss
	# struct winsize {
	#   unsigned short ws_row;
	#   unsigned short ws_col;
	#   unsigned short ws_xpixel;
	#   unsigned short ws_ypixel;
	# };
	.lcomm	WinStruct, 8

	# struct termios {
	#   tcflag_t	c_iflag;
	#   tcflag_t	c_oflag;
	#   tcflag_t	c_cflag;
	#   tcflag_t	c_lflag;
	#   cc_t	c_cc[NCCS];
	#   int		c_ispeed;
	#   int		c_ospeed;
	# };
	.lcomm	Termiostruct, 60

	# struct {
	#   unsigned short x, y;
	#   unsigned short px, py;
	# } SnakeBody[SNAKE_MAX_LEN];
	.lcomm	SnakeBody, 30 * 8

	#
	# Input buffer
	#
	.lcomm	Input, 1

.section .text

.macro EXIT a
	movq	\a, %rdi
	movq	$60, %rax
	syscall
.endm

.macro	DO_SIMPLE_FP, a
	leaq	\a, %rdi
	movq	$1, %rsi
	call	fpx86
.endm

.macro ERRMSG a, b
	movq	\b, %rdx
	leaq	\a, %rsi
	movq	$2, %rdi
	movq	$1, %rax
	syscall
.endm

.globl _start

_start:	
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$32, %rsp
	#
	# Stack distribution
	#
	#  -2(%rbp):	snake length
	# -10(%rbp):    standard flag fd conf
	# -18(%rbp):	last label visited while moving
	#
	movw	$1, -2(%rbp)
	leaq	.go_down(%rip), %rax
	movq	%rax, -18(%rbp)
	#
	# Getting current terminal dimensions.
	#
	movq	$16, %rax
	movq	$0, %rdi
	movq	$21523, %rsi
	movq	$WinStruct, %rdx
	syscall
	#
	# Making sure terminal dimensions are enough
	#
	movw	(WinStruct), %ax
	cmpw	BOARD_ROWS(%rip), %ax
	jbe	.err_small_windown
	movw	(WinStruct + 2), %ax
	cmpw	BOARD_COLS(%rip), %ax
	jbe	.err_small_windown
	#
	# Drawing the board edges.
	#
	DO_SIMPLE_FP ansi_init_screen(%rip)
	DO_SIMPLE_FP board_up_bottom(%rip)
	movw	$0, %r15w

.board_drawing_loop:
	cmpw	BOARD_ROWS(%rip), %r15w
	je	.finish_set_up
	DO_SIMPLE_FP board_sides(%rip)
	incw	%r15w
	jmp	.board_drawing_loop

.finish_set_up:
	#
	# Getting terminal default settings
	#
	movq	$16, %rax
	movq	$0, %rdi
	movq	$21505, %rsi
	movq	$Termiostruct, %rdx
	syscall
	#
	# Setting nocanonical mode
	#
	andw	$-11, (Termiostruct + 12)
	movq	$16, %rax
	movq	$0, %rdi
	movq	$21506, %rsi
	movq	$Termiostruct, %rdx
	syscall
	#
	# If we want the snake keep moving even if no
	# key is pressed we need to make STDIN non-blocking
	#
	movq	$72, %rax
	movq	$0, %rdi
	movq	$3, %rsi
	movq	$0, %rdx
	syscall
	movl	%eax, -10(%rbp)
	orl	$2048, %eax
	cltq
	movq	%rax, %rdx
	movq	$72, %rax
	movq	$0, %rdi
	movq	$4, %rsi
	syscall
	#
	# Bottom edge of the bar
	#
	DO_SIMPLE_FP board_up_bottom(%rip)
	#
	# r15 contains the snake's head
	#
	leaq	SnakeBody(%rip), %r15

.game:
	movq	$0, %rax
	movq	$0, %rdi
	movq	$Input, %rsi
	movq	$1, %rdx
	syscall
	movb	(Input), %al
	cmpb	$0, %al
	jle	.repeat_motion
	cmpb	$'q', %al
	je	.end_program
	cmpb	$'w', %al
	je	.go_up
	cmpb	$'s', %al
	je	.go_down
	cmpb	$'a', %al
	je	.go_left
	cmpb	$'d', %al
	je	.go_right

.repeat_motion:
	movq	-18(%rbp), %rax
	jmp	*%rax

.go_down:
	leaq	.go_down(%rip), %rax
	movq	-18(%rbp), %rax
	DO_SIMPLE_FP s(%rip)
	jmp	.continue

.go_left:
	leaq	.go_left(%rip), %rax
	movq	-18(%rbp), %rax
	DO_SIMPLE_FP a(%rip)
	jmp	.continue

.go_up:
	leaq	.go_up(%rip), %rax
	movq	-18(%rbp), %rax
	DO_SIMPLE_FP w(%rip)
	jmp	.continue

.go_right:
	leaq	.go_right(%rip), %rax
	movq	-18(%rbp), %rax
	DO_SIMPLE_FP d(%rip)
	jmp	.continue

.continue:
	jmp	.game

.end_program:
	movl	-10(%rbp), %eax
	cltq
	movq	%rax, %rdx
	movq	$72, %rax
	movq	$0, %rdi
	movq	$4, %rsi
	syscall
	#
	# Setting default terminal settings back
	#
	orw	$10, (Termiostruct + 12)
	movq	$16, %rax
	movq	$0, %rdi
	movq	$21506, %rsi
	movq	$Termiostruct, %rdx
	syscall
	DO_SIMPLE_FP ansi_term_screen(%rip)
	EXIT	$0

.err_small_windown:
	ERRMSG	smallwindow_msg(%rip), smallwindow_len(%rip)
	EXIT	$-1





.section .rodata
	.cleanscreen: .string "\x1b[H\x1b[2J"

	.border1:     .string "+----------------------------------------------------------------------------------------------------+\n"
	.filling:     .string "|                                                                                                    |\n"

	.fmtmove:     .string "\x1b[%d;%dH#"


.section .bss
	# Space in memory to store winsize struct
	.lcomm .windowinfo, 8
	# Space for storing character pressed
	.lcomm .input, 1
	# Space for termios struct
	.lcomm .termstts, 60

.section .text

.macro EXIT a
    movq    \a, %rdi
    movq    $60, %rax
    syscall
.endm

.macro  ERROUT a, b
    leaq    \a, %rsi
    movq    \b, %rdx
    movq    $1, %rax
    movq    $2, %rdi
    syscall
.endm

.globl _start

_start:
	pushq	%rbp
	movq	%rsp, %rbp
	#
	# Stack distribution
	#
	#  -2(%rbp):	x position
	#  -4(%rbp):	y position
	#  -6(%rbp):	snake's length
	#
	#
	subq	$8, %rsp
	movw	$2, -2(%rbp)
	movw	$2, -4(%rbp)
	movw	$1, -6(%rbp)
	#
	# Getting windows size
	#
	movq	$16, %rax
	movq	$1, %rdi
	movq	$0x5413, %rsi
	movq	$.windowinfo, %rdx
	syscall
	#
	# Checking window is big enough
	#
	movw	(.windowinfo), %ax
	cmpw	SCREEN_HEIGHT(%rip), %ax
	jb	.error_win_small
 	movw	(.windowinfo + 2), %ax
 	cmpw	SCREEN_WIDTH(%rip), %ax
 	jb	.error_win_small
	#
	# Cleaning the screen
	#
	leaq	.cleanscreen(%rip), %rdi
	movq	$1, %rsi
	call	fpx86
	#
	# Printing board
	#
	leaq	.border1(%rip), %rdi
	movq	$1, %rsi
	call	fpx86
	movq	$2, %r15
.board_loop:
	cmpw	SCREEN_HEIGHT(%rip), %r15w
	leaq	.filling(%rip), %rdi
	je	.finishboard
	movq	$1, %rsi
	call	fpx86
	incq	%r15
	jmp	.board_loop
.finishboard:
	leaq	.border1(%rip), %rdi
	movq	$1, %rsi
	call	fpx86
	#
	# Getting terminal settings
	#
	movq	$16, %rax
	movq	$0, %rdi
	movq	$21505, %rsi
	movq	$.termstts, %rdx
	syscall
	#
	# Chamging conf
	# -11 comes from ~ICANON & ~ECHO
	#
	movw	(.termstts + 12), %ax
	andw	$-11, %ax
	movw	%ax, (.termstts + 12)
	#
	# Setting new terminal conf
	# termios struct definition: https://github.com/openbsd/src/blob/666a659208ae9191b22cd83518a9bb4a426358c7/sys/sys/termios.h#L194
	#
	movq	$16, %rax
	movq	$0, %rdi
	movq	$21506, %rsi
	movq	$.termstts, %rdx
	syscall
	#
	# Prints first position
	#
	pushq	$2
	pushq	$2
	leaq	.fmtmove(%rip), %rdi
	movq	$1, %rsi
	call	fpx86
	popq	%rax
	popq	%rax
.mainloop:
	movq	$0, %rax
	movq	$0, %rdi
	leaq	.input(%rip), %rsi
	movq	$1, %rdx
	syscall
	#
	# Leave the program if 'q' is pressed
	#
	movb	.input(%rip), %al
	cmpb	$'q', %al
	je	.c_fini
	#
	# Where do you wanna go?
	#
	cmpb	$'w', %al
	je	.move_up
	cmpb	$'s', %al
	je	.move_down
	cmpb	$'a', %al
	je	.move_left
	cmpb	$'d', %al
	je	.move_right
	jmp	.continue

.move_up:
.move_down:
.move_left:
.move_right:

.continue:
	jmp	.mainloop

.c_fini:
	#
	# Setting default configs back
	# 10 comes from ICANON | ECHO
	#
	orw	$10, (.termstts + 12)
	movq	$16, %rax
	movq	$0, %rdi
	movq	$21506, %rsi
	movq	$.termstts, %rdx
	syscall
	EXIT	$0

#  ________________
# < error messages >
#  ----------------
#         \   ^__^
#          \  (oo)\_______
#             (__)\       )\/\
#                 ||----w |
#                 ||     ||
.error_win_small:
	ERROUT	ERR_MSG_SMALL_WIN(%rip), ERR_LEN_SMALL_WIN(%rip)
	EXIT	$1

.section .rodata
	.clswindow: .string "\x1b[H\x1b[2J"
	.border1:   .string "+----------------------------------------------------------------------------------------------------+\n"
	.filling:   .string "|                                                                                                    |\n"

.section .bss
	.lcomm .windowinfo, 8
	.lcomm .input, 1
	.lcomm .termstts, 60

.section .text

.include "macros.inc"

.globl _start

_start:
	pushq	%rbp
	movq	%rsp, %rbp
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
	leaq	.clswindow(%rip), %rdi
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

.mainloop:
	movq	$0, %rax
	movq	$0, %rdi
	leaq	.input(%rip), %rsi
	movq	$1, %rdx
	syscall

	movb	.input(%rip), %al
	cmpb	$'q', %al
	je	.c_fini


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

	EXIT	$-1






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

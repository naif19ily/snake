.section .rodata
	.clswindow: .string "\x1b[H\x1b[2J"
	.border1:   .string "+----------------------------------------------------------------------------------------------------+\n"
	.filling:   .string "|                                                                                                    |\n"

.section .bss
	.lcomm windowinfo, 8

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
	movq	$windowinfo, %rdx
	syscall
	#
	# Checking window is big enough
	#
	movw	(windowinfo), %ax
	cmpw	SCREEN_HEIGHT(%rip), %ax
	jb	.error_win_small
 	movw	(windowinfo + 2), %ax
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
.filloop:
	cmpw	SCREEN_HEIGHT(%rip), %r15w
	leaq	.filling(%rip), %rdi
	je	.mainloop
	movq	$1, %rsi
	call	fpx86
	incq	%r15
	jmp	.filloop
.mainloop:
	leaq	.border1(%rip), %rdi
	movq	$1, %rsi
	call	fpx86
	#
	# Disable canon mode
	#

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

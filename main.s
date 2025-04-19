.section .bss
	.lcomm windowinfo, 8

.section .text

.include "macros.inc"

.globl _start

_start:
	pushq	%rbp
	movq	%rsp, %rbp

	movq	$16, %rax
	movq	$1, %rdi
	movq	$0x5413, %rsi
	movq	$windowinfo, %rdx
	syscall

	xorq	%rax, %rax

	movw	(windowinfo), %ax
	cmpw	SCREEN_HEIGHT(%rip), %ax
	jb	.error_win_small

 	movw	(windowinfo + 2), %ax
 	cmpw	SCREEN_WIDTH(%rip), %ax
 	jb	.error_win_small

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

#                  _        
#  ___ _ __   __ _| | _____ 
# / __| '_ \ / _` | |/ / _ \
# \__ \ | | | (_| |   <  __/
# |___/_| |_|\__,_|_|\_\___|

.section .rodata
	.PutChunk: .string "\x1b[%d;%dHS"
	.ClsChunk: .string "\x1b[%d;%dH "

.section .text

.macro PUTXY action, row, col
	pushq	\col
	pushq	\row
	leaq	\action, %rdi
	xorq	%rsi, %rsi
	movl	$1, %esi
	call	fp86
	addq	$16, %rsp
.endm

.globl _Loop

_Loop:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$8, %rsp

	PUTXY	.PutChunk(%rip), $3, $6

.toujour:
	movq	$0, %rax
	movq	$0, %rdi
	leaq	-2(%rbp), %rsi
	movq	$1, %rdx
	syscall

	cmpb	$'q', -2(%rbp)
	jz	.fini

	jmp	.toujour
.fini:
	leave
	ret

#                  _        
#  ___ _ __   __ _| | _____ 
# / __| '_ \ / _` | |/ / _ \
# \__ \ | | | (_| |   <  __/
# |___/_| |_|\__,_|_|\_\___|
#
# This file contains the function which parses numbers
# from strings
#

.section .text

.globl _getNumber

_getNumber:
	xorq	%rcx, %rcx
	xorq	%rax, %rax
	xorq	%rdx, %rdx
.loop:
	cmpq	$5, %rcx
	jz	fatal_huge_number
	movzbl	(%rdi), %ebx
	cmpb	$'0', %bl
	jl	.return
	cmpb	$'9', %bl
	jg	.return
	subb	$'0', %bl
	imulq	$10, %rax, %rax
	addq	%rbx, %rax
	incq	%rcx
	incq	%rdi
	jmp	.loop
.return:
	ret

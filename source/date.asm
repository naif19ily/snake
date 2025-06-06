#                  _        
#  ___ _ __   __ _| | _____ 
# / __| '_ \ / _` | |/ / _ \
# \__ \ | | | (_| |   <  __/
# |___/_| |_|\__,_|_|\_\___|
#
# This file handles dates
#

.section .bss
	Day: .zero 8
	Month: .zero 8
	Year: .zero 8

.section .text

.globl _getDate

_getDate:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$24, %rsp
	# Stack distribution
	#  -8: total amount of days sicne Jan 01 1970	(used to get other values)
	# -16: total amount of months since Jan 1970
	# -24: year
	movq	$201, %rax
	xorq	%rdi, %rdi
	syscall
	movq	%rax, %r8
	xorq	%rdx, %rdx
	movq	$86400, %rbx
	divq	%rbx
	movq	%rax, -8(%rbp)
	movq	%r8, %rax
	xorq	%rdx, %rdx
	movq	$2628000, %rbx
	divq	%rbx
	movq	%rax, -16(%rbp)
	movq	$1970, -24(%rbp)
	movq	-8(%rbp), %r8
.get_year_loop:
	cmpq	$365, %r8
	jl	.got_year
	movq	-24(%rbp), %rax
	xorq	%rdx, %rdx
	movq	$4, %rbx
	divq	%rbx
	cmpq	$0, %rdx
	jz	.is_366d
	subq	$365, %r8
	jmp	.year_resume
.is_366d:
	subq	$366, %r8
.year_resume:
	incq	-24(%rbp)
	jmp	.get_year_loop
.got_year:
	movq	$60, %rax
	movq	-24(%rbp), %rdi
	syscall

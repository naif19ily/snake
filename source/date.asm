#                  _        
#  ___ _ __   __ _| | _____ 
# / __| '_ \ / _` | |/ / _ \
# \__ \ | | | (_| |   <  __/
# |___/_| |_|\__,_|_|\_\___|
#
# This file handles dates
#

.section .bss
	ThisDay: .zero 8
	ThisMonth: .zero 8
	ThisYear: .zero 8

	.globl ThisDay
	.globl ThisMonth
	.globl ThisYear

.section .data
	.NoDays:
		.quad 31
		.quad 28
		.quad 31
		.quad 30
		.quad 31
		.quad 30
    		.quad 31
		.quad 31
		.quad 30
		.quad 31
		.quad 30
		.quad 31
	
.section .rodata
        .Jan: .string "Jan"
        .Feb: .string "Feb"
        .Mar: .string "Mar"
        .Apr: .string "Apr"
        .May: .string "May"
        .Jun: .string "Jun"
        .Jul: .string "Jul"
        .Aug: .string "Aug"
        .Sep: .string "Sep"
        .Oct: .string "Oct"
        .Nov: .string "Nov"
        .Dec: .string "Dec"

        Months:
                .quad .Jan
                .quad .Feb
                .quad .Mar
                .quad .Apr
                .quad .May
                .quad .Jun
                .quad .Jul
                .quad .Aug
                .quad .Sep
                .quad .Oct
                .quad .Nov
                .quad .Dec
        .globl Months

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
	# r8 will hold the ultimate value for the days
	movq	-8(%rbp), %r8
	movq	$1970, %r9
.get_month_loop:
	movq	%r9, %rax
	xorq	%rdx, %rdx
	movq	$4, %rbx
	divq	%rbx
	cmpq	$0, %rdx
	jz	.is_366
	movq	$365, %r10
	jmp	.month_resume
.is_366:
	movq	$366, %r10
.month_resume:
	cmpq	%r10, %r8
	jl	.got_month
	subq	$12, -16(%rbp)
	incq	%r9
	subq	%r10, %r8
	jmp	.get_month_loop
.got_month:
	incq	%r8
        movq    $0, %rcx
	leaq	.NoDays(%rip), %r9
	movq	-16(%rbp), %rax
	movq	%rax, (ThisMonth)
	movq	-24(%rbp), %rax
	movq	%rax, (ThisYear)
	xorq	%rdx, %rdx
	movq	-24(%rbp), %rax
	movq	$4, %rbx
	divq	%rbx
	cmpq	$0, %rdx
	jnz	.get_day
	incq	(.NoDays + 8)
.get_day:
	cmpq	-16(%rbp), %rcx
	jge	.fini
	movq	(%r9), %rax
	subq	%rax, %r8
	addq	$8, %r9
	incq	%rcx
	jmp	.get_day
.fini:
	movq	%r8, (ThisDay)
	leave
	ret

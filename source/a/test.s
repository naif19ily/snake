	.file	"test.c"
	.text
	.section	.rodata
.LC1:
	.string	"%ld\n"
.LC2:
	.string	"%ld year\n"
.LC3:
	.string	"%ld month\n"
.LC4:
	.string	"%ld days\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$64, %rsp
	movl	$0, %edi
	call	time@PLT
	movq	%rax, -24(%rbp)
	movq	-24(%rbp), %rcx
	movabsq	$1749024623285053783, %rdx
	movq	%rcx, %rax
	imulq	%rdx
	movq	%rdx, %rax
	sarq	$13, %rax
	sarq	$63, %rcx
	movq	%rcx, %rdx
	subq	%rdx, %rax
	movq	%rax, -16(%rbp)
	pxor	%xmm0, %xmm0
	cvtsi2sdq	-24(%rbp), %xmm0
	movsd	.LC0(%rip), %xmm1
	divsd	%xmm1, %xmm0
	cvttsd2siq	%xmm0, %rax
	movq	%rax, -64(%rbp)
	movq	-64(%rbp), %rax
	movq	%rax, %rsi
	leaq	.LC1(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movq	-16(%rbp), %rax
	movq	%rax, -56(%rbp)
	movq	$1970, -48(%rbp)
	movq	$1, -8(%rbp)
	jmp	.L2
.L5:
	movq	-56(%rbp), %rax
	andl	$3, %eax
	testq	%rax, %rax
	jne	.L3
	subq	$366, -56(%rbp)
	jmp	.L4
.L3:
	subq	$365, -56(%rbp)
.L4:
	addq	$1, -48(%rbp)
.L2:
	cmpq	$364, -56(%rbp)
	jg	.L5
	movq	-16(%rbp), %rax
	movq	%rax, -56(%rbp)
	movq	$1970, -40(%rbp)
	jmp	.L6
.L12:
	movq	$365, -32(%rbp)
	cmpq	$1, -8(%rbp)
	jne	.L7
	movq	-40(%rbp), %rax
	andl	$3, %eax
	testq	%rax, %rax
	jne	.L8
	movq	-40(%rbp), %rcx
	movabsq	$-6640827866535438581, %rdx
	movq	%rcx, %rax
	imulq	%rdx
	leaq	(%rdx,%rcx), %rax
	sarq	$6, %rax
	movq	%rcx, %rsi
	sarq	$63, %rsi
	subq	%rsi, %rax
	movq	%rax, %rdx
	movq	%rdx, %rax
	salq	$2, %rax
	addq	%rdx, %rax
	leaq	0(,%rax,4), %rdx
	addq	%rdx, %rax
	salq	$2, %rax
	subq	%rax, %rcx
	movq	%rcx, %rdx
	testq	%rdx, %rdx
	jne	.L9
.L8:
	movq	-40(%rbp), %rcx
	movabsq	$-6640827866535438581, %rdx
	movq	%rcx, %rax
	imulq	%rdx
	leaq	(%rdx,%rcx), %rax
	sarq	$8, %rax
	movq	%rcx, %rsi
	sarq	$63, %rsi
	subq	%rsi, %rax
	movq	%rax, %rdx
	movq	%rdx, %rax
	salq	$2, %rax
	addq	%rdx, %rax
	leaq	0(,%rax,4), %rdx
	addq	%rdx, %rax
	salq	$4, %rax
	subq	%rax, %rcx
	movq	%rcx, %rdx
	testq	%rdx, %rdx
	jne	.L7
.L9:
	movq	$366, -32(%rbp)
.L7:
	movq	-56(%rbp), %rax
	cmpq	-32(%rbp), %rax
	jl	.L14
	subq	$12, -64(%rbp)
	addq	$1, -40(%rbp)
	movq	-32(%rbp), %rax
	subq	%rax, -56(%rbp)
.L6:
	movq	-40(%rbp), %rax
	cmpq	-48(%rbp), %rax
	jle	.L12
	jmp	.L11
.L14:
	nop
.L11:
	movq	-48(%rbp), %rax
	movq	%rax, %rsi
	leaq	.LC2(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movq	-64(%rbp), %rax
	movq	%rax, %rsi
	leaq	.LC3(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movq	-56(%rbp), %rax
	movq	%rax, %rsi
	leaq	.LC4(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$0, %eax
	leave
	ret

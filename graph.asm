.section .text

.include "macros.inc"

.macro _FP c, x, y
        xorq    %rax, %rax
        movb    \c, %al
        pushq   %rax
        movw    \x, %ax
        pushq   %rax
        movw    \y, %ax
        pushq   %rax
        leaq    fp_display(%rip), %rdi
        movq    $1, %rsi
        call    fpx86
        popq    %rax
        popq    %rax
        popq    %rax
.endm

.macro _GENFOD
	xorq	%rax, %rax
	xorq	%rdx, %rdx
	xorq	%rbx, %rbx
	#
	# Generating y component
	#
	call	rand
	movw	frameheight(%rip), %bx
	divq	%rbx
	movw	%dx, (food + 2)
	addw	$2, (food + 2)
	#
	# Generating x component
	#
	call	rand
	movw	framewidth(%rip), %bx
	divq	%rbx
	movw	%dx, (food)
	addw	$2, (food)
	movw	$0, (food +  4)
	_FP	$'$', (food), (food + 2)
.endm

.globl graph_draw_frame
graph_draw_frame:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$2, %rsp
	movw	$0, -2(%rbp)
	FP	$1, frame_b0(%rip)
.__0_loop:
	movw	frameheight(%rip), %ax
	cmpw	-2(%rbp), %ax
	je	.__0_return
	incw	-2(%rbp)
	FP	$1, frame_b1(%rip)
	jmp	.__0_loop
.__0_return:
	FP	$1, frame_b0(%rip)
	leave
	ret

.globl graph_play
graph_play:
	pushq	%rbp
	movq	%rsp, %rbp
	#
	# Stack distribution
	#  -2(%rbp):   snake's length
	#  -4(%rbp):   x head's coord
	#  -6(%rbp):   y head's coord
	#  -14(%rbp):  last label visited (address)
	#  -16(%rbp):  input (key pressed)
	#
	subq	$16, %rsp
	movw	$1, -2(%rbp)
	movw	$2, -4(%rbp)
	movw	$2, -6(%rbp)
	leaq	.__1_s(%rip), %rax
	movq	%rax, -14(%rbp)
	#
	# Setting player
	#
	_FP	$'s',  $2, $2
	_GENFOD
.__1_loop:
	movq	$0, %rax
	movq	$0, %rdi
	leaq	-16(%rbp), %rsi
	movq	$1, %rdx
	syscall
	leaq	-16(%rbp), %rax
	movzbl	(%rax), %eax
	cmpb	$'q', %al
	je	.__1_return
	cmpb	$'w', %al
	je	.__1_w
	cmpb	$'s', %al
	je	.__1_s
	cmpb	$'a', %al
	je	.__1_a
	cmpb	$'d', %al
	je	.__1_d
	movq	-14(%rbp), %rax
	jmp	*%rax
.__1_s:
	incw	-6(%rbp)
	leaq	.__1_s(%rip), %rax
	movq	%rax, -14(%rbp)
	jmp	.__1_resume
.__1_w:
	decw	-6(%rbp)
	leaq	.__1_w(%rip), %rax
	movq	%rax, -14(%rbp)
	jmp	.__1_resume
.__1_d:
	incw	-4(%rbp)
	leaq	.__1_d(%rip), %rax
	movq	%rax, -14(%rbp)
	jmp	.__1_resume
.__1_a:
	decw	-4(%rbp)
	leaq	.__1_a(%rip), %rax
	movq	%rax, -14(%rbp)
	jmp	.__1_resume

.__1_inc_length:
	incw	-2(%rbp)
	movw	-2(%rbp), %ax
	cmpw	snake_max_len(%rip), %ax
	je	.__1_return

.__1_resume:
	xorq	%rdi, %rdi
	xorq	%rsi, %rsi
	xorq	%rdx, %rdx
	leaq	-2(%rbp), %rdi
	movw	-4(%rbp), %si
	movw	-6(%rbp), %dx
	call	.__got_food

	xorq	%rdi, %rdi
	movw	-2(%rbp), %di
	call	.__update_coords
	movw	-4(%rbp), %ax
	movw	%ax, (%r15)
	movw	-6(%rbp), %ax
	movw	%ax, 2(%r15)
	xorq	%rdi, %rdi
	movw	-2(%rbp), %di
	call	.__draw
	movq	$35, %rax
	leaq	timespec(%rip), %rdi
	movq	$0, %rsi
	movw	$0, -16(%rbp)
	syscall
	jmp	.__1_loop
.__1_return:
	leave
	ret

.__update_coords:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$4, %rsp
	movw	%di, -2(%rbp)
	decw	-2(%rbp)
	movw	$0, -4(%rbp)
	xorq	%rax, %rax
	movw	-2(%rbp), %ax
	cltq
	mulq	snake_chunk_size(%rip)
	leaq	snake(%rip), %r15
	addq	%rax, %r15
.__2_loop:
	movw	-4(%rbp), %ax
	cmpw	-2(%rbp), %ax
	je	.__2_return
	_FP	$' ', 0(%r15), 2(%r15)
	movq	%r15, %r14
	subq	snake_chunk_size(%rip), %r14
	xorq	%rax, %rax
	movw	0(%r14), %ax
	movw	%ax, 0(%r15)
	movw	2(%r14), %ax
	movw	%ax, 2(%r15)
	movq	%r14, %r15
	incw	-4(%rbp)
	jmp	.__2_loop
.__2_return:
	_FP	$' ', 0(%r15), 2(%r15)
	leave
	ret

.__draw:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$4, %rsp
	movw	%di, -2(%rbp)
	movw	$0, -4(%rbp)
	leaq	snake(%rip), %r15
.__3_loop:
	movw	-4(%rbp), %ax
	cmpw	-2(%rbp), %ax
	je	.__3_return
	_FP	$'s', 0(%r15), 2(%r15)
	incw	-4(%rbp)
	addq	snake_chunk_size(%rip), %r15
	jmp	.__3_loop
.__3_return:
	leave
	ret

.__got_food:
	movw	(food), %ax
	cmpw	%ax, %si
	jne	.__4_return
	movw	(food + 2), %ax
	cmpw	%ax, %dx
	jne	.__4_return
	movq	-8(%rbp), %rax
	_GENFOD
	incw	(%rdi)
	movw	(%rdi), %ax
	cmpw	snake_max_len(%rip), %ax
.__4_return:
	ret

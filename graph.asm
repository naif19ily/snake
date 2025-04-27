.section .text

.include "macros.inc"

.macro __FPX c, x, y
        xorq    %rax, %rax
        movb    \c, %al
        pushq   %rax
        xorq    %rax, %rax
        movw    \x, %ax
        pushq   %rax
        xorq    %rax, %rax
        movw    \y, %ax
        pushq   %rax
        leaq    fp_display(%rip), %rdi
        movq    $1, %rsi
        call    fpx86
        popq    %rax
        popq    %rax
        popq    %rax
.endm

.macro __GENFOD
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
	__FPX	$'$', (food), (food + 2)
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
        pushq   %rbp
        movq    %rsp, %rbp
        subq    $12, %rsp
        movw    $1, -2(%rbp)
        leaq    .__1_s(%rip), %rax
        movq    %rax, -10(%rbp)
        leaq    snake(%rip), %r15
	movw	$1, 8(%r15)
        __FPX   $'#', 0(%r15), 2(%r15)
	__GENFOD
.__1_loop:
        movq    $0, %rax
        movq    $0, %rdi
        leaq    -12(%rbp), %rsi
        movq    $1, %rdx
        syscall
        movzbl  -12(%rbp), %eax
        cmpb    $'q', %al
        je      .__1_return
        cmpb    $'w', %al
        je      .__1_w
        cmpb    $'d', %al
        je      .__1_d
        cmpb    $'s', %al
        je      .__1_s
        cmpb    $'a', %al
        je      .__1_a
        movq    -10(%rbp), %rax
        jmp     *%rax

.__1_w:
        decw    2(%r15)
	movw	2(%r15), %ax
	cmpw	$1, %ax
	je	.__1_game_over
	movw	$1, %cx
.__1_w_loop:
	cmpw	-2(%rbp), %cx
	je	.__1_w_fini
	addq	snake_chunk_size(%rip), %r15
        decw    2(%r15)
	incw	%cx
	jmp	.__1_w_loop
.__1_w_fini:
	leaq	.__1_w(%rip), %rax
	movq	%rax, -10(%rbp)
	jmp	.__1_continue

.__1_s:
        incw    2(%r15)
	movw	2(%r15), %ax
	cmpw	minorows(%rip), %ax
	je	.__1_game_over
	movw	$1, %cx
.__1_s_loop:
	cmpw	-2(%rbp), %cx
	je	.__1_s_fini
	addq	snake_chunk_size(%rip), %r15
	incw	2(%r15)
	incw	%cx
	jmp	.__1_s_loop
.__1_s_fini:
	leaq	.__1_s(%rip), %rax
	movq	%rax, -10(%rbp)
	jmp	.__1_continue

.__1_a:
	decw	0(%r15)
	movw	0(%r15), %ax
	cmpw	$1, %ax
	je	.__1_game_over
	movw	$1, %cx
.__1_a_loop:
	cmpw	-2(%rbp), %cx
	je	.__1_a_fini
	addq	snake_chunk_size(%rip), %r15
	decw	0(%r15)
	incw	%cx
	jmp	.__1_a_loop
.__1_a_fini:
	leaq	.__1_a(%rip), %rax
	movq	%rax, -10(%rbp)
	jmp	.__1_continue

.__1_d:
	incw	0(%r15)
	movw	0(%r15), %ax
	cmpw	minocols(%rip), %ax
	leaq	.__1_d(%rip), %rax
	movq	%rax, -10(%rbp)
	je	.__1_game_over
	movw	$1, %cx
.__1_d_loop:
	cmpw	-2(%rbp), %cx
	je	.__1_d_fini
	addq	snake_chunk_size(%rip), %r15
	incw	0(%r15)
	incw	%cx
	jmp	.__1_d_loop
.__1_d_fini:
	leaq	.__1_d(%rip), %rax
	movq	%rax, -10(%rbp)
	jmp	.__1_continue


.__1_continue:
	leaq	snake(%rip), %r15
	leaq	-2(%rbp), %rdi
	call	.food_handler
	movw	-2(%rbp), %di
	call	.print_body
	movq	$35, %rax
	leaq	timespec(%rip), %rdi
	movq	$0, %rsi
	syscall
        jmp     .__1_loop
.__1_game_over:
	xorq	%rax, %rax
	movw	-2(%rbp), %ax
	cltq
	negq	%rax
.__1_return:
        leave
        ret

.print_body:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$4, %rsp
	movw	$0, -2(%rbp)
	movw	%di, -4(%rbp)
	leaq	snake(%rip), %r15
.__2_loop:
	movw	-2(%rbp), %ax
	cmpw	%ax, -4(%rbp)
	je	.__2_return
	__FPX	$' ', 4(%r15), 6(%r15)
	__FPX	$'#', 0(%r15), 2(%r15)
	movw	0(%r15), %ax
	movw	%ax, 4(%r15)
	movw	2(%r15), %ax
	movw	%ax, 6(%r15)
	addq	snake_chunk_size(%rip), %r15
	incw	-2(%rbp)
	jmp	.__2_loop
.__2_return:
	leaq	snake(%rip), %r15
	leave
	ret

.food_handler:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$8, %rsp
	movq	%rdi, -8(%rbp)
	movw	0(%r15), %ax
	cmpw	%ax, (food)
	jne	.__3_return
	movw	2(%r15), %ax
	cmpw	%ax, (food + 2)
	jne	.__3_return
	movq	-8(%rbp), %r8
	incw	(%r8)
	xorq	%rax, %rax
	movw	(%r8), %ax
	cmpw	snake_max_len(%rip), %ax
	je	.__2_return
	leaq	snake(%rip), %r14
.__2_get_new_chunk_loop:
	movw	8(%r14), %ax
	cmpw	$0, %ax
	je	.__2_chunk_found
	addq	snake_chunk_size(%rip), %r14
	jmp	.__2_get_new_chunk_loop
.__2_chunk_found:
	movw	4(%r15), %ax
	subw	$2, %ax
	addw	%ax, 0(%r14)
	addw	%ax, 4(%r14)
	movw	6(%r15), %ax
	subw	$2, %ax
	addw	%ax, 2(%r14)
	addw	%ax, 6(%r14)
	__FPX	$'*', 0(%r14), 2(%r14)
	movw	$1, 8(%r14)
	__GENFOD
.__3_return:
	leave
	ret

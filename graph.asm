.section .text

.include "macros.inc"

.macro FPX c, x, y
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

.globl graph_draw_frame
graph_draw_frame:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$2, %rsp
	movw	$1, -2(%rbp)
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
        FPX     $'#', 0(%r15), 2(%r15)
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
	jmp	.__1_continue
.__1_s:
        incw    2(%r15)
	jmp	.__1_continue
.__1_a:
	decw	0(%r15)
	jmp	.__1_continue
.__1_d:
	incw	0(%r15)
.__1_continue:
	movw	-2(%rbp), %di
	call	.update_snake_chunks
        jmp     .__1_loop

.__1_return:
        leave
        ret

.update_snake_chunks:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$4, %rsp
	movw	$0, -2(%rbp)
	movw	%di, -4(%rbp)
.__2_loop:
	movw	-2(%rbp), %ax
	cmpw	%ax, -4(%rbp)
	je	.__2_return
	FPX	$'#', 0(%r15), 2(%r15)
	FPX	$' ', 4(%r15), 6(%r15)
	movl	0(%r15), %eax
	movl	%eax, 4(%r15)
	addq	snake_chunk_size(%rip), %r15
	incw	-2(%rbp)
	jmp	.__2_loop
.__2_return:
	leaq	snake(%rip), %r15
	leave
	ret

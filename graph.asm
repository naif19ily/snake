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
        subq    $16, %rsp
        #
        #  -2(%rbp):    snake's length
        # -10(%rbp):    last label jumped
        # -12(%rbp):    input
        #
        movw    $1, -2(%rbp)
        leaq    .__1_s(%rip), %rax
        movq    %rax, -10(%rbp)
        movw    $0, -12(%rbp)
        leaq    snake(%rip), %r15
        _FP     $'a', (%r15), 2(%r15)
.__1_loop:
        movq    $0, %rax
        movq    $0, %rdi
        leaq    -12(%rbp), %rsi
        movq    $1, %rdx
        syscall

        leaq    -12(%rbp), %rax
        movzbl  (%rax), %eax

        cmpb    $'q', %al
        je      .__1_return

        cmpb    $'w', %al
        je      .__1_w

        cmpb    $'a', %al
        je      .__1_a

        cmpb    $'s', %al
        je      .__1_s

        cmpb    $'d', %al
        je      .__1_d

        cmpb    $'4', %al
        je      .__1_add_chunk

        movq    -10(%rbp), %rax
        jmp     *%rax

.__1_s:
        incw    2(%r15)
        leaq    .__1_s(%rip), %rax
        movq    %rax, -10(%rbp)
        jmp     .__1_continue
.__1_w:
        decw    2(%r15)
        leaq    .__1_w(%rip), %rax
        movq    %rax, -10(%rbp)
        jmp     .__1_continue
.__1_d:
        incw    0(%r15)
        leaq    .__1_d(%rip), %rax
        movq    %rax, -10(%rbp)
        jmp     .__1_continue
.__1_a:
        decw    0(%r15)
        leaq    .__1_a(%rip), %rax
        movq    %rax, -10(%rbp)
        jmp     .__1_continue

.__1_add_chunk:
        leaq    -2(%rbp), %rdi
        movq    -10(%rbp), %rsi
        call    .__add_chunk

.__1_continue:
        xorq    %rdi, %rdi
        movw    -2(%rbp), %di
        call    .__update_chunks
        call    .__update_display
        movq    $35, %rax
        leaq    timespec(%rip), %rdi
        movq    $0, %rsi
        syscall
        movw    $0, -12(%rbp)
        jmp     .__1_loop

.__1_return:
        leave
        ret

.__update_chunks:
        pushq   %rbp
        movq    %rsp, %rbp
        subq    $4, %rsp
        movw    %di, -2(%rbp)
        movw    $1, -4(%rbp)
        movw    4(%r15), %r8w
        movw    6(%r15), %r9w
        leaq    snake(%rip), %r10
        addq    snake_chunk_size(%rip), %r10
.__2_loop:
        movw    -4(%rbp), %ax
        cmpw    -2(%rbp), %ax
        je      .__2_return

        movw    %r8w, 0(%r10)
        movw    %r9w, 2(%r10)

        movw    4(%r10), %r8w
        movw    6(%r10), %r9w

        addq    snake_chunk_size(%rip), %r10


        incw    -4(%rbp)
        jmp     .__2_loop
.__2_return:
        leave
        ret

.__update_display:
        pushq   %rbp
        movq    %rsp, %rbp
        subq    $12, %rsp
        movw    $0, -2(%rbp)
        movw    %di, -4(%rbp)
        leaq    snake(%rip), %rax
        movq    %rax, -12(%rbp)
.__3_loop:
        movw    -2(%rbp), %ax
        cmpw    -4(%rbp), %ax
        je      .__3_return

        movq    -12(%rbp), %r14
        _FP     $' ', 4(%r14), 6(%r14)
        _FP     $'a', 0(%r14), 2(%r14)
        movw    0(%r14), %ax
        movw    %ax, 4(%r14)
        movw    2(%r14), %ax
        movw    %ax, 6(%r14)
        movq    snake_chunk_size(%rip), %rax
        addq    %rax, -12(%rbp)

        incw    -2(%rbp)
        jmp     .__3_loop
.__3_return:
        leave
        ret

.__add_chunk:
        pushq   %rbp
        movq    %rsp, %rbp
        subq    $16, %rsp
        movq    %rdi, -8(%rbp)
        movq    %rsi, -16(%rbp)
        xorq    %rax, %rax
        xorq    %rdx, %rdx
        movw    (%rdi), %ax
        cltq
        movq    snake_chunk_size(%rip), %rbx
        mulq    %rbx
        leaq    snake(%rip), %r14
        addq    %rax, %r14
        movq    %r14, %r13                              # r13 is the new chunk
        subq    snake_chunk_size(%rip), %r14            # r14 is the previous chunk
        xorq    %rax, %rax
        movw    0(%r14), %ax
        movw    %ax, 0(%r13)
        movw    %ax, 4(%r13)
        movw    2(%r14), %ax
        movw    %ax, 2(%r13)
        movw    %ax, 6(%r13)
        movq    -16(%rbp), %rax
        cmpq    .__1_w(%rip), %rax
        je      .__4_w
        cmpq    .__1_a(%rip), %rax
        je      .__4_a
        cmpq    .__1_s(%rip), %rax
        je      .__4_s
        cmpq    .__1_d(%rip), %rax
        je      .__4_d
.__4_w:
        incw    2(%r13)
        jmp     .__4_return
.__4_s:
        decw    2(%r13)
        jmp     .__4_return
.__4_d:
        incw    0(%r13)
        jmp     .__4_return
.__4_a:
        decw    0(%r13)
        jmp     .__4_return

        #xorq    %rax, %rax
        #movq    -8(%rbp), %rdi
        #movw    (%rdi), %ax
        #cltq
        #leaq    util_length(%rip), %rdi
        #movq    $1, %rsi
        #pushq   %rax
        #call    fpx86
        #popq    %rax

.__4_return:
        movq    -8(%rbp), %rax
        incw    (%rax)
        leave
        ret


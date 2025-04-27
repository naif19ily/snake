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
        movw    -2(%rbp), %di
        movq    $2, %rsi
        movw    $'+', %dx
        call    .__update_chunks
        leaq    .__1_s(%rip), %rax
        movq    %rax, -10(%rbp)
        jmp     .__1_continue
.__1_w:
        movw    -2(%rbp), %di
        movq    $2, %rsi
        movw    $'-', %dx
        call    .__update_chunks
        leaq    .__1_w(%rip), %rax
        movq    %rax, -10(%rbp)
        jmp     .__1_continue
.__1_d:
        movw    -2(%rbp), %di
        movq    $0, %rsi
        movw    $'+', %dx
        call    .__update_chunks
        leaq    .__1_d(%rip), %rax
        movq    %rax, -10(%rbp)
        jmp     .__1_continue
.__1_a:
        movw    -2(%rbp), %di
        movq    $0, %rsi
        movw    $'-', %dx
        call    .__update_chunks
        leaq    .__1_a(%rip), %rax
        movq    %rax, -10(%rbp)
        jmp     .__1_continue

.__1_add_chunk:
        leaq    -2(%rbp), %rdi
        call    .__add_chunk

.__1_continue:
        xorq    %rdi, %rdi
        movw    -2(%rbp), %di
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
        subq    $22, %rsp
        #
        #  -2(%rbp):    snake's total length
        #  -4(%rbp):    number of chunks visted
        # -12(%rbp):    variable to be changed (x/y coord, offset)
        # -14(%rbp):    operation to be performed (+/-) 
        # -22(%rbp):    current address' chunk
        #
        movw    %di, -2(%rbp)
        movw    $0, -4(%rbp)
        movq    %rsi, -12(%rbp)
        movw    %dx, -14(%rbp)
        leaq    snake(%rip), %rax
        movq    %rax, -22(%rbp)
.__2_loop:
        movw    -4(%rbp), %ax
        cmpw    -2(%rbp), %ax
        je      .__2_return
        movq    -22(%rbp), %rax
        addq    -12(%rbp), %rax
        cmpw    $'+', -14(%rbp)
        je      .__2_inc
        decw    (%rax)
        jmp     .__2_iter
.__2_inc:
        incw    (%rax)
.__2_iter:
        movq    snake_chunk_size(%rip), %rax
        addq    %rax, -22(%rbp)
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
        subq    $8, %rsp
        movq    %rdi, -8(%rbp)


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
        movw    4(%r14), %ax
        movw    %ax, 0(%r13)
        movw    %ax, 4(%r13)
        movw    6(%r14), %ax
        movw    %ax, 2(%r13)
        movw    %ax, 6(%r13)
        movq    -8(%rbp), %rax
        incw    (%rax)

        xorq    %rax, %rax
        movq    -8(%rbp), %rdi
        movw    (%rdi), %ax
        cltq
        leaq    util_length(%rip), %rdi
        movq    $1, %rsi
        pushq   %rax
        call    fpx86
        popq    %rax

.__4_return:
        leave
        ret


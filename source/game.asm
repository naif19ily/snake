#                  _        
#  ___ _ __   __ _| | _____ 
# / __| '_ \ / _` | |/ / _ \
# \__ \ | | | (_| |   <  __/
# |___/_| |_|\__,_|_|\_\___|
#
# This file contains all the logic needed for the snake to move,
# food spawn, score and collitions (could be seen as the engine)
#

.section .bss
	.SnakeBody: .zero 4 * 30
	.FoodSpawn: .zero 4
        .Grid:      .zero 50 * 100

.section .data
	.SnakeDelay:
		.quad 0
		.quad 90000000

	.GameOverDelay:
		.quad 5
		.quad 0

.section .rodata
	.PutChunk:  .string "\x1b[32;42m\x1b[%d;%dHS\x1b[0m"
	.ClsChunk:  .string "\x1b[%d;%dH "
	.PutFood:   .string "\x1b[31;40m\x1b[%d;%dH*\x1b[0m"
	.InfoHead:  .string "\x1b[56;13H %d %d     "
	.InfoScore: .string "\x1b[55;13H %d        "

.section .text

.include "macros.inc"

.macro PUTXY action, row, col
	pushq	\col
	pushq	\row
	leaq	\action, %rdi
	xorq	%rsi, %rsi
	movl	$1, %esi
	call	fp86
	addq	$16, %rsp
.endm

.macro UPDLST last
	# Setting last label visited (a, w, s or d)
	leaq	\last, %rax
	movq	%rax, -12(%rbp)
	# Detecting self-collisions
	xorq	%rax, %rax
	leaq	.Grid(%rip), %r14
	movq	$100, %rbx
	movw	-14(%rbp), %ax
	mulq	%rbx
	addq	%rax, %r14
	movw	-16(%rbp), %ax
	addq	%rax, %r14
	cmpb	$1, (%r14)
	jz	.game_over
	# Checking if head is on food spawn
	xorq	%rax, %rax
	movw	(.FoodSpawn), %ax
	cmpw	%ax, -14(%rbp)
        jnz     .updview
	movw	(.FoodSpawn + 2), %ax
	cmpw	%ax, -16(%rbp)
        jnz     .updview
        jmp     .food_found
.endm

.macro GENFOOD
	xorq	%rax, %rax
	xorq	%rdx, %rdx
	xorq	%rbx, %rbx
	rdrand	%rax
	jnc	.fatal_no_soported_cpu
	movw	$50, %bx
	divq	%rbx
	movw	%dx, (.FoodSpawn)
	addw	$3, (.FoodSpawn)
	rdrand	%rax
	jnc	.fatal_no_soported_cpu
	movw	$100, %bx
	divq	%rbx
	movw	%dx, (.FoodSpawn + 2)
	addw	$6, (.FoodSpawn + 2)
	xorq	%rax, %rax
	xorq	%rbx, %rbx
	movw	(.FoodSpawn), %ax
	movw	(.FoodSpawn + 2), %bx
	PUTXY	.PutFood(%rip), %rax, %rbx
.endm

.macro SETG2 r1, r2, to	
	leaq	.Grid(%rip), %r14
	xorq	%rdx, %rdx
	movq	\r1, %rax
	movq	$100, %rbx
	mulq	%rbx
	addq	%rax, %r14
	addq	\r2, %r14
	movb	\to, (%r14)
.endm

.globl _Loop

_Loop:
	pushq	%rbp
	movq	%rsp, %rbp
	# Stack distribution
	#  -2: input
	#  -4: snake's length
	# -12: last motion
	# -14: snake's head row (this works as the next move)
	# -16: snake's head col (this works as the next move)
	subq	$16, %rsp
	movw	$0, -2(%rbp)
	movw	$1, -4(%rbp)
	leaq	.s(%rip), %rax
	movq	%rax, -12(%rbp)
	PUTXY	.PutChunk(%rip), $3, $6
	# Relative cursor position 
	movw	$3, -14(%rbp)
	movw	$6, -16(%rbp)
	# Snake's first chunk
	movw	$3, (.SnakeBody)
	movw	$6, (.SnakeBody + 2)
	GENFOOD
.toujour:
	movq	$0, %rax
	movq	$0, %rdi
	leaq	-2(%rbp), %rsi
	movq	$1, %rdx
	syscall
	cmpb	$'q', -2(%rbp)
	jz	.fini
	cmpb	$'w', -2(%rbp)
	jz	.w
	cmpb	$'a', -2(%rbp)
	jz	.a
	cmpb	$'s', -2(%rbp)
	jz	.s
	cmpb	$'d', -2(%rbp)
	jz	.d
	movq	-12(%rbp), %rax
	jmp	*%rax
.w:
	cmpw	$3, -14(%rbp)
	jz	.game_over
	decw	-14(%rbp)
	UPDLST	.w(%rip)
	jmp	.updview
.s:
	cmpw	$52, -14(%rbp)
	jz	.game_over
	incw	-14(%rbp)
	UPDLST	.s(%rip)
	jmp	.updview
.a:
	cmpw	$6, -16(%rbp)
	jz	.game_over
	decw	-16(%rbp)
	UPDLST	.a(%rip)
	jmp	.updview
.d:
	cmpw	$105, -16(%rbp)
	jz	.game_over
	incw	-16(%rbp)
	UPDLST	.d(%rip)
	jmp	.updview
.updview:
	xorq	%rax, %rax
	xorq	%rbx, %rbx
	movw	-14(%rbp), %ax
	movw	-16(%rbp), %bx
	subw	$3, %ax
	subw	$6, %bx
	pushq	%rbx
	pushq	%rax
	leaq	.InfoHead(%rip), %rdi
	xorq	%rsi, %rsi
	movl	$1, %esi
	call	fp86
	addq	$16, %rsp
	movw	-4(%rbp), %ax
	pushq	%rax
	leaq	.InfoScore(%rip), %rdi
	xorq	%rsi, %rsi
	movl	$1, %esi
	call	fp86
	addq	$8, %rsp
	leaq	.SnakeBody(%rip), %r8
	xorq	%r9, %r9
	xorq	%r10, %r10
	xorq	%r11, %r11
	xorq	%r12, %r12
	xorq	%r13, %r13
	movw	-14(%rbp), %r12w
	movw	-16(%rbp), %r13w
.updv_loop:
	cmpw	-4(%rbp), %r9w
	jz	.continue
	movw	(%r8), %r10w
	movw	2(%r8), %r11w
	PUTXY	.ClsChunk(%rip), %r10, %r11
	SETG2	%r10, %r11, $0
	movw	%r12w, (%r8)
	movw	%r13w, 2(%r8)
	PUTXY	.PutChunk(%rip), %r12, %r13
	SETG2	%r12, %r13, $1
	movw	%r10w, %r12w
	movw	%r11w, %r13w
	addq	$4, %r8
	incw	%r9w
	jmp	.updv_loop
.food_found:
	movw	$0, -2(%rbp)
	incw	-4(%rbp)
        xorq    %rax, %rax
        xorq    %rbx, %rbx
        movw    (.FoodSpawn), %ax
        movw    (.FoodSpawn + 2), %bx
        PUTXY   .ClsChunk(%rip), %rax, %rbx
        GENFOOD
	jmp	.continue
.continue:
	movq	$35, %rax
	leaq	.SnakeDelay(%rip), %rdi
	movq	$0, %rsi
	syscall
	jmp	.toujour
.game_over:
        leaq    GameOver(%rip), %r8
	xorq	%r9, %r9
	movw	(TermSize), %r9w
	subw	$4, %r9w
	shrw	$1, %r9w
	xorq	%r10, %r10
	movw	(TermSize + 2), %r10w
	subw	$69, %r10w
	shrw	$1, %r10w
        movq    $0, %r11
.gameov_loop:
        cmpq    $4, %r11
        jz      .delay
        pushq   (%r8)
        pushq   %r10
        pushq   %r9
        xorq    %rsi, %rsi
        movl    $1, %esi
        leaq    Gfmt(%rip), %rdi
        call    fp86
        addq    $24, %rsp
        addq    $8, %r8
        incq    %r11
        incq    %r9
        jmp     .gameov_loop
.delay:
	movq	$35, %rax
	leaq	.GameOverDelay(%rip), %rdi
	movq	$0, %rsi
	syscall
.fini:
	leave
	ret
.fatal_no_soported_cpu:
	EXIT	$-1

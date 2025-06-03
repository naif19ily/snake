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
	.SnakeBody: .zero

.section .rodata
	.TimeSpec:
		.quad 0
		.quad 90000000

	.PutChunk:  .string "\x1b[%d;%dHS"
	.ClsChunk:  .string "\x1b[%d;%dH "
	.InfoHead:  .string "\x1b[56;13H %d %d     "
	.InfoScore: .string "\x1b[55;13H %d        "


.section .text

.macro PUTXY action, row, col
	pushq	\col
	pushq	\row
	leaq	\action, %rdi
	xorq	%rsi, %rsi
	movl	$1, %esi
	call	fp86
	addq	$16, %rsp
.endm

.macro DBHEAD
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
.endm

.macro DBSCORE
	movw	-4(%rbp), %ax
	pushq	%rax
	leaq	.InfoScore(%rip), %rdi
	xorq	%rsi, %rsi
	movl	$1, %esi
	call	fp86
	addq	$8, %rsp
.endm

.macro UPDLST last
	leaq	\last, %rax
	movq	%rax, -12(%rbp)
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
	decw	-14(%rbp)
	UPDLST	.w(%rip)
	jmp	.updview
.s:
	incw	-14(%rbp)
	UPDLST	.s(%rip)
	jmp	.updview
.a:
	decw	-16(%rbp)
	UPDLST	.a(%rip)
	jmp	.updview
.d:
	incw	-16(%rbp)
	UPDLST	.d(%rip)
	jmp	.updview
.updview:
	xorq	%rax, %rax
	xorq	%rbx, %rbx
	DBHEAD
	DBSCORE
	leaq	.SnakeBody(%rip), %r8
	xorq	%r9, %r9
	xorq	%r10, %r10
	xorq	%r11, %r11
.updv_loop:
	cmpw	-4(%rbp), %r9w
	jz	.continue
	xorq	%rax, %rax
	xorq	%rbx, %rbx
	movw	(%r8), %r10w
	movw	2(%r8), %r11w
	PUTXY	.ClsChunk(%rip), %r10, %r11
	cmpw	$0, %r9w
	jz	.updv_first
	movw	%r10w, (%r8)
	movw	%r11w, 2(%r8)
	PUTXY	.PutChunk(%rip), %rax, %rbx
	jmp	.updv_continue
.updv_first:
	movw	-14(%rbp), %ax
	movw	-16(%rbp), %bx
	movw	%ax, (%r8)
	movw	%bx, 2(%r8)
	PUTXY	.PutChunk(%rip), %rax, %rbx
.updv_continue:
	incw	%r9w
	addq	$4, %r8
	jmp	.updv_loop
.continue:
	movq	$35, %rax
	leaq	.TimeSpec(%rip), %rdi
	movq	$0, %rsi
	syscall
	jmp	.toujour
.fini:
	leave
	ret

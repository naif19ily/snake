#                  _        
#  ___ _ __   __ _| | _____ 
# / __| '_ \ / _` | |/ / _ \
# \__ \ | | | (_| |   <  __/
# |___/_| |_|\__,_|_|\_\___|
#
# This file parses the execution arguments
# P stands for play:   snake P <nickname>
# R stands for replay: snake P <game>
# S stands for save:   snake S <game-name>
#

.section .rodata
	.DefaultName: .string "unknown"
	.DefaultGame: .string "game"
	.DefaultRepl: .string ""

.section .data
	ArgUsrName:  .quad 0
	ArgGameName: .quad 0
	ArgReplay:   .quad 0

	.globl ArgUsrName
	.globl ArgGameName
	.globl ArgReplay

.section .text

.macro ARG_Q
	incq	%rcx
	cmpq	%rcx, %r9
	jz	fatal_usage
	addq	$8, %r8
	movq	(%r15, %r8), %rax
.endm

.globl _parseArgs

_parseArgs:
	leaq	.DefaultName(%rip), %rax
	movq	%rax, (ArgUsrName)
	leaq	.DefaultGame(%rip), %rax
	movq	%rax, (ArgGameName)
	leaq	.DefaultRepl(%rip), %rax
	movq	%rax, (ArgReplay)
	movq	0(%r15), %rax
	cmpq	$1, %rax
	jz	.return
	movq	$16, %r8
	movq	%rax, %r9
	movq	$1, %rcx
.loop:
	cmpq	%rcx, %r9
	jz	.return
	movq	(%r15, %r8), %rax
	movzbl	(%rax), %eax
	cmpb	$'P', %al
	jz	.P
	cmpb	$'R', %al
	jz	.R
	cmpb	$'S', %al
	jz	.S
	jmp	fatal_unk_op
.P:
	ARG_Q
	leaq	(%rax), %rax
	movq	%rax, (ArgUsrName)
	jmp	.continue
.S:
	ARG_Q
	leaq	(%rax), %rax
	movq	%rax, (ArgGameName)
	jmp	.continue
.R:
	ARG_Q
	leaq	(%rax), %rax
	movq	%rax, (ArgReplay)
	jmp	.continue
.continue:
	addq	$8, %r8
	incq	%rcx
	jmp	.loop
.return:
	ret

#                  _        
#  ___ _ __   __ _| | _____ 
# / __| '_ \ / _` | |/ / _ \
# \__ \ | | | (_| |   <  __/
# |___/_| |_|\__,_|_|\_\___|

.section .rodata
	#
	# Defines the minimum dimensions to run
	# the program properly
	#
	.MinRows: .word 59
	.MinCols: .word 110

        #
        # Useful (mandatory) ANSI Escape codes
        #
        .CmdCls: .string "\x1b[H\x1b[2J"

        .Board1: .string "    +----------------------------------------------------------------------------------------------------+\n"

.section .bss
	# struct winsize
	# {
	#   unsigned short int ws_row;
	#   unsigned short int ws_col;
	#   unsigned short int ws_xpixel;
	#   unsigned short int ws_ypixel;
	# };
	.TermSize: .zero 8

.section .text

.include "macros.inc"

.globl _start

_start:
	pushq	%rbp
	movq	%rsp, %rbp

	call	._getermsz
	call	._drawboard

	EXIT	$0

._getermsz:	
	pushq	%rbp
	movq	%rsp, %rbp
	movq	$16, %rax
	movq	$0, %rdi
	movq	$21523, %rsi
	leaq	.TermSize(%rip), %rdx
	syscall
	movw	(.TermSize), %ax
	cmpw	.MinRows(%rip), %ax
	jl	.fatal_dimns
	movw	(.TermSize + 2), %ax
	cmpw	.MinCols(%rip), %ax
	jl	.fatal_dimns
	leave
	ret

._drawboard:
        pushq   %rbp
        movq    %rsp, %rbp
        CLS

	movq	$1, %rax
	movq	$1, %rdi
	leaq	BoardFrame(%rip), %rsi
	movq	$5612, %rdx
	syscall

        leave
        ret


.fatal_dimns:
	EXIT	$-1

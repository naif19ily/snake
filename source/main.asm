#                  _        
#  ___ _ __   __ _| | _____ 
# / __| '_ \ / _` | |/ / _ \
# \__ \ | | | (_| |   <  __/
# |___/_| |_|\__,_|_|\_\___|
#
# Starting point, calls the needed functions to configurate
# terminal and get everything running
#

.section .rodata
	#
	# Defines the minimum dimensions to run
	# the program properly
	#
	.MinRows: .word 59
	.MinCols: .word 110

.section .bss
	# struct winsize
	# {
	#   unsigned short int ws_row;
	#   unsigned short int ws_col;
	#   unsigned short int ws_xpixel;
	#   unsigned short int ws_ypixel;
	# };
	TermSize: .zero 8
	.globl TermSize

.section .text

.include "macros.inc"

.globl _start

_start:
	movq	%rsp, %r15

        call    _getDate

        call    _getRecord
	call	_parseArgs
	call	._getTermsz
	call	_sysStart
	call	._drawBoard
	call	_loop
	call	_sysFinish
._fini:
	EXIT	$0
._getTermsz:	
	pushq	%rbp
	movq	%rsp, %rbp
	movq	$16, %rax
	movq	$0, %rdi
	movq	$21523, %rsi
	leaq	TermSize(%rip), %rdx
	syscall
	movw	(TermSize), %ax
	cmpw	.MinRows(%rip), %ax
	jl	fatal_dims
	movw	(TermSize + 2), %ax
	cmpw	.MinCols(%rip), %ax
	jl	fatal_dims
	leave
	ret
._drawBoard:
        pushq   %rbp
        movq    %rsp, %rbp
	movq	$1, %rax
	movq	$1, %rdi
	leaq	BoardFrame(%rip), %rsi
	movq	$5612, %rdx
	syscall
        leave
        ret

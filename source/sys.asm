#                  _        
#  ___ _ __   __ _| | _____ 
# / __| '_ \ / _` | |/ / _ \
# \__ \ | | | (_| |   <  __/
# |___/_| |_|\__,_|_|\_\___|


.section .rodata
        #
        # Useful (mandatory) ANSI Escape codes
        #
        .CmdCls: .string "\x1b[H\x1b[2J"
	.CmdInv: .string "\x1b[?25l"
	.CmdVis: .string "\x1b[?25h"

.section .bss
	# struct termios
	# {
	#   tcflag_t c_iflag;
	#   tcflag_t c_oflag;
	#   tcflag_t c_cflag;
	#   tcflag_t c_lflag;
	#   cc_t     c_cc[NCCS];
	#   int      c_ispeed;
	#   int      c_ospeed;
	# };
	.Termios: .zero 60

.section .text

.macro CLS cur
	movq	$1, %rax
	movq	$1, %rdi
	leaq	\cur, %rsi
	movq	$6, %rdx
	syscall
        movq    $1, %rax
        movq    $1, %rdi
        leaq    .CmdCls(%rip), %rsi
        movq    $7, %rdx
        syscall
.endm

.globl _sysStart
.globl _sysFinish

_sysStart:
	pushq	%rbp
	movq	%rsp, %rbp
	CLS	.CmdInv(%rip)
	# Disabling canonical mode
	movq	$16, %rax
	movq	$0, %rdi
	movq	$21505, %rsi
	movq	$.Termios, %rdx
	syscall
	andw	$-11, (.Termios + 12)
	movq	$16, %rax
	movq	$0, %rdi
	movq	$21506, %rsi
	movq	$.Termios, %rdx
	syscall
	# Allowing program's continuity even if no
	# input is given
	movq	$72, %rax
	movq	$0, %rdi
	movq	$3, %rsi
	movq	$0, %rdx
	syscall
	movl	%eax, %r8d
	orl	$2048, %eax
	cltq
	movq	%rax, %rdx
	movq	$72, %rax
	movq	$0, %rdi
	movq	$4, %rsi
	syscall
	movl	%r8d, %eax
	# -*-

	leave
	ret

_sysFinish:
	pushq	%rbp
	movq	%rsp, %rbp
	# Enabling canonical mode
	orw	$10, (.Termios + 12)
	movq	$16, %rax
	movq	$0, %rdi
	movq	$21506, %rsi
	movq	$.Termios, %rdx
	syscall
	# Returning standard stdin back
	xorq	%rax, %rax
	movl	%edi, %eax
	cltq
	movq	%rax, %rdx
	movq	$72, %rax
	movq	$0, %rdi
	movq	$4, %rsi
	syscall
	# -*-
	movq	$1, %rax
	movq	$1, %rdi
	leaq	.CmdVis(%rip), %rsi
	movq	$6, %rdx
	syscall
	CLS	.CmdVis(%rip)
	leave
	ret

.section .text


.globl sys_check_terminal_size

sys_check_terminal_size:
	pushq	%rbp
	movq	%rsp, %rbp
	#
	# Gets window terminal dimensions
	#
	movq	$16, %rax
	movq	$0, %rdi
	movq	$21523, %rsi
	movq	$winsize, %rdx
	syscall
	movw	minorows(%rip), %ax
	cmpw	%ax, (winsize)
	jl	err_small_window
	movw	minocols(%rip), %ax
	cmpw	%ax, (winsize + 2)
	jl	err_small_window
	leave
	ret

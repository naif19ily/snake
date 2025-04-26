.section .text


.globl sys_check_terminal_size
sys_check_terminal_size:
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
	ret

.globl sys_disable_canonical_mode
sys_disable_canonical_mode:
	movq	$16, %rax
	movq	$0, %rdi
	movq	$21505, %rsi
	movq	$termios, %rdx
	syscall
	andw	$-11, (termios + 12)
	movq	$16, %rax
	movq	$0, %rdi
	movq	$21506, %rsi
	movq	$termios, %rdx
	syscall
	ret

.globl sys_enable_canonical_mode
sys_enable_canonical_mode:
	orw	$10, (termios + 12)
	movq	$16, %rax
	movq	$0, %rdi
	movq	$21506, %rsi
	movq	$termios, %rdx
	syscall
	ret

.globl sys_stdin_init
sys_stdin_init:
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
	ret

.globl sys_stdin_fini
sys_stdin_fini:
	xorq	%rax, %rax
	movl	%edi, %eax
	cltq
	movq	%rax, %rdx
	movq	$72, %rax
	movq	$0, %rdi
	movq	$4, %rsi
	syscall
	ret

#                  _        
#  ___ _ __   __ _| | _____ 
# / __| '_ \ / _` | |/ / _ \
# \__ \ | | | (_| |   <  __/
# |___/_| |_|\__,_|_|\_\___|

.macro EXIT status
	movq	\status, %rdi
	movq	$60, %rax
	syscall
.endm

.macro OPFILE fd, path
	movq	$2, %rax
	leaq	\path, %rdi
	movq	$2, %rsi
	movq	$0, %rdx
	syscall
	cmpq	$-1, %rax
	jz	fatal_cannot_open_file
	movq	%rax, (\fd)
.endm

.macro RDFILE fd, size, buff
	movq	$8, %rax
	movq	\fd, %rdi
	xorq	%rsi, %rsi
	movq	$2, %rdx
	syscall
	movq	%rax, (\size)
	movq	$8, %rax
	movq	(\fd), %rdi
	xorq	%rsi, %rsi
	xorq	%rdx, %rdx
	syscall
	movq	$9, %rax
	xorq	%rdi, %rdi
	movq	\size(%rip), %rsi
	movq	$3, %rdx
	movq	$34, %r10
	movq	$-1, %r8
	xorq	%r9, %r9
	syscall
	movq	%rax, \buff
	movq	$0, %rax
	movq	(\fd), %rdi
	movq	\buff, %rsi
	movq	(\size), %rdx
	syscall
.endm

.macro UNMAP addr, len
	movq	$11, %rax
	movq	\addr, %rdi
	movq	\len, %rsi
	syscall
.endm

.macro CLOSE fd
	movq	$3, %rax
	movq	\fd, %rdi
	syscall
.endm

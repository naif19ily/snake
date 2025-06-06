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

.macro RDFILE path, fd, size
	movq	$2, %rax
	leaq	\path, %rdi
	movq	$2, %rsi
	movq	$0, %rdx
	syscall
	cmpq	$-1, %rax
	jz	fatal_cannot_open_file
	movq	%rax, (\fd)
	movq	$8, %rax
	movq	\fd, %rdi
	xorq	%rsi, %rsi
	movq	$2, %rdx
	syscall
	movq	%rax, (\size)
	movq	$8, %rax
	movq	(\size), %rdi
	xorq	%rsi, %rsi
	xorq	%rdx, %rdx
	syscall
.endm

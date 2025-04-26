.macro EX code
	movq	\code, %rdi
	movq	$60, %rax
	syscall
.endm

.macro FP fd, buff
        leaq    \buff, %rdi
        movq    \fd, %rsi
        call    fpx86
.endm

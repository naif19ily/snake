.macro EXIT a
    movq    \a, %rdi
    movq    $60, %rax
    syscall
.endm

.macro  ERROUT a, b
    leaq    \a, %rsi
    movq    \b, %rdx
    movq    $1, %rax
    movq    $2, %rdi
    syscall
.endm

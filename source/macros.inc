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

.macro CLS
        movq    $1, %rax
        movq    $1, %rdi
        leaq    .CmdCls(%rip), %rsi
        movq    $7, %rdx
        syscall
.endm

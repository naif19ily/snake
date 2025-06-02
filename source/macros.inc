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

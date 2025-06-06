#                  _        
#  ___ _ __   __ _| | _____ 
# / __| '_ \ / _` | |/ / _ \
# \__ \ | | | (_| |   <  __/
# |___/_| |_|\__,_|_|\_\___|
#
# This file handles maximum score file input and
# output
#

.section .rodata
	.FilePath: .string "../cache/record"

.section .data
	.FileDesc: .quad 0
	.FileSize: .quad 0

.section .bss
	RecordScore: .zero 2
	.globl RecordScore

	RecordPlayer: .quad 0
	.globl RecordPlayer

.section .text

.include "macros.inc"

.globl _getRecord

_getRecord:
	RDFILE	.FilePath(%rip), .FileDesc, .FileSize
	movq	(.FileSize), %rax
	cmpq	$0, %rax
	jz	.return
.return:
	ret

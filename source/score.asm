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
	.NumBuff:  .zero 32

.section .data
	.FileDesc: .quad 0
	.FileSize: .quad 0

.section .bss
	RecordScore: .zero 8
	.globl RecordScore

	RecordPlayer: .quad 0
	.globl RecordPlayer

	.Buffer: .quad 0

.section .text

.include "macros.inc"

.globl _getRecord

_getRecord:
	RDFILE	.FilePath(%rip), .FileDesc, .FileSize, .Buffer(%rip)
	movq	(.FileSize), %rax
	cmpq	$0, %rax
	jz	.return
	movq	.Buffer(%rip), %rdi
	call	_getNumber
	movq	%rax, (RecordScore)
	incq	%rdi
	movq	%rdi, (RecordPlayer)
	ret
.return:
        ret

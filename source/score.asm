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

        RecordDay: .quad 0
        .globl RecordDay

        RecordMonth: .quad 0
        .globl RecordMonth

        RecordYear: .quad 0
        .globl RecordYear

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
	call	_getNumber
	movq	%rax, (RecordDay)
	incq	%rdi
	call	_getNumber
	movq	%rax, (RecordMonth)
	incq	%rdi
	call	_getNumber
	movq	%rax, (RecordYear)
	incq	%rdi
	movq	%rdi, (RecordPlayer)
	ret
.return:
        ret



# TODO close file & unmap buffer

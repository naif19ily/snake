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
	.FilePath: .string "../RECORD"
	.UpdScore: .string "%d\n%d %d %d\n%s"

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
	OPFILE	.FileDesc, .FilePath(%rip)
	RDFILE	.FileDesc, .FileSize, .Buffer(%rip)
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
        CLOSE   (.FileDesc)
	ret
.return:
        ret

.globl _newRecord
_newRecord:
	pushq	%rbp
	movq	%rsp, %rbp
        movq    $2, %rax
        movq    %rdi, %r8
        leaq    .FilePath(%rip), %rdi
        movq    $577, %rsi                                              # O_WRONLY, O_TRUNC, O_CREAT
        movq    $292, %rdx                                              # no write permissions
        syscall
	cmpq	$-1, %rax
	jz	fatal_cannot_open_file
        movq    %rax, %rsi
	movq	ArgUsrName(%rip), %rax
	pushq	%rax
	movq	(ThisYear), %rax
	pushq	%rax
	movq	(ThisMonth), %rax
	pushq	%rax
	movq	(ThisDay), %rax
	pushq	%rax
	pushq	%r8
	leaq	.UpdScore(%rip), %rdi
	call	fp86
	addq	$40, %rsp
        UNMAP   .Buffer(%rip), .FileSize(%rip)
	leave
	ret

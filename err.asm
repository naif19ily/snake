.section .text

.include "macros.inc"

.globl err_small_window

err_small_window:
	EX	$-1

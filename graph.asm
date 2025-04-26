.section .text

.include "macros.inc"

.globl graph_draw_frame

graph_draw_frame:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$2, %rsp
	movw	$1, -2(%rbp)
	FP	$1, frame_b0(%rip)
.__0_loop:
	movw	frameheight(%rip), %ax
	cmpw	-2(%rbp), %ax
	je	.__0_return
	incw	-2(%rbp)
	FP	$1, frame_b1(%rip)
	jmp	.__0_loop
.__0_return:
	FP	$1, frame_b0(%rip)
	leave
	ret

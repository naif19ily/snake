.section .text

.globl _start

.include "macros.inc"

_start:
        #
        # Setting up 'main's' function stack
        #
        pushq   %rbp
        movq    %rsp, %rbp
        subq    $16, %rsp
        #  -2(%rbp): snake's current length
        #
        #
        #
        movw    $1, -2(%rbp)
        call    sys_check_terminal_size
        FP      $1, fp_init_game
        call    graph_draw_frame

.finish_program:
        FP      $1, fp_fini_game
        EX      $0

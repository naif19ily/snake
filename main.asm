.section .text

.include "macros.inc"

.globl _start
_start:
        pushq   %rbp
        movq    %rsp, %rbp
        subq    $4, %rsp
        call    sys_check_terminal_size
        FP      $1, fp_init_game
        call    graph_draw_frame
        call    sys_disable_canonical_mode
        movl    %eax, -4(%rbp)
        movw    $0, %cx
        leaq    snake(%rip), %r15
.set_up_snakes_body:
        #
        # ANSI offaet escape codes start from 1, so we need to set up
        # each x and y position to 2, since the first column and row
        # of the screen are used to display the frame bounds
        #
        cmpw    %cx, snake_max_len(%rip)
        je      .continue_main_proc
        movw    $2, 0(%r15)
        movw    $2, 2(%r15)
        movw    $2, 4(%r15)
        movw    $2, 6(%r15)
        addq    snake_chunk_size(%rip), %r15
        incw    %cx
        jmp     .set_up_snakes_body
.continue_main_proc:
        call    graph_play
.finish_program:
        call    sys_enable_canonical_mode
        movl    -6(%rbp), %edi
        call    sys_stdin_fini
        FP      $1, fp_fini_game
        EX      $0

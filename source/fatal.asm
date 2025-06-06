#                  _        
#  ___ _ __   __ _| | _____ 
# / __| '_ \ / _` | |/ / _ \
# \__ \ | | | (_| |   <  __/
# |___/_| |_|\__,_|_|\_\___|
#
# Handle fatal situations and program's usage message
#

.include "macros.inc"

.globl fatal_usage
fatal_usage:
	EXIT	$1

.globl fatal_dims
fatal_dims:
	EXIT	$2

.globl fatal_cpu
fatal_cpu:
	EXIT	$3

.globl fatal_unk_op
fatal_unk_op:
	EXIT	$4

.globl fatal_cannot_open_file
fatal_cannot_open_file:
	EXIT	$5

.globl fatal_huge_number
fatal_huge_number:
	EXIT	$6

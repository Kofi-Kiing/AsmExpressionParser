.data
stack:  .space  100
ostack: .space  100
expr:   .asciiz "1+2*3-4/2+10"

.text
        .globl  main

main:
    la      $t0,                    expr                                                    # pointer to current character in expression
    la      $t1,                    stack                                                   # pointer to numeric stack
    la      $t2,                    ostack                                                  # pointer to operator stack
    addi    $t1,                    $t1,                        100
    addi    $t2,                    $t2,                        100
    add     $t7,                    $t2,                        $zero                       #pointer to top of operator stack
    addi    $s6,                    $zero,                      48
    # t0: expr pointer, t1: num stack pointer, t2: op stack pointer, t3: current token,
    # t4: 10 (for multiplication), t5: accumulator for numbers, t6: is operator indicator,
    # t7: op stack top pointer, t8: temp op, t9: temp char, a0/a1: operands, s0: top op precedence,
    # s1: current op prec, s3: current operator, v1: results of computation

forLoop:
    lb      $t3,                    0($t0)
    beq     $t3,                    $zero,                      end_parse
    slti    $t6,                    $t3,                        48                          # if current token is an operator
    bne     $t6,                    $zero,                      storeValandWorkOnOperator
    beq     $t6,                    $zero,                      workOnNumber

workOnNumber:
    addi    $t4,                    $zero,                      10
    mul     $t5,                    $t5,                        $t4                         #mulitply accumulated number by 10
    addi    $t3,                    $t3,                        -48                         #convert current token to an integer
    add     $t5,                    $t5,                        $t3                         #add to accumulated number
    add     $t0,                    $t0,                        1
    j       forLoop

storeValandWorkOnOperator:
    add     $s3,                    $t3,                        $zero                       # Store current operator
    addi    $t1,                    $t1,                        -4
    sw      $t5,                    0($t1)                                                  # Store accumulated number
    addi    $t5,                    $zero,                      0                           # Reset number accumulator

compareLoop:
    beq     $t7,                    $t2,                        push_current_op             # Operator stack is empty

    lb      $t8,                    0($t7)                                                  # Top operator
    jal     get_precedence_top
    add     $s0,                    $v0,                        $zero

    add     $a0,                    $s3,                        $zero
    jal     get_precedence_current
    add     $s1,                    $v0,                        $zero

    bge     $s0,                    $s1,                        applyTopOppFromStore
    j       push_current_op

applyTopOppFromStore:
    # Pop operator
    lb      $t8,                    0($t7)
    addi    $t7,                    $t7,                        1

    # Pop two values
    lw      $a0,                    0($t1)
    addi    $t1,                    $t1,                        4
    lw      $a1,                    0($t1)
    addi    $t1,                    $t1,                        4

    # Perform operation
    beq     $t8,                    42,                         doMultOppAndStore
    beq     $t8,                    43,                         doAddOppAndStore
    beq     $t8,                    45,                         doSubOppAndStore
    beq     $t8,                    47,                         doDivOppAndStore
    j       compareLoop                                                                     # Continue checking stack

doMultOppAndStore:
    mul     $s1,                    $a1,                        $a0                         # left * right
    j       pushResultStore
doAddOppAndStore:
    add     $s1,                    $a1,                        $a0                         # left + right
    j       pushResultStore
doSubOppAndStore:
    sub     $s1,                    $a1,                        $a0                         # left - right
    j       pushResultStore
doDivOppAndStore:
    div     $a1,                    $a0                                                     # left / right
    mflo    $s1
    j       pushResultStore

pushResultStore:
    addi    $t1,                    $t1,                        -4
    sw      $s1,                    0($t1)
    j       compareLoop

push_current_op:
    addi    $t7,                    $t7,                        -1
    sb      $s3,                    0($t7)
    addi    $t0,                    $t0,                        1
    j       forLoop

end_parse:
    bnez    $t5,                    storeValandWorkOnOperator                               # Flush last number

flushLoop:
    beq     $t7,                    $t2,                        done
    # Pop operator
    lb      $t8,                    0($t7)
    addi    $t7,                    $t7,                        1
    # Pop two values
    lw      $a0,                    0($t1)                                                  # right operand
    addi    $t1,                    $t1,                        4
    lw      $a1,                    0($t1)                                                  # left operand
    addi    $t1,                    $t1,                        4
    # Perform operation
    beq     $t8,                    42,                         doMultOppAndflush
    beq     $t8,                    43,                         doAddOppAndflush
    beq     $t8,                    45,                         doSubOppAndflush
    beq     $t8,                    47,                         doSubOppAndflush
    j       flushLoop

doMultOppAndflush:
    mul     $s1,                    $a1,                        $a0
    j       pushResultFlush
doAddOppAndflush:
    add     $s1,                    $a1,                        $a0
    j       pushResultFlush
doSubOppAndflush:
    sub     $s1,                    $a1,                        $a0
    j       pushResultFlush
doDivOppAndflush:
    div     $a1,                    $a0
    mflo    $s1
    j       pushResultFlush

pushResultFlush:
    addi    $t1,                    $t1,                        -4
    sw      $s1,                    0($t1)
    j       flushLoop

done:
    add     $v1,                    $v1,                        $s1
    lw      $a0,                    0($t1)
    addi    $v0,                    $zero,                      10
    syscall                                                                                 #end my program

get_precedence_top:
    lb      $t9,                    0($t7)
    addi    $v0,                    $zero,                      0
    beq     $t9,                    43,                         setPre1RetTop               # +
    beq     $t9,                    45,                         setPre1RetTop               # -
    beq     $t9,                    42,                         setPre2RetTop               # *
    beq     $t9,                    47,                         setPre2RetTop               # /
    jr      $ra
setPre1RetTop:
    addi    $v0,                    $zero,                      1
    jr      $ra
setPre2RetTop:
    addi    $v0,                    $zero,                      2
    jr      $ra

get_precedence_current:
    addi    $v0,                    $zero,                      0
    beq     $a0,                    43,                         setPre1RetCurr              # +
    beq     $a0,                    45,                         setPre1RetCurr              # -
    beq     $a0,                    42,                         setPre2RetCurr              # *
    beq     $a0,                    47,                         setPre2RetCurr              # /
    jr      $ra
setPre1RetCurr:
    addi    $v0,                    $zero,                      1
    jr      $ra
setPre2RetCurr:
    addi    $v0,                    $zero,                      2
    jr      $ra
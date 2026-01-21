.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:
    # Error checks
    li t0 1
    blt a1 t0 length_less_than_one
    blt a2 t0 length_less_than_one
    blt a4 t0 length_less_than_one
    blt a5 t0 length_less_than_one
    # length error
    
    bne a2 a4 Acols_not_equal_Brows

    # Prologue
    addi sp sp -4
    sw ra 0(sp)

    li t0 0
    
outer_loop_start:
    li t1 0


inner_loop_start:
    # a5 must > 0
    # so there will must be one loop
   
    # save the register
    addi sp sp -32
    sw t0 0(sp)
    sw t1 4(sp)
    sw a0 8(sp)
    sw a1 12(sp)
    sw a2 16(sp)
    sw a3 20(sp)
    sw a4 24(sp)
    sw a6 28(sp)
    
    slli t1 t1 2
    slli t0 t0 2 # t0 and t1 will be the offset
    
    add a3 a3 t1 # a3 = a3 + j Point to the start of the col
    add a1 a3 x0 # a1 = a3, start of arr1
    
    li a3 1 # stride of arr1
    add a4 x0 a5 # stride of arr2 
    
    mul t0 t0 a5
    add t0 t0 t1
    add a6 a6 t0 # offset of the result arr
    
    ebreak
    call dot
    ebreak
    
    sw a0 0(a6) # save the return value
    
    # load the register
    lw t0 0(sp)
    lw t1 4(sp)
    lw a0 8(sp)
    lw a1 12(sp)
    lw a2 16(sp)
    lw a3 20(sp)
    lw a4 24(sp)
    lw a6 28(sp)
    addi sp sp 32
   
    addi t1 t1 1
    blt t1 a5 inner_loop_start # if t1 < a5 jump to the loop start
    
inner_loop_end:
    slli t3 a2 2
    add a0 a0 t3 # a0 = a0 + a2 * 4, a0 points the start of the row
    
    addi t0 t0 1 # i += 1
    
    blt t0 a1 outer_loop_start # if t0 < a1 jump to the start

outer_loop_end:
    # Epilogue
    lw ra 0(sp)
    addi sp sp 4
    

    jr ra
    
length_less_than_one:
    li a0 38
    j exit
    
Acols_not_equal_Brows:
    li a0 38
    j exit
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
    ble a1 t0 length_less_than_one
    ble a1 t0 length_less_than_one
    ble a4 t0 length_less_than_one
    ble a5 t0 length_less_than_one
    
    bne a2 a4 Acols_not_equal_Brows

    # Prologue
    addi sp sp -4
    sw ra 0(sp)

outer_loop_start:
    



inner_loop_start:










length_less_than_one:
    li a0 36
    j exit
    
Acols_not_equal_Brows:
    li a0 38
    j exit
    
inner_loop_end:




outer_loop_end:


    # Epilogue
    lw ra 0(sp)
    addi sp sp 4
    

    jr ra

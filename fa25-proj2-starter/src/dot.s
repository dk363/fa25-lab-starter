.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    addi t0, x0, 1 # t0 = 1
    blt a2, t0, the_number_of_elements_less_than_1 # if a2 < 1 error 36
    
    # Prologue
    blt a3, t0, the_stride_less_than_1 # if a3 < 1 error 37
    blt a4, t0, the_stride_less_than_1 # if a4 < 1 error 37
    
    slli a3, a3, 2
    slli a4, a4, 2 
    
    add t1, x0, x0 # t1: result
    
loop_start:
    lw t2, 0(a0) 
    lw t3, 0(a1) 
    
    mul t2, t2, t3 # t2 = t2 * t3
    add t1, t1, t2 # t1 = t1 + t2
    
    addi a2, a2, -1 # a2 -= 1
    beq a2, x0, loop_end # If a2 < 0 then jump to the end
    
    add a0, a0, a3 
    add a1, a1, a4 # update the pointer
    j loop_start
    
loop_end:
    # Epilogue
    add a0, x0, t1
    jr ra
    
the_number_of_elements_less_than_1:
    li a0, 36
    j exit

the_stride_less_than_1:
    li a0, 37
    j exit
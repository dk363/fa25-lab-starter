.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    addi t0, x0, 1 # t0 = 1
    blt a1, t0, error # a1 < 1 return error

loop_start:
    lw t0, 0(a0) # t0 represents the max number max_number = *arr
    add t1, x0, x0 # max_number_idx
    
    add t2, a0, x0 # Current Pinter 
    slli t3, a1, 2 # t3 = n * 4
    add t3, a0, t3 # t3 = End Pointer

loop_continue:
    bge t2, t3, loop_end
    
    lw t4, 0(t2) # t4 = Current Number
    
    bge t0, t4, next_iter # t0 >= t4, continue
    # t0 < t4 there is another bigger number
    add t0, x0, t4
    sub t5, t2, a0
    srli t5, t5, 2
    add t1, x0, t5
    
next_iter:
    addi t2, t2, 4 # update the pointer
    j loop_continue
    
loop_end:
    # Epilogue
    add a0, x0, t1
    jr ra
    
error:
    li a0, 36
    j exit
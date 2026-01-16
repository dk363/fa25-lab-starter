.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    ebreak 
    
    # Prologue
    addi t0, x0, 1 # t0 = 1
    blt a1, t0, error # if a1 < 1 jump to error
    
loop_start:
    addi t0, x0, 0 # t0 = 0 (means int i = 0
    
loop_continue:
    slli t1, t0, 2 # offset t1 = t0 * 4 (sizeof(int) == 4)
    add t3, a0, t1 # t3 = a0 + t1 (t3 is the address of the arr number
    
    lw t2, 0(t3) # load word from the arr (t3 is the real number of the arr number
    bge t2, x0, greater_than_zero # if t2 >= x0 jump to the label
    
    sw x0, 0(t3) # store word 
    
    greater_than_zero:

        addi t0, t0, 1
        blt t0, a1, loop_continue
    
loop_end:
    # Epilogue
    jr ra
    
error:
    li a0 36
    j exit
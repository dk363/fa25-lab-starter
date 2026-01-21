.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:

    # Prologue
    addi sp sp -24
    sw ra 0(sp)
    sw s0 4(sp)
    sw a2 8(sp)
    sw a3 12(sp)
    sw a1 16(sp)
    sw s1 20(sp)
    
    
    # open file
    li a1 1 # 1 represents write only
    call fopen
    li t0 -1
    beq a0 t0 fopen_error
    add s0 a0 x0 # s0, file descriptor

    # write the row 
    add a0 s0 x0
    addi a1 sp 8 # the pointer of the row  
    li a2 1 # number of elements
    li a3 4 # size of each elements
    call fwrite
    li t0 1 # t0 = 1 = number of elements
    bne a0 t0 fwrite_error # If a0 != a2, error 
    
    # write the col 
    add a0 s0 x0
    addi a1 sp 12 # the pointer of the col
    li a2 1 # number of elements
    li a3 4 # size of each elements
    call fwrite
    li t0 1 # t0 = 1 = number of elements
    bne a0 t0 fwrite_error # If a0 != a2, error 

    # write the matrix
    add a0 s0 x0
    lw a1 16(sp)
    lw t0 8(sp) # read the row
    lw t1 12(sp) # read the col
    mul a2 t0 t1 # get the size of matrix
    add s1 a2 x0 # save the size of matrix
    li a3 4
    call fwrite
    bne a0 s1 fwrite_error
    
    # close the file
    add a0 s0 x0 # load the file descriptor
    call fclose
    li t0 -1
    beq a0 t0 fclose_error # a0 == -1, error


    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 20(sp)
    addi sp sp 24
    
    jr ra
    
fopen_error:
    li a0 27
    j exit
    
fwrite_error:
    li a0 30
    j exit
    
fclose_error:
    li a0 28
    j exit

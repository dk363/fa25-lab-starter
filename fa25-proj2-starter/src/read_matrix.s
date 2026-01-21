.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:
    # Prologue
    addi sp sp -4
    sw ra 0(sp)
    
    addi sp sp -24
    sw a0 0(sp)
    sw a1 4(sp)
    sw a2 8(sp)
    sw s0 12(sp)
    sw s1 16(sp)
    sw s2 20(sp)
    
    
    # read the row and col size
    # open the file
    li a1 0 # 0 represents read only
    call fopen
    li t0 -1
    beq a0 t0 fopen_error # if a0 == -1 error
    add s0 a0 x0 # s0, file descriptor
    
    # read the row 
    lw a1 4(sp) # load the row pointer address
    li a2 4 # the number of read bytes is 4
    call fread
    li t1 4
    bne t1 a0 fread_error # if t1 != 4 error
    lw t1 4(sp)
    lw s1 0(t1) # save the row size 
    
    # read the col
    lw a1 8(sp) # load the col pointer address
    li a2 4 # the number of bytes to read is 4
    add a0 s0 x0 # load the file descriptor
    call fread
    li t1 4
    bne t1 a0 fread_error # if a0 != 4 error
    lw t1 8(sp) # load the col size
    lw t1 0(t1)
    mul s1 s1 t1 # s1, size of matrix
    
    slli s1 s1 2 # s1, number of bytes     

    # malloc the buffer 
    add a0 x0 s1 # load the number of bytes
    call malloc
    beq a0 x0 malloc_error # if a0 == 0, error
    add s2 a0 x0 # s2, buffer address
    
    
    # read the file to the buffer
    add a0 s0 x0 # file descriptr
    add a1 s2 x0 # the buffer address
    add a2 s1 x0 # number of bytes
    call fread
    bne a0 s1 fread_error
    
    # close the file
    add a0 s0 x0 # file descriptr
    call fclose
    li t1 -1
    beq a0 t1 fclose_error # if a0 == -1 error

    add a0 s2 x0 # return the pointer to the buffer address
    
    # Epilogue
    lw s0 12(sp)
    lw s1 16(sp)
    lw s2 20(sp)
    addi sp sp 24
    
    lw ra 0(sp)
    addi sp sp 4

    jr ra
    
malloc_error:
    li a0 26
    j exit
    
fopen_error:
    li a0 27
    j exit
    
fclose_error:
    li a0 28
    j exit
    
fread_error:
    li a0 29
    j exit
    
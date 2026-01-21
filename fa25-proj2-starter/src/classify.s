.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    addi sp sp -60
    sw ra 0(sp)
    sw s0 28(sp)
    sw s1 32(sp)
    sw s2 36(sp)
    sw s3 40(sp)
    sw s4 44(sp)
    sw s5 48(sp)
    sw s6 52(sp)
    sw a2 56(sp)
    
    mv s0 a1
    # error_check
    li t0 5
    bne a0 t0 incorrect_number_argu

    # read m0
    lw a0 4(s0) # load word from s0 + 4, pointer of the m0
    addi a1 sp 4 # sp+4 pointer m0 row
    addi a2 sp 8 # sp+8 pointer m0 col
    call read_matrix
    mv s1 a0 # s1, pointer m0
    
    # read m1
    lw a0 8(s0)
    addi a1 sp 12 # sp+12 pointer m1 row
    addi a2 sp 16 # sp+16 pointer m1 col 
    call read_matrix
    mv s2 a0 # s2, pointer m1
    
    # read input
    lw a0 12(s0)
    addi a1 sp 20 # sp+20 pointer input row
    addi a2 sp 24 # sp+24 pointer input col
    call read_matrix
    mv s3 a0 # s3, pointer input
    
    # Compute h = matmul(m0, input)
    # malloc h 
    lw t0 4(sp) # m0 row h row
    lw t1 24(sp) # input col h col
    mul a0 t0 t1 # a0, matrix size
    slli a0 a0 2
    call malloc 
    li t0 0
    beq a0 t0 malloc_error
    mv s4 a0 # s4, pointer h

    mv a0 s1 # m0
    lw a1 4(sp) # m0 row
    lw a2 8(sp) # m0 col
    mv a3 s3 # input 
    lw a4 20(sp) # input row
    lw a5 24(sp) # input col
    mv a6 s4 # h
    call matmul
    
    # Compute h = relu(h)
    mv a0 s4 # h
    lw t0 4(sp) # m0 row
    lw t1 24(sp) # input col
    mul a1 t0 t1 # size of matrix
    call relu
    
    
    # Compute o = matmul(m1, h)
    # malloc o
    lw t0 12(sp) # m1 row o row
    lw t1 24(sp) # h col o col
    mul a0 t0 t1 # matrix size
    slli a0 a0 2
    call malloc
    li t0 0
    beq a0 t0 malloc_error
    mv s5 a0 # s5, pointer o
    
    mv a0 s2 # m1
    lw a1 12(sp) # m1 row
    lw a2 16(sp) # m1 col
    mv a3 s4 # h
    lw a4 4(sp) # h row
    lw a5 24(sp) # h col
    mv a6 s5 # o
    call matmul
    
    
    # write matrix o into output file
    lw a0 16(s0) # output file pointer
    mv a1 s5
    lw a2 12(sp) # m1 row o row
    lw a3 24(sp) # h col o col
    call write_matrix
    
    
    # Compute and return argmax(o)
    mv a0 s5
    lw t0 12(sp) # m1 row o row
    lw t1 24(sp) # h col o col
    mul a1 t0 t1 # matrix size
    call argmax # a0 is the result of biggest element
    mv s6 a0 # s6, result of argmax(o)
    

    # If enabled, print argmax(o) and newline
    lw t0 56(sp)
    bne t0 x0 end # If a2 != 0 jump to the end directly
    call print_int
    li a0 '\n'
    call print_char
end:
    mv a0 s1
    call free
    mv a0 s2
    call free
    mv a0 s3
    call free
    mv a0 s4
    call free # free h
    mv a0 s5
    call free # free o
    
    mv a0 s6
    
    lw ra 0(sp)
    lw s0 28(sp)
    lw s1 32(sp)
    lw s2 36(sp)
    lw s3 40(sp)
    lw s4 44(sp)
    lw s5 48(sp)
    lw s6 52(sp)
    addi sp sp 60
    
    jr ra
    
malloc_error:
    li a0 26
    j exit
    
incorrect_number_argu:
    li a0 31
    j exit
    
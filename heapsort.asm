# HEAPSORT algorithm in Assembly MIPS32

            .data
welcome:    .asciiz "HEAPSORT\nThis program sorts a vector of integers\n\n"
str1:       .asciiz "Enter an integer: "
str2:       .asciiz "Want to enter another number? (y/n): "
str3:       .asciiz "Vector: "
str4:       .asciiz "Sorted vector: "
space:      .asciiz " "
return:     .asciiz "\n"

            .text
            .globl main

            #MAIN

# The main function guides the user in the insertion of the vector to be sorted. Every integer is saved in the stack, using 4mb of memory each. Entered vector and sorted vector are printed.

main:       move $s0, $sp           # $s0->vector base adress (a*)
            li $s1, 0               # $s1->inserted numbers counter (n)

            la $a0, welcome
            li $v0, 4
            syscall

ins_loop:   la $a0, str1
            li $v0, 4
            syscall

            li $v0, 5               # read vector and save into stack
            syscall
            addi $sp, $sp, -4
            sw $v0, 0($sp)
            addi $s1, $s1, 1

check:      la $a0, str2
            li $v0, 4
            syscall

            li $t0, 'n'
	        li $t1, 'y'
            li $v0, 12
            syscall
	        move $t3, $v0
            beq $t0, $t3, exit_ins

    	    la $a0, return
    	    li $v0, 4
    	    syscall

    	    beq $t1, $t3, ins_loop
    	    j check


exit_ins:   la $a0, return
    	    li $v0, 4
    	    syscall

    	    la $a0, str3
            li $v0, 4
            syscall

            move $t0, $s0           # print entered vector
            addi $t0, $t0, -4

pr1_loop:   lw $a0, 0($t0)
            li $v0, 1
            syscall

            la $a0, space
            li $v0, 4
            syscall

            addi $t0, $t0, -4
            bge $t0, $sp, pr1_loop

            la $a0, return
            li $v0, 4
            syscall

            addi $sp, $sp, -8
            sw $s0, 4($sp)
            sw $s1, 0($sp)

            addi $a0, $s0, -4
            add $a1, $s1, $zero

            jal heapsort

            lw $s1, 0($sp)
            lw $s0, 4($sp)
            addi $sp, $sp, 8

            la $a0, str4
            li $v0, 4
            syscall

            move $t0, $s0           # print sorted vector
            addi $t0, $t0, -4

pr2_loop:   lw $a0, 0($t0)
            li $v0, 1
            syscall

            la $a0, space
            li $v0, 4
            syscall

            addi $t0, $t0, -4
            bge $t0, $sp, pr2_loop

            li $v0, 10              #exit
            syscall

            #FUNCTIONS

# Before every function there's a C possible implementation.

            #SWAP

# This function swaps the position of 2 elements of the vector.

#	    void swap(int *a, int i, int j) {
#		int k = a[i];
#		a[i] = a[j];
#		a[j] = k;
#	    }

swap:       sll $t0, $a1, 2         # $a0->a* $a1->i $a2->j
            sll $t1, $a2, 2
            sub $t0, $a0, $t0
            sub $t1, $a0, $t1
            lw $t2, 0($t0)          # $t2->a[i]
            lw $t3, 0($t1)          # $t3->a[j]
            sw $t2, 0($t1)
            sw $t3, 0($t0)
            j $ra

            #HEAPIFY

# This function is used to make sure that the i-index node respects the heap property and eventually swaps the nodes to make them respect it.

#	    void heapify(int *a, int n, int i) {
#	        int l = 2*i+1;	  // left child
#	        int r = l+1;	  // right child
#	        int m;
#
#	        m = (l<n && a[l]>a[i]) ? l : i;
#	        if(r<n && a[r]>a[m])
#	            m = r;
#	        if(m!=i) {
#	            swap(a,i,m);
#	            heapify(a,n,m);
#	        }
#	    }

heapify:    sll $t0, $a2, 1         # $a0->a* $a1->n $a2->i
            addi $t0, $t0, 1        # $t0->l
            addi $t1, $t0, 1        # $t1->r

            slt $t2, $t0, $a1       # l < n

            sll $t3, $t0, 2
            sub $t3, $a0, $t3
            lw $t3, 0($t3)          # $t3->a[l]

            sll $t4, $a2, 2
            sub $t4, $a0, $t4
            lw $t4, 0($t4)          # $t4->a[i]

            slt $t3, $t4, $t3       # a[i] < a[l]

            and $t2, $t2, $t3       # l < n && a[i] < a[l]

            beq $t2, $zero, m_i     # branch if (l<n && a[l]>a[i]) == FALSE
            add $s0, $t0, $zero     # $s0->m=l
            j exit_con
m_i:        add $s0, $a2, $zero     # $s0->m=i

exit_con:   slt $t5, $t1, $a1       # r < n

            sll $t3, $t1, 2
            sub $t3, $a0, $t3
            lw $t3, 0($t3)          # $t3->a[r]

            sll $t4, $s0, 2
            sub $t4, $a0, $t4
            lw $t4, 0($t4)          # $t4->a[m]

            slt $t3, $t4, $t3       # a[m] < a[r]

            and $t5, $t3, $t5       # r < n && a[m] < a[r]

            beq $t5, $zero, exit_c1 # branch if (r<n && a[r]>a[m]) == FALSE
            add $s0, $t1, $zero     # $s0->m=r
exit_c1:    beq $s0, $a2, exit_f1   # branch if (m!=i) == FALSE

            addi $sp, $sp, -20
            sw $ra, 16($sp)
            sw $a0, 12($sp)
            sw $a1, 8($sp)
            sw $a2, 4($sp)
            sw $s0, 0($sp)

            add $a1, $a2, $zero
            add $a2, $s0, $zero

            jal swap

            lw $s0, 0($sp)
            lw $a2, 4($sp)
            lw $a1, 8($sp)
            lw $a0, 12($sp)
            lw $ra, 16($sp)
            addi $sp, $sp, 20

            addi $sp, $sp, -20
            sw $ra, 16($sp)
            sw $a0, 12($sp)
            sw $a1, 8($sp)
            sw $a2, 4($sp)
            sw $s0, 0($sp)

            add $a2, $s0, $zero

            jal heapify

            lw $s0, 0($sp)
            lw $a2, 4($sp)
            lw $a1, 8($sp)
            lw $a0, 12($sp)
            lw $ra, 16($sp)
            addi $sp, $sp, 20

exit_f1:    jr $ra

            #BUILDHEAP

# This function organizes a vector of n elements into a heap data structure

#	    void buildheap(int *a, int n) {
#	        int i;
#
#	        for(i=n/2-1; i>=0; i--)
#	            heapify(a,n,i);
#	    }

buildheap:  li $s0, 2               # $a0->a* $a1->n
            div $a1, $s0
            mflo $s0
            addi $s0, $s0, -1       # $s0->i

loop_1:     bltz $s0, exit_f2       # branch if i <= 0

            addi $sp, $sp, -16
            sw $ra, 12($sp)
            sw $a0, 8($sp)
            sw $a1, 4($sp)
            sw $s0, 0($sp)

            add $a2, $s0, $zero

            jal heapify

            lw $s0, 0($sp)
            lw $a1, 4($sp)
            lw $a0, 8($sp)
            lw $ra, 12($sp)
            addi $sp, $sp, 16

            addi $s0, $s0, -1       # i--

            j loop_1

exit_f2:    jr $ra

            #HEAPSORT

# This function organizes a vector into a heap data structure and then sorts it in ascending order

#	    void heapsort(int *a, int n) {
#	        int i;
#
#	        buildheap(a,n);
#	        for(i=n-1; i; i--) {
#	            swap(a,0,i);
#	            heapify(a,i,0);
#	        }
#	    }

heapsort:   addi $sp, $sp, -12
            sw $ra, 8($sp)
            sw $a0, 4($sp)
            sw $a1, 0($sp)

            jal buildheap

            lw $a1, 0($sp)
            lw $a0, 4($sp)
            lw $ra, 8($sp)
            addi $sp, $sp, 12

            addi $s0, $a1, -1       # $s0->i

loop_2:     beq $s0, $zero, exit_f3 # branch if i == 0

            addi $sp, $sp, -16
            sw $ra, 12($sp)
            sw $a0, 8($sp)
            sw $a1, 4($sp)
            sw $s0, 0($sp)

            add $a1, $zero, $zero
            add $a2, $s0, $zero

            jal swap

            lw $s0, 0($sp)
            lw $a1, 4($sp)
            lw $a0, 8($sp)
            lw $ra, 12($sp)
            addi $sp, $sp, 16

            addi $sp, $sp, -16
            sw $ra, 12($sp)
            sw $a0, 8($sp)
            sw $a1, 4($sp)
            sw $s0, 0($sp)

            add $a1, $s0, $zero
            add $a2, $zero, $zero

            jal heapify

            lw $s0, 0($sp)
            lw $a1, 4($sp)
            lw $a0, 8($sp)
            lw $ra, 12($sp)
            addi $sp, $sp, 16

            addi $s0, $s0, -1       # i--

            j loop_2

exit_f3:    jr $ra

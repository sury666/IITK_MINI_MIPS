# Bucket sort implementation for MIPS
# Assuming array address is in $a0, size in $a1
# Using 10 buckets for sorting values between 0-99

.data
array:      .word 37, 23, 5, 89, 12, 45, 67, 98, 32, 71    # Input array
size:       .word 10                                        # Size of array
buckets:    .space 400                                      # 10 buckets, each can hold 10 elements
bucketSize: .space 40                                       # Size of each bucket (10 buckets)
result:     .space 40                                       # Sorted output array

.text
main:
    la $a0, array                 # Load address of array
    lw $a1, size                  # Load size of array
    jal bucketSort                # Call bucket sort
    j exit                        # Exit program

# Bucket sort function
bucketSort:
    # Initialize variables
    move $t0, $a0                 # $t0 = array address
    move $t1, $a1                 # $t1 = array size
    la $t2, buckets               # $t2 = buckets address
    la $t3, bucketSize            # $t3 = bucket sizes address
    
    # Initialize bucket sizes to 0
    li $t4, 0                     # $t4 = counter for buckets (0 to 9)
    
initBuckets:
    beq $t4, 10, distributeToBuckets # If all buckets initialized, move to distribution
    sll $t5, $t4, 2               # $t5 = $t4 * 4 (offset for bucket size array)
    add $t5, $t3, $t5             # $t5 = address of bucket size[i]
    sw $zero, 0($t5)              # bucketSize[i] = 0
    addi $t4, $t4, 1              # Increment counter
    j initBuckets                 # Repeat for next bucket

# Distribute elements into buckets
distributeToBuckets:
    li $t4, 0                     # $t4 = counter for array elements (0 to size-1)
    
loopDistribute:
    beq $t4, $t1, sortBuckets     # If all elements distributed, proceed to sort
    
    # Get the current array element
    sll $t5, $t4, 2               # $t5 = $t4 * 4 (offset for array)
    add $t5, $t0, $t5             # $t5 = address of array[i]
    lw $t6, 0($t5)                # $t6 = array[i]
    
    # Calculate bucket index: value / 10
    div $t6, $t6, 10              # $t6 = array[i] / 10 (bucket index)
    mflo $t7                      # $t7 = bucket index
    
    # Find current bucket size
    sll $t8, $t7, 2               # $t8 = bucket index * 4 (offset for bucket size array)
    add $t8, $t3, $t8             # $t8 = address of bucketSize[bucket]
    lw $t9, 0($t8)                # $t9 = current size of bucket
    
    # Calculate position in bucket array
    mul $s0, $t7, 40              # $s0 = bucket index * 40 (each bucket can hold 10 elements)
    sll $s1, $t9, 2               # $s1 = current size * 4 (offset within bucket)
    add $s0, $s0, $s1             # $s0 = total offset in bucket array
    add $s0, $t2, $s0             # $s0 = address where to store in bucket
    
    # Store element in bucket
    lw $t6, 0($t5)                # Reload the original value
    sw $t6, 0($s0)                # buckets[bucket][size] = array[i]
    
    # Increment bucket size
    addi $t9, $t9, 1              # Increment size
    sw $t9, 0($t8)                # Update size in memory
    
    # Move to next array element
    addi $t4, $t4, 1              # Increment counter
    j loopDistribute              # Repeat for next element

# Sort each bucket (using insertion sort for simplicity)
sortBuckets:
    li $t4, 0                     # $t4 = bucket counter (0 to 9)
    
bucketLoop:
    beq $t4, 10, mergeBuckets     # If all buckets sorted, merge them
    
    # Get bucket size
    sll $t5, $t4, 2               # $t5 = bucket index * 4
    add $t5, $t3, $t5             # $t5 = address of bucketSize[bucket]
    lw $t6, 0($t5)                # $t6 = size of current bucket
    
    # Calculate bucket start address
    mul $t7, $t4, 40              # $t7 = bucket index * 40
    add $t7, $t2, $t7             # $t7 = address of bucket[bucketIndex][0]
    
    # Insertion sort for current bucket
    li $t8, 1                     # $t8 = i (starting from 1)
    
insertionSort:
    beq $t8, $t6, nextBucket      # If i == bucketSize, move to next bucket
    
    sll $t9, $t8, 2               # $t9 = i * 4
    add $t9, $t7, $t9             # $t9 = address of bucket[bucketIndex][i]
    lw $s0, 0($t9)                # $s0 = key = bucket[bucketIndex][i]
    
    add $s1, $t8, -1              # $s1 = j = i - 1
    
insertionLoop:
    bltz $s1, insertionEnd        # If j < 0, end insertion for current element
    
    sll $s2, $s1, 2               # $s2 = j * 4
    add $s2, $t7, $s2             # $s2 = address of bucket[bucketIndex][j]
    lw $s3, 0($s2)                # $s3 = bucket[bucketIndex][j]
    
    ble $s3, $s0, insertionEnd    # If bucket[j] <= key, end insertion
    
    # Move elements
    sll $s4, $s1, 2               # $s4 = j * 4
    addi $s4, $s4, 4              # $s4 = (j+1) * 4
    add $s4, $t7, $s4             # $s4 = address of bucket[bucketIndex][j+1]
    sw $s3, 0($s4)                # bucket[bucketIndex][j+1] = bucket[bucketIndex][j]
    
    addi $s1, $s1, -1             # j--
    j insertionLoop               # Continue insertion loop
    
insertionEnd:
    addi $s1, $s1, 1              # j++
    sll $s4, $s1, 2               # $s4 = (j) * 4
    add $s4, $t7, $s4             # $s4 = address of bucket[bucketIndex][j]
    sw $s0, 0($s4)                # bucket[bucketIndex][j] = key
    
    addi $t8, $t8, 1              # i++
    j insertionSort               # Continue insertion sort
    
nextBucket:
    addi $t4, $t4, 1              # Move to next bucket
    j bucketLoop                  # Repeat for next bucket

# Merge sorted buckets back into original array
mergeBuckets:
    li $t4, 0                     # $t4 = bucket counter (0 to 9)
    li $t5, 0                     # $t5 = position in result array
    
mergeBucketLoop:
    beq $t4, 10, copyResult       # If all buckets merged, copy to original array
    
    # Get bucket size
    sll $t6, $t4, 2               # $t6 = bucket index * 4
    add $t6, $t3, $t6             # $t6 = address of bucketSize[bucket]
    lw $t7, 0($t6)                # $t7 = size of current bucket
    
    # Calculate bucket start address
    mul $t8, $t4, 40              # $t8 = bucket index * 40
    add $t8, $t2, $t8             # $t8 = address of bucket[bucketIndex][0]
    
    # Copy elements from bucket to result array
    li $t9, 0                     # $t9 = element counter in bucket
    
copyBucketLoop:
    beq $t9, $t7, nextMergeBucket # If all elements copied, move to next bucket
    
    # Get element from bucket
    sll $s0, $t9, 2               # $s0 = element index * 4
    add $s0, $t8, $s0             # $s0 = address of bucket[bucketIndex][element]
    lw $s1, 0($s0)                # $s1 = bucket[bucketIndex][element]
    
    # Store in result array
    sll $s2, $t5, 2               # $s2 = position in result * 4
    add $s2, $a0, $s2             # $s2 = address in result array
    sw $s1, 0($s2)                # result[position] = bucket[bucketIndex][element]
    
    addi $t5, $t5, 1              # Increment position in result
    addi $t9, $t9, 1              # Increment element counter
    j copyBucketLoop              # Continue copying elements
    
nextMergeBucket:
    addi $t4, $t4, 1              # Move to next bucket
    j mergeBucketLoop             # Repeat for next bucket

copyResult:
    # No need to copy since we've directly written back to the original array
    jr $ra                        # Return from function

exit:
    # End of program
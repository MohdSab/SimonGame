.data
sequence:  .byte 0,0,0,0
count:     .word 4
newline: .string "\n"
black: .word 0x000000
yellow: .word 0xf3f300
red: .word 0xe20000
green: .word 0x00f500
blue: .word 0x0000ee
playAgainPromptA: .string "\nPress LEFT/RIGHT on the D-pad to exit the game.\n"
playAgainPromptB: .string "To play the game again press the UP on the D-pad to increase the sequence count,\n"
playAgainPromptC: .string "or DOWN on the D-pad to keep the same sequence count.\n"
welcomePrompt: .string "Welcome to this Simon game, please set the I/O to anable a 10x10 LED grid and a D-pad (refer to manual)\nIf the LEDs are not working properly, please restart RIPES.\n\nA sequence of 4 colour will be displayed, try to match it.\n\nPress ANY arrow on the D-pad to start."
success: .string "\n\nCORRECT!\n\n"
fail: .string "\n\nTHAT WAS WRONG\n\n"
recorded: .string "\nNext?\n"
curr: .string "The current sequence count:"
start: .string "\nWhat was the first step?\n"

.globl main
.text

main:
    # TODO: Before we deal with the LEDs, we need to generate a random
    # sequence of numbers that we will use to indicate the button/LED
    # to light up. For example, we can have 0 for UP, 1 for DOWN, 2 for
    # LEFT, and 3 for RIGHT. Store the sequence in memory. We provided 
    # a declaration above that you can use if you want.
    # HINT: Use the rand function provided to generate each number
    
    
    jal allBlack
    
    li a7, 4
    la a0, welcomePrompt
    ecall
    
    jal pollDpad
    
    la t6, sequence #sequence to t6 
    lw t5, count #count to t5 
    
    repeat:
        
        jal allBlack
        
        li t4, 0 #loop counter
        mv t3, t6 #temp address to parse
        
    sequenceLoop:
        beq t4, t5, sequenceLoopEnd
        
        li a0, 1
        jal delay
        
        li a0, 4 #load a0 for rand
        jal rand
        sb a0, 0(t3) #store byte
        
        addi t3, t3, 1
        
        addi t4, t4, 1
        j sequenceLoop
        
    sequenceLoopEnd:
    
    li a7, 4
    la a0, newline
    ecall
    
    
    # TODO: Now read the sequence and replay it on the LEDs. You will
    # need to use the delay function to ensure that the LEDs light up 
    # slowly. In general, for each number in the sequence you should:
    # 1. Figure out the corresponding LED location and colour
    # 2. Light up the appropriate LED (with the colour)
    # 2. Wait for a short delay (e.g. 500 ms)
    # 3. Turn off the LED (i.e. set it to black)
    # 4. Wait for a short delay (e.g. 1000 ms) before repeating

    jal allBlack
    li t4, 0 #loop counter
    mv t3, t6 #temp address to parse
    
    showSequenceLoop:
        beq t4, t5, showSequenceLoopEnd
        
        lb t1, 0(t3)
        jal whereToBlink
        
        addi t3, t3, 1
        
        addi t4, t4, 1
        j showSequenceLoop
        
    showSequenceLoopEnd:
    
        li a7, 4
        la a0, start
        ecall
    
    # TODO: Read through the sequence again and check for user input
    # using pollDpad. For each number in the sequence, check the d-pad
    # input and compare it against the sequence. If the input does not
    # match, display some indication of error on the LEDs and exit. 
    # Otherwise, keep checking the rest of the sequence and display 
    # some indication of success once you reach the end.
    
    jal allBlack
    li t4, 0 #loop counter
    mv s6, t6 #temp address to parse
        
    readInputLoop:
        beq t4, t5, successScreen
        lb s5, 0(s6)
        
        jal pollDpad
        mv s9, a0
        
        bne s9, s5, failScreen
        
        li a7, 4
        la a0, recorded
        ecall
        
        addi s6, s6, 1
        
        addi t4, t4, 1
        j readInputLoop
        
    successScreen:
        jal allBlack
        jal allGreen
        li a0, 400
        jal delay
        jal allBlack
        li a0, 400
        jal delay
        jal allGreen
        
        li a7, 4
        la a0, success
        ecall
        
        j endRun
        
    failScreen:
        jal allBlack
        jal allRed
        li a0, 400
        jal delay
        jal allBlack
        li a0, 400
        jal delay
        jal allRed
        li a0, 400
        jal delay
        jal allBlack
        li a0, 400
        jal delay
        jal allRed
        
        li a7, 4
        la a0, fail
        ecall

    endRun:
        

    # TODO: Ask if the user wishes to play again and either loop back to
    # start a new round or terminate, based on their input.
    
    li a7, 4
    la a0, curr
    ecall
    
    li a7, 1
    mv a0, t5
    ecall
    
    li a7, 4
    la a0, newline
    ecall
    
    li a7, 4
    la a0, newline
    ecall
    
    li a7, 4
    la a0, playAgainPromptA
    ecall
    li a7, 4
    la a0, playAgainPromptB
    ecall
    li a7, 4
    la a0, playAgainPromptC
    ecall
    
    li a7, 4
    la a0, newline
    ecall
    
    li s4, 0
    li s5, 1
    
    jal pollDpad
    
    beq a0, s4, increaseRepeat
    beq a0, s5, repeat
 
exit:
    li a7, 10
    ecall
    
increaseRepeat:
    addi t5, t5, 1
    j repeat
    
    
# --- HELPER FUNCTIONS ---
# Feel free to use (or modify) them however you see fit
     
# Takes in the number of milliseconds to wait (in a0) before returning
delay:
    mv t0, a0
    li a7, 30
    ecall
    mv t1, a0
delayLoop:
    ecall
    sub t2, a0, t1
    bgez t2, delayIfEnd
    addi t2, t2, -1
delayIfEnd:
    bltu t2, t0, delayLoop
    jr ra

# Takes in a number in a0, and returns a (sort of) random number from 0 to
# this number (exclusive)
rand:
    mv t0, a0
    li a7, 30
    ecall
    remu a0, a0, t0
    jr ra
    
# Takes in an RGB color in a0, an x-coordinate in a1, and a y-coordinate
# in a2. Then it sets the led at (x, y) to the given color.
setLED:
    li t1, LED_MATRIX_0_WIDTH
    mul t0, a2, t1
    add t0, t0, a1
    li t1, 4
    mul t0, t0, t1
    li t1, LED_MATRIX_0_BASE
    add t0, t1, t0
    sw a0, (0)t0
    jr ra
    
# Polls the d-pad input until a button is pressed, then returns a number
# representing the button that was pressed in a0.
# The possible return values are:
# 0: UP
# 1: DOWN
# 2: LEFT
# 3: RIGHT
pollDpad:
    mv a0, zero
    li t1, 4
pollLoop:
    bge a0, t1, pollLoopEnd
    li t2, D_PAD_0_BASE
    slli t3, a0, 2
    add t2, t2, t3
    lw t3, (0)t2
    bnez t3, pollRelease
    addi a0, a0, 1
    j pollLoop
pollLoopEnd:
    j pollDpad
pollRelease:
    lw t3, (0)t2
    bnez t3, pollRelease
pollExit:
    jr ra
    
    
whereToBlink:
    mv s3, ra
    li s4, 0
    li s5, 1
    li s6, 2
    li s7, 3
    beq t1, s4, topRed
    beq t1, s5, bottomGreen
    beq t1, s6, leftYellow
    beq t1, s7, rightBlue
    jr s3
    
    
########################################################################################

                             # below is the 10x10 LED grid setup #
                                     # FYI: Its very long! #

########################################################################################    

leftYellow:
    mv s2, ra
    
    li a1, 0
    li a2, 0
    lw a0, yellow
    jal setLED
    li a1, 0
    li a2, 1
    lw a0, yellow
    jal setLED
    li a1, 0
    li a2, 2
    lw a0, yellow
    jal setLED
    li a1, 0
    li a2, 3
    lw a0, yellow
    jal setLED
    li a1, 0
    li a2, 4
    lw a0, yellow
    jal setLED
    li a1, 0
    li a2, 5
    lw a0, yellow
    jal setLED
    li a1, 0
    li a2, 6
    lw a0, yellow
    jal setLED
    li a1, 0
    li a2, 7
    lw a0, yellow
    jal setLED
    li a1, 0
    li a2, 8
    lw a0, yellow
    jal setLED
    li a1, 0
    li a2, 9
    lw a0, yellow
    jal setLED
    li a1, 1
    li a2, 1
    lw a0, yellow
    jal setLED
    li a1, 1
    li a2, 2
    lw a0, yellow
    jal setLED
    li a1, 1
    li a2, 3
    lw a0, yellow
    jal setLED
    li a1, 1
    li a2, 4
    lw a0, yellow
    jal setLED
    li a1, 1
    li a2, 5
    lw a0, yellow
    jal setLED
    li a1, 1
    li a2, 6
    lw a0, yellow
    jal setLED
    li a1, 1
    li a2, 7
    lw a0, yellow
    jal setLED
    li a1, 1
    li a2, 8
    lw a0, yellow
    jal setLED
    li a1, 2
    li a2, 2
    lw a0, yellow
    jal setLED
    li a1, 2
    li a2, 3
    lw a0, yellow
    jal setLED
    li a1, 2
    li a2, 4
    lw a0, yellow
    jal setLED
    li a1, 2
    li a2, 5
    lw a0, yellow
    jal setLED
    li a1, 2
    li a2, 6
    lw a0, yellow
    jal setLED
    li a1, 2
    li a2, 7
    lw a0, yellow
    jal setLED
    li a1, 3
    li a2, 3
    lw a0, yellow
    jal setLED
    li a1, 3
    li a2, 4
    lw a0, yellow
    jal setLED
    li a1, 3
    li a2, 5
    lw a0, yellow
    jal setLED
    li a1, 3
    li a2, 6
    lw a0, yellow
    jal setLED
    li a1, 4
    li a2, 4
    lw a0, yellow
    jal setLED
    li a1, 4
    li a2, 5
    lw a0, yellow
    jal setLED
    
    li a0, 500
    jal delay
    
    li a1, 0
    li a2, 0
    lw a0, black
    jal setLED
    li a1, 0
    li a2, 1
    lw a0, black
    jal setLED
    li a1, 0
    li a2, 2
    lw a0, black
    jal setLED
    li a1, 0
    li a2, 3
    lw a0, black
    jal setLED
    li a1, 0
    li a2, 4
    lw a0, black
    jal setLED
    li a1, 0
    li a2, 5
    lw a0, black
    jal setLED
    li a1, 0
    li a2, 6
    lw a0, black
    jal setLED
    li a1, 0
    li a2, 7
    lw a0, black
    jal setLED
    li a1, 0
    li a2, 8
    lw a0, black
    jal setLED
    li a1, 0
    li a2, 9
    lw a0, black
    jal setLED
    li a1, 1
    li a2, 1
    lw a0, black
    jal setLED
    li a1, 1
    li a2, 2
    lw a0, black
    jal setLED
    li a1, 1
    li a2, 3
    lw a0, black
    jal setLED
    li a1, 1
    li a2, 4
    lw a0, black
    jal setLED
    li a1, 1
    li a2, 5
    lw a0, black
    jal setLED
    li a1, 1
    li a2, 6
    lw a0, black
    jal setLED
    li a1, 1
    li a2, 7
    lw a0, black
    jal setLED
    li a1, 1
    li a2, 8
    lw a0, black
    jal setLED
    li a1, 2
    li a2, 2
    lw a0, black
    jal setLED
    li a1, 2
    li a2, 3
    lw a0, black
    jal setLED
    li a1, 2
    li a2, 4
    lw a0, black
    jal setLED
    li a1, 2
    li a2, 5
    lw a0, black
    jal setLED
    li a1, 2
    li a2, 6
    lw a0, black
    jal setLED
    li a1, 2
    li a2, 7
    lw a0, black
    jal setLED
    li a1, 3
    li a2, 3
    lw a0, black
    jal setLED
    li a1, 3
    li a2, 4
    lw a0, black
    jal setLED
    li a1, 3
    li a2, 5
    lw a0, black
    jal setLED
    li a1, 3
    li a2, 6
    lw a0, black
    jal setLED
    li a1, 4
    li a2, 4
    lw a0, black
    jal setLED
    li a1, 4
    li a2, 5
    lw a0, black
    jal setLED
    
    li a0, 1000
    jal delay
    
    jr s2
    
topRed:
    mv s2, ra
    
    li a1, 0
    li a2, 0
    lw a0, red
    jal setLED
    li a1, 1
    li a2, 0
    lw a0, red
    jal setLED
    li a1, 2
    li a2, 0
    lw a0, red
    jal setLED
    li a1, 3
    li a2, 0
    lw a0, red
    jal setLED
    li a1, 4
    li a2, 0
    lw a0, red
    jal setLED
    li a1, 5
    li a2, 0
    lw a0, red
    jal setLED
    li a1, 6
    li a2, 0
    lw a0, red
    jal setLED
    li a1, 7
    li a2, 0
    lw a0, red
    jal setLED
    li a1, 8
    li a2, 0
    lw a0, red
    jal setLED
    li a1, 9
    li a2, 0
    lw a0, red
    jal setLED
    li a1, 1
    li a2, 1
    lw a0, red
    jal setLED
    li a1, 2
    li a2, 1
    lw a0, red
    jal setLED
    li a1, 3
    li a2, 1
    lw a0, red
    jal setLED
    li a1, 4
    li a2, 1
    lw a0, red
    jal setLED
    li a1, 5
    li a2, 1
    lw a0, red
    jal setLED
    li a1, 6
    li a2, 1
    lw a0, red
    jal setLED
    li a1, 7
    li a2, 1
    lw a0, red
    jal setLED
    li a1, 8
    li a2, 1
    lw a0, red
    jal setLED
    li a1, 2
    li a2, 2
    lw a0, red
    jal setLED
    li a1, 3
    li a2, 2
    lw a0, red
    jal setLED
    li a1, 4
    li a2, 2
    lw a0, red
    jal setLED
    li a1, 5
    li a2, 2
    lw a0, red
    jal setLED
    li a1, 6
    li a2, 2
    lw a0, red
    jal setLED
    li a1, 7
    li a2, 2
    lw a0, red
    jal setLED
    li a1, 3
    li a2, 3
    lw a0, red
    jal setLED
    li a1, 4
    li a2, 3
    lw a0, red
    jal setLED
    li a1, 5
    li a2, 3
    lw a0, red
    jal setLED
    li a1, 6
    li a2, 3
    lw a0, red
    jal setLED
    li a1, 4
    li a2, 4
    lw a0, red
    jal setLED
    li a1, 5
    li a2, 4
    lw a0, red
    jal setLED
    
    
    li a0, 500
    jal delay
    
    li a1, 0
    li a2, 0
    lw a0, black
    jal setLED
    li a1, 1
    li a2, 0
    lw a0, black
    jal setLED
    li a1, 2
    li a2, 0
    lw a0, black
    jal setLED
    li a1, 3
    li a2, 0
    lw a0, black
    jal setLED
    li a1, 4
    li a2, 0
    lw a0, black
    jal setLED
    li a1, 5
    li a2, 0
    lw a0, black
    jal setLED
    li a1, 6
    li a2, 0
    lw a0, black
    jal setLED
    li a1, 7
    li a2, 0
    lw a0, black
    jal setLED
    li a1, 8
    li a2, 0
    lw a0, black
    jal setLED
    li a1, 9
    li a2, 0
    lw a0, black
    jal setLED
    li a1, 1
    li a2, 1
    lw a0, black
    jal setLED
    li a1, 2
    li a2, 1
    lw a0, black
    jal setLED
    li a1, 3
    li a2, 1
    lw a0, black
    jal setLED
    li a1, 4
    li a2, 1
    lw a0, black
    jal setLED
    li a1, 5
    li a2, 1
    lw a0, black
    jal setLED
    li a1, 6
    li a2, 1
    lw a0, black
    jal setLED
    li a1, 7
    li a2, 1
    lw a0, black
    jal setLED
    li a1, 8
    li a2, 1
    lw a0, black
    jal setLED
    li a1, 2
    li a2, 2
    lw a0, black
    jal setLED
    li a1, 3
    li a2, 2
    lw a0, black
    jal setLED
    li a1, 4
    li a2, 2
    lw a0, black
    jal setLED
    li a1, 5
    li a2, 2
    lw a0, black
    jal setLED
    li a1, 6
    li a2, 2
    lw a0, black
    jal setLED
    li a1, 7
    li a2, 2
    lw a0, black
    jal setLED
    li a1, 3
    li a2, 3
    lw a0, black
    jal setLED
    li a1, 4
    li a2, 3
    lw a0, black
    jal setLED
    li a1, 5
    li a2, 3
    lw a0, black
    jal setLED
    li a1, 6
    li a2, 3
    lw a0, black
    jal setLED
    li a1, 4
    li a2, 4
    lw a0, black
    jal setLED
    li a1, 5
    li a2, 4
    lw a0, black
    jal setLED

    li a0, 1000
    jal delay
    
    jr s2
    
rightBlue:
    mv s2, ra
    
    li a1, 9
    li a2, 0
    lw a0, blue
    jal setLED
    li a1, 9
    li a2, 1
    lw a0, blue
    jal setLED
    li a1, 9
    li a2, 2
    lw a0, blue
    jal setLED
    li a1, 9
    li a2, 3
    lw a0, blue
    jal setLED
    li a1, 9
    li a2, 4
    lw a0, blue
    jal setLED
    li a1, 9
    li a2, 5
    lw a0, blue
    jal setLED
    li a1, 9
    li a2, 6
    lw a0, blue
    jal setLED
    li a1, 9
    li a2, 7
    lw a0, blue
    jal setLED
    li a1, 9
    li a2, 8
    lw a0, blue
    jal setLED
    li a1, 9
    li a2, 9
    lw a0, blue
    jal setLED
    li a1, 8
    li a2, 1
    lw a0, blue
    jal setLED
    li a1, 8
    li a2, 2
    lw a0, blue
    jal setLED
    li a1, 8
    li a2, 3
    lw a0, blue
    jal setLED
    li a1, 8
    li a2, 4
    lw a0, blue
    jal setLED
    li a1, 8
    li a2, 5
    lw a0, blue
    jal setLED
    li a1, 8
    li a2, 6
    lw a0, blue
    jal setLED
    li a1, 8
    li a2, 7
    lw a0, blue
    jal setLED
    li a1, 8
    li a2, 8
    lw a0, blue
    jal setLED
    li a1, 7
    li a2, 2
    lw a0, blue
    jal setLED
    li a1, 7
    li a2, 3
    lw a0, blue
    jal setLED
    li a1, 7
    li a2, 4
    lw a0, blue
    jal setLED
    li a1, 7
    li a2, 5
    lw a0, blue
    jal setLED
    li a1, 7
    li a2, 6
    lw a0, blue
    jal setLED
    li a1, 7
    li a2, 7
    lw a0, blue
    jal setLED
    li a1, 6
    li a2, 3
    lw a0, blue
    jal setLED
    li a1, 6
    li a2, 4
    lw a0, blue
    jal setLED
    li a1, 6
    li a2, 5
    lw a0, blue
    jal setLED
    li a1, 6
    li a2, 6
    lw a0, blue
    jal setLED
    li a1, 5
    li a2, 4
    lw a0, blue
    jal setLED
    li a1, 5
    li a2, 5
    lw a0, blue
    jal setLED
    
    
    li a0, 500
    jal delay
    
    li a1, 9
    li a2, 0
    lw a0, black
    jal setLED
    li a1, 9
    li a2, 1
    lw a0, black
    jal setLED
    li a1, 9
    li a2, 2
    lw a0, black
    jal setLED
    li a1, 9
    li a2, 3
    lw a0, black
    jal setLED
    li a1, 9
    li a2, 4
    lw a0, black
    jal setLED
    li a1, 9
    li a2, 5
    lw a0, black
    jal setLED
    li a1, 9
    li a2, 6
    lw a0, black
    jal setLED
    li a1, 9
    li a2, 7
    lw a0, black
    jal setLED
    li a1, 9
    li a2, 8
    lw a0, black
    jal setLED
    li a1, 9
    li a2, 9
    lw a0, black
    jal setLED
    li a1, 8
    li a2, 1
    lw a0, black
    jal setLED
    li a1, 8
    li a2, 2
    lw a0, black
    jal setLED
    li a1, 8
    li a2, 3
    lw a0, black
    jal setLED
    li a1, 8
    li a2, 4
    lw a0, black
    jal setLED
    li a1, 8
    li a2, 5
    lw a0, black
    jal setLED
    li a1, 8
    li a2, 6
    lw a0, black
    jal setLED
    li a1, 8
    li a2, 7
    lw a0, black
    jal setLED
    li a1, 8
    li a2, 8
    lw a0, black
    jal setLED
    li a1, 7
    li a2, 2
    lw a0, black
    jal setLED
    li a1, 7
    li a2, 3
    lw a0, black
    jal setLED
    li a1, 7
    li a2, 4
    lw a0, black
    jal setLED
    li a1, 7
    li a2, 5
    lw a0, black
    jal setLED
    li a1, 7
    li a2, 6
    lw a0, black
    jal setLED
    li a1, 7
    li a2, 7
    lw a0, black
    jal setLED
    li a1, 6
    li a2, 3
    lw a0, black
    jal setLED
    li a1, 6
    li a2, 4
    lw a0, black
    jal setLED
    li a1, 6
    li a2, 5
    lw a0, black
    jal setLED
    li a1, 6
    li a2, 6
    lw a0, black
    jal setLED
    li a1, 5
    li a2, 4
    lw a0, black
    jal setLED
    li a1, 5
    li a2, 5
    lw a0, black
    jal setLED
    
    li a0, 1000
    jal delay
    
    jr s2
    
bottomGreen:
    mv s2, ra
    
    li a1, 0
    li a2, 9
    lw a0, green
    jal setLED
    li a1, 1
    li a2, 9
    lw a0, green
    jal setLED
    li a1, 2
    li a2, 9
    lw a0, green
    jal setLED
    li a1, 3
    li a2, 9
    lw a0, green
    jal setLED
    li a1, 4
    li a2, 9
    lw a0, green
    jal setLED
    li a1, 5
    li a2, 9
    lw a0, green
    jal setLED
    li a1, 6
    li a2, 9
    lw a0, green
    jal setLED
    li a1, 7
    li a2, 9
    lw a0, green
    jal setLED
    li a1, 8
    li a2, 9
    lw a0, green
    jal setLED
    li a1, 9
    li a2, 9
    lw a0, green
    jal setLED
    li a1, 1
    li a2, 8
    lw a0, green
    jal setLED
    li a1, 2
    li a2, 8
    lw a0, green
    jal setLED
    li a1, 3
    li a2, 8
    lw a0, green
    jal setLED
    li a1, 4
    li a2, 8
    lw a0, green
    jal setLED
    li a1, 5
    li a2, 8
    lw a0, green
    jal setLED
    li a1, 6
    li a2, 8
    lw a0, green
    jal setLED
    li a1, 7
    li a2, 8
    lw a0, green
    jal setLED
    li a1, 8
    li a2, 8
    lw a0, green
    jal setLED
    li a1, 2
    li a2, 7
    lw a0, green
    jal setLED
    li a1, 3
    li a2, 7
    lw a0, green
    jal setLED
    li a1, 4
    li a2, 7
    lw a0, green
    jal setLED
    li a1, 5
    li a2, 7
    lw a0, green
    jal setLED
    li a1, 6
    li a2, 7
    lw a0, green
    jal setLED
    li a1, 7
    li a2, 7
    lw a0, green
    jal setLED
    li a1, 3
    li a2, 6
    lw a0, green
    jal setLED
    li a1, 4
    li a2, 6
    lw a0, green
    jal setLED
    li a1, 5
    li a2, 6
    lw a0, green
    jal setLED
    li a1, 6
    li a2, 6
    lw a0, green
    jal setLED
    li a1, 4
    li a2, 5
    lw a0, green
    jal setLED
    li a1, 5
    li a2, 5
    lw a0, green
    jal setLED
    
    li a0, 500
    jal delay
    
    li a1, 0
    li a2, 9
    lw a0, black
    jal setLED
    li a1, 1
    li a2, 9
    lw a0, black
    jal setLED
    li a1, 2
    li a2, 9
    lw a0, black
    jal setLED
    li a1, 3
    li a2, 9
    lw a0, black
    jal setLED
    li a1, 4
    li a2, 9
    lw a0, black
    jal setLED
    li a1, 5
    li a2, 9
    lw a0, black
    jal setLED
    li a1, 6
    li a2, 9
    lw a0, black
    jal setLED
    li a1, 7
    li a2, 9
    lw a0, black
    jal setLED
    li a1, 8
    li a2, 9
    lw a0, black
    jal setLED
    li a1, 9
    li a2, 9
    lw a0, black
    jal setLED
    li a1, 1
    li a2, 8
    lw a0, black
    jal setLED
    li a1, 2
    li a2, 8
    lw a0, black
    jal setLED
    li a1, 3
    li a2, 8
    lw a0, black
    jal setLED
    li a1, 4
    li a2, 8
    lw a0, black
    jal setLED
    li a1, 5
    li a2, 8
    lw a0, black
    jal setLED
    li a1, 6
    li a2, 8
    lw a0, black
    jal setLED
    li a1, 7
    li a2, 8
    lw a0, black
    jal setLED
    li a1, 8
    li a2, 8
    lw a0, black
    jal setLED
    li a1, 2
    li a2, 7
    lw a0, black
    jal setLED
    li a1, 3
    li a2, 7
    lw a0, black
    jal setLED
    li a1, 4
    li a2, 7
    lw a0, black
    jal setLED
    li a1, 5
    li a2, 7
    lw a0, black
    jal setLED
    li a1, 6
    li a2, 7
    lw a0, black
    jal setLED
    li a1, 7
    li a2, 7
    lw a0, black
    jal setLED
    li a1, 3
    li a2, 6
    lw a0, black
    jal setLED
    li a1, 4
    li a2, 6
    lw a0, black
    jal setLED
    li a1, 5
    li a2, 6
    lw a0, black
    jal setLED
    li a1, 6
    li a2, 6
    lw a0, black
    jal setLED
    li a1, 4
    li a2, 5
    lw a0, black
    jal setLED
    li a1, 5
    li a2, 5
    lw a0, black
    jal setLED
    
    li a0, 1000
    jal delay
    
    jr s2
    
allBlack:
    mv s2, ra
    
    li a1, 0
    li a2, 0
    lw a0, black
    jal setLED    
    li a1, 0
    li a2, 1
    lw a0, black
    jal setLED    
    li a1, 0
    li a2, 2
    lw a0, black
    jal setLED    
    li a1, 0
    li a2, 3
    lw a0, black
    jal setLED    
    li a1, 0
    li a2, 4
    lw a0, black
    jal setLED    
    li a1, 0
    li a2, 5
    lw a0, black
    jal setLED    
    li a1, 0
    li a2, 6
    lw a0, black
    jal setLED    
    li a1, 0
    li a2, 7
    lw a0, black
    jal setLED    
    li a1, 0
    li a2, 8
    lw a0, black
    jal setLED    
    li a1, 0
    li a2, 9
    lw a0, black
    jal setLED    
    li a1, 1
    li a2, 0
    lw a0, black
    jal setLED    
    li a1, 1
    li a2, 1
    lw a0, black
    jal setLED    
    li a1, 1
    li a2, 2
    lw a0, black
    jal setLED    
    li a1, 1
    li a2, 3
    lw a0, black
    jal setLED    
    li a1, 1
    li a2, 4
    lw a0, black
    jal setLED    
    li a1, 1
    li a2, 5
    lw a0, black
    jal setLED    
    li a1, 1
    li a2, 6
    lw a0, black
    jal setLED    
    li a1, 1
    li a2, 7
    lw a0, black
    jal setLED    
    li a1, 1
    li a2, 8
    lw a0, black
    jal setLED    
    li a1, 1
    li a2, 9
    lw a0, black
    jal setLED    
    li a1, 2
    li a2, 0
    lw a0, black
    jal setLED    
    li a1, 2
    li a2, 1
    lw a0, black
    jal setLED    
    li a1, 2
    li a2, 2
    lw a0, black
    jal setLED    
    li a1, 2
    li a2, 3
    lw a0, black
    jal setLED    
    li a1, 2
    li a2, 4
    lw a0, black
    jal setLED    
    li a1, 2
    li a2, 5
    lw a0, black
    jal setLED    
    li a1, 2
    li a2, 6
    lw a0, black
    jal setLED    
    li a1, 2
    li a2, 7
    lw a0, black
    jal setLED    
    li a1, 2
    li a2, 8
    lw a0, black
    jal setLED    
    li a1, 2
    li a2, 9
    lw a0, black
    jal setLED    
    li a1, 3
    li a2, 0
    lw a0, black
    jal setLED    
    li a1, 3
    li a2, 1
    lw a0, black
    jal setLED    
    li a1, 3
    li a2, 2
    lw a0, black
    jal setLED    
    li a1, 3
    li a2, 3
    lw a0, black
    jal setLED    
    li a1, 3
    li a2, 4
    lw a0, black
    jal setLED    
    li a1, 3
    li a2, 5
    lw a0, black
    jal setLED    
    li a1, 3
    li a2, 6
    lw a0, black
    jal setLED    
    li a1, 3
    li a2, 7
    lw a0, black
    jal setLED    
    li a1, 3
    li a2, 8
    lw a0, black
    jal setLED    
    li a1, 3
    li a2, 9
    lw a0, black
    jal setLED    
    li a1, 4
    li a2, 0
    lw a0, black
    jal setLED    
    li a1, 4
    li a2, 1
    lw a0, black
    jal setLED    
    li a1, 4
    li a2, 2
    lw a0, black
    jal setLED    
    li a1, 4
    li a2, 3
    lw a0, black
    jal setLED    
    li a1, 4
    li a2, 4
    lw a0, black
    jal setLED    
    li a1, 4
    li a2, 5
    lw a0, black
    jal setLED    
    li a1, 4
    li a2, 6
    lw a0, black
    jal setLED    
    li a1, 4
    li a2, 7
    lw a0, black
    jal setLED    
    li a1, 4
    li a2, 8
    lw a0, black
    jal setLED    
    li a1, 4
    li a2, 9
    lw a0, black
    jal setLED    
    li a1, 5
    li a2, 0
    lw a0, black
    jal setLED    
    li a1, 5
    li a2, 1
    lw a0, black
    jal setLED    
    li a1, 5
    li a2, 2
    lw a0, black
    jal setLED    
    li a1, 5
    li a2, 3
    lw a0, black
    jal setLED    
    li a1, 5
    li a2, 4
    lw a0, black
    jal setLED    
    li a1, 5
    li a2, 5
    lw a0, black
    jal setLED    
    li a1, 5
    li a2, 6
    lw a0, black
    jal setLED    
    li a1, 5
    li a2, 7
    lw a0, black
    jal setLED    
    li a1, 5
    li a2, 8
    lw a0, black
    jal setLED    
    li a1, 5
    li a2, 9
    lw a0, black
    jal setLED    
    li a1, 6
    li a2, 0
    lw a0, black
    jal setLED    
    li a1, 6
    li a2, 1
    lw a0, black
    jal setLED    
    li a1, 6
    li a2, 2
    lw a0, black
    jal setLED    
    li a1, 6
    li a2, 3
    lw a0, black
    jal setLED    
    li a1, 6
    li a2, 4
    lw a0, black
    jal setLED    
    li a1, 6
    li a2, 5
    lw a0, black
    jal setLED    
    li a1, 6
    li a2, 6
    lw a0, black
    jal setLED    
    li a1, 6
    li a2, 7
    lw a0, black
    jal setLED    
    li a1, 6
    li a2, 8
    lw a0, black
    jal setLED    
    li a1, 6
    li a2, 9
    lw a0, black
    jal setLED    
    li a1, 7
    li a2, 0
    lw a0, black
    jal setLED    
    li a1, 7
    li a2, 1
    lw a0, black
    jal setLED    
    li a1, 7
    li a2, 2
    lw a0, black
    jal setLED    
    li a1, 7
    li a2, 3
    lw a0, black
    jal setLED    
    li a1, 7
    li a2, 4
    lw a0, black
    jal setLED    
    li a1, 7
    li a2, 5
    lw a0, black
    jal setLED    
    li a1, 7
    li a2, 6
    lw a0, black
    jal setLED    
    li a1, 7
    li a2, 7
    lw a0, black
    jal setLED    
    li a1, 7
    li a2, 8
    lw a0, black
    jal setLED    
    li a1, 7
    li a2, 9
    lw a0, black
    jal setLED    
    li a1, 8
    li a2, 0
    lw a0, black
    jal setLED    
    li a1, 8
    li a2, 1
    lw a0, black
    jal setLED    
    li a1, 8
    li a2, 2
    lw a0, black
    jal setLED    
    li a1, 8
    li a2, 3
    lw a0, black
    jal setLED    
    li a1, 8
    li a2, 4
    lw a0, black
    jal setLED    
    li a1, 8
    li a2, 5
    lw a0, black
    jal setLED    
    li a1, 8
    li a2, 6
    lw a0, black
    jal setLED    
    li a1, 8
    li a2, 7
    lw a0, black
    jal setLED    
    li a1, 8
    li a2, 8
    lw a0, black
    jal setLED    
    li a1, 8
    li a2, 9
    lw a0, black
    jal setLED    
    li a1, 9
    li a2, 0
    lw a0, black
    jal setLED    
    li a1, 9
    li a2, 1
    lw a0, black
    jal setLED    
    li a1, 9
    li a2, 2
    lw a0, black
    jal setLED    
    li a1, 9
    li a2, 3
    lw a0, black
    jal setLED    
    li a1, 9
    li a2, 4
    lw a0, black
    jal setLED    
    li a1, 9
    li a2, 5
    lw a0, black
    jal setLED    
    li a1, 9
    li a2, 6
    lw a0, black
    jal setLED    
    li a1, 9
    li a2, 7
    lw a0, black
    jal setLED    
    li a1, 9
    li a2, 8
    lw a0, black
    jal setLED    
    li a1, 9
    li a2, 9
    lw a0, black
    jal setLED

    jr s2
    
allRed:
    mv s2, ra
    
    li a1, 0
    li a2, 0
    lw a0, red
    jal setLED    
    li a1, 0
    li a2, 1
    lw a0, red
    jal setLED    
    li a1, 0
    li a2, 2
    lw a0, red
    jal setLED    
    li a1, 0
    li a2, 3
    lw a0, red
    jal setLED    
    li a1, 0
    li a2, 4
    lw a0, red
    jal setLED    
    li a1, 0
    li a2, 5
    lw a0, red
    jal setLED    
    li a1, 0
    li a2, 6
    lw a0, red
    jal setLED    
    li a1, 0
    li a2, 7
    lw a0, red
    jal setLED    
    li a1, 0
    li a2, 8
    lw a0, red
    jal setLED    
    li a1, 0
    li a2, 9
    lw a0, red
    jal setLED    
    li a1, 1
    li a2, 0
    lw a0, red
    jal setLED    
    li a1, 1
    li a2, 1
    lw a0, red
    jal setLED    
    li a1, 1
    li a2, 2
    lw a0, red
    jal setLED    
    li a1, 1
    li a2, 3
    lw a0, red
    jal setLED    
    li a1, 1
    li a2, 4
    lw a0, red
    jal setLED    
    li a1, 1
    li a2, 5
    lw a0, red
    jal setLED    
    li a1, 1
    li a2, 6
    lw a0, red
    jal setLED    
    li a1, 1
    li a2, 7
    lw a0, red
    jal setLED    
    li a1, 1
    li a2, 8
    lw a0, red
    jal setLED    
    li a1, 1
    li a2, 9
    lw a0, red
    jal setLED    
    li a1, 2
    li a2, 0
    lw a0, red
    jal setLED    
    li a1, 2
    li a2, 1
    lw a0, red
    jal setLED    
    li a1, 2
    li a2, 2
    lw a0, red
    jal setLED    
    li a1, 2
    li a2, 3
    lw a0, red
    jal setLED    
    li a1, 2
    li a2, 4
    lw a0, red
    jal setLED    
    li a1, 2
    li a2, 5
    lw a0, red
    jal setLED    
    li a1, 2
    li a2, 6
    lw a0, red
    jal setLED    
    li a1, 2
    li a2, 7
    lw a0, red
    jal setLED    
    li a1, 2
    li a2, 8
    lw a0, red
    jal setLED    
    li a1, 2
    li a2, 9
    lw a0, red
    jal setLED    
    li a1, 3
    li a2, 0
    lw a0, red
    jal setLED    
    li a1, 3
    li a2, 1
    lw a0, red
    jal setLED    
    li a1, 3
    li a2, 2
    lw a0, red
    jal setLED    
    li a1, 3
    li a2, 3
    lw a0, red
    jal setLED    
    li a1, 3
    li a2, 4
    lw a0, red
    jal setLED    
    li a1, 3
    li a2, 5
    lw a0, red
    jal setLED    
    li a1, 3
    li a2, 6
    lw a0, red
    jal setLED    
    li a1, 3
    li a2, 7
    lw a0, red
    jal setLED    
    li a1, 3
    li a2, 8
    lw a0, red
    jal setLED    
    li a1, 3
    li a2, 9
    lw a0, red
    jal setLED    
    li a1, 4
    li a2, 0
    lw a0, red
    jal setLED    
    li a1, 4
    li a2, 1
    lw a0, red
    jal setLED    
    li a1, 4
    li a2, 2
    lw a0, red
    jal setLED    
    li a1, 4
    li a2, 3
    lw a0, red
    jal setLED    
    li a1, 4
    li a2, 4
    lw a0, red
    jal setLED    
    li a1, 4
    li a2, 5
    lw a0, red
    jal setLED    
    li a1, 4
    li a2, 6
    lw a0, red
    jal setLED    
    li a1, 4
    li a2, 7
    lw a0, red
    jal setLED    
    li a1, 4
    li a2, 8
    lw a0, red
    jal setLED    
    li a1, 4
    li a2, 9
    lw a0, red
    jal setLED    
    li a1, 5
    li a2, 0
    lw a0, red
    jal setLED    
    li a1, 5
    li a2, 1
    lw a0, red
    jal setLED    
    li a1, 5
    li a2, 2
    lw a0, red
    jal setLED    
    li a1, 5
    li a2, 3
    lw a0, red
    jal setLED    
    li a1, 5
    li a2, 4
    lw a0, red
    jal setLED    
    li a1, 5
    li a2, 5
    lw a0, red
    jal setLED    
    li a1, 5
    li a2, 6
    lw a0, red
    jal setLED    
    li a1, 5
    li a2, 7
    lw a0, red
    jal setLED    
    li a1, 5
    li a2, 8
    lw a0, red
    jal setLED    
    li a1, 5
    li a2, 9
    lw a0, red
    jal setLED    
    li a1, 6
    li a2, 0
    lw a0, red
    jal setLED    
    li a1, 6
    li a2, 1
    lw a0, red
    jal setLED    
    li a1, 6
    li a2, 2
    lw a0, red
    jal setLED    
    li a1, 6
    li a2, 3
    lw a0, red
    jal setLED    
    li a1, 6
    li a2, 4
    lw a0, red
    jal setLED    
    li a1, 6
    li a2, 5
    lw a0, red
    jal setLED    
    li a1, 6
    li a2, 6
    lw a0, red
    jal setLED    
    li a1, 6
    li a2, 7
    lw a0, red
    jal setLED    
    li a1, 6
    li a2, 8
    lw a0, red
    jal setLED    
    li a1, 6
    li a2, 9
    lw a0, red
    jal setLED    
    li a1, 7
    li a2, 0
    lw a0, red
    jal setLED    
    li a1, 7
    li a2, 1
    lw a0, red
    jal setLED    
    li a1, 7
    li a2, 2
    lw a0, red
    jal setLED    
    li a1, 7
    li a2, 3
    lw a0, red
    jal setLED    
    li a1, 7
    li a2, 4
    lw a0, red
    jal setLED    
    li a1, 7
    li a2, 5
    lw a0, red
    jal setLED    
    li a1, 7
    li a2, 6
    lw a0, red
    jal setLED    
    li a1, 7
    li a2, 7
    lw a0, red
    jal setLED    
    li a1, 7
    li a2, 8
    lw a0, red
    jal setLED    
    li a1, 7
    li a2, 9
    lw a0, red
    jal setLED    
    li a1, 8
    li a2, 0
    lw a0, red
    jal setLED    
    li a1, 8
    li a2, 1
    lw a0, red
    jal setLED    
    li a1, 8
    li a2, 2
    lw a0, red
    jal setLED    
    li a1, 8
    li a2, 3
    lw a0, red
    jal setLED    
    li a1, 8
    li a2, 4
    lw a0, red
    jal setLED    
    li a1, 8
    li a2, 5
    lw a0, red
    jal setLED    
    li a1, 8
    li a2, 6
    lw a0, red
    jal setLED    
    li a1, 8
    li a2, 7
    lw a0, red
    jal setLED    
    li a1, 8
    li a2, 8
    lw a0, red
    jal setLED    
    li a1, 8
    li a2, 9
    lw a0, red
    jal setLED    
    li a1, 9
    li a2, 0
    lw a0, red
    jal setLED    
    li a1, 9
    li a2, 1
    lw a0, red
    jal setLED    
    li a1, 9
    li a2, 2
    lw a0, red
    jal setLED    
    li a1, 9
    li a2, 3
    lw a0, red
    jal setLED    
    li a1, 9
    li a2, 4
    lw a0, red
    jal setLED    
    li a1, 9
    li a2, 5
    lw a0, red
    jal setLED    
    li a1, 9
    li a2, 6
    lw a0, red
    jal setLED    
    li a1, 9
    li a2, 7
    lw a0, red
    jal setLED    
    li a1, 9
    li a2, 8
    lw a0, red
    jal setLED    
    li a1, 9
    li a2, 9
    lw a0, red
    jal setLED
    
    jr s2
    
allGreen:
    mv s2, ra
    
    li a1, 0
    li a2, 0
    lw a0, green
    jal setLED    
    li a1, 0
    li a2, 1
    lw a0, green
    jal setLED    
    li a1, 0
    li a2, 2
    lw a0, green
    jal setLED    
    li a1, 0
    li a2, 3
    lw a0, green
    jal setLED    
    li a1, 0
    li a2, 4
    lw a0, green
    jal setLED    
    li a1, 0
    li a2, 5
    lw a0, green
    jal setLED    
    li a1, 0
    li a2, 6
    lw a0, green
    jal setLED    
    li a1, 0
    li a2, 7
    lw a0, green
    jal setLED    
    li a1, 0
    li a2, 8
    lw a0, green
    jal setLED    
    li a1, 0
    li a2, 9
    lw a0, green
    jal setLED    
    li a1, 1
    li a2, 0
    lw a0, green
    jal setLED    
    li a1, 1
    li a2, 1
    lw a0, green
    jal setLED    
    li a1, 1
    li a2, 2
    lw a0, green
    jal setLED    
    li a1, 1
    li a2, 3
    lw a0, green
    jal setLED    
    li a1, 1
    li a2, 4
    lw a0, green
    jal setLED    
    li a1, 1
    li a2, 5
    lw a0, green
    jal setLED    
    li a1, 1
    li a2, 6
    lw a0, green
    jal setLED    
    li a1, 1
    li a2, 7
    lw a0, green
    jal setLED    
    li a1, 1
    li a2, 8
    lw a0, green
    jal setLED    
    li a1, 1
    li a2, 9
    lw a0, green
    jal setLED    
    li a1, 2
    li a2, 0
    lw a0, green
    jal setLED    
    li a1, 2
    li a2, 1
    lw a0, green
    jal setLED    
    li a1, 2
    li a2, 2
    lw a0, green
    jal setLED    
    li a1, 2
    li a2, 3
    lw a0, green
    jal setLED    
    li a1, 2
    li a2, 4
    lw a0, green
    jal setLED    
    li a1, 2
    li a2, 5
    lw a0, green
    jal setLED    
    li a1, 2
    li a2, 6
    lw a0, green
    jal setLED    
    li a1, 2
    li a2, 7
    lw a0, green
    jal setLED    
    li a1, 2
    li a2, 8
    lw a0, green
    jal setLED    
    li a1, 2
    li a2, 9
    lw a0, green
    jal setLED    
    li a1, 3
    li a2, 0
    lw a0, green
    jal setLED    
    li a1, 3
    li a2, 1
    lw a0, green
    jal setLED    
    li a1, 3
    li a2, 2
    lw a0, green
    jal setLED    
    li a1, 3
    li a2, 3
    lw a0, green
    jal setLED    
    li a1, 3
    li a2, 4
    lw a0, green
    jal setLED    
    li a1, 3
    li a2, 5
    lw a0, green
    jal setLED    
    li a1, 3
    li a2, 6
    lw a0, green
    jal setLED    
    li a1, 3
    li a2, 7
    lw a0, green
    jal setLED    
    li a1, 3
    li a2, 8
    lw a0, green
    jal setLED    
    li a1, 3
    li a2, 9
    lw a0, green
    jal setLED    
    li a1, 4
    li a2, 0
    lw a0, green
    jal setLED    
    li a1, 4
    li a2, 1
    lw a0, green
    jal setLED    
    li a1, 4
    li a2, 2
    lw a0, green
    jal setLED    
    li a1, 4
    li a2, 3
    lw a0, green
    jal setLED    
    li a1, 4
    li a2, 4
    lw a0, green
    jal setLED    
    li a1, 4
    li a2, 5
    lw a0, green
    jal setLED    
    li a1, 4
    li a2, 6
    lw a0, green
    jal setLED    
    li a1, 4
    li a2, 7
    lw a0, green
    jal setLED    
    li a1, 4
    li a2, 8
    lw a0, green
    jal setLED    
    li a1, 4
    li a2, 9
    lw a0, green
    jal setLED    
    li a1, 5
    li a2, 0
    lw a0, green
    jal setLED    
    li a1, 5
    li a2, 1
    lw a0, green
    jal setLED    
    li a1, 5
    li a2, 2
    lw a0, green
    jal setLED    
    li a1, 5
    li a2, 3
    lw a0, green
    jal setLED    
    li a1, 5
    li a2, 4
    lw a0, green
    jal setLED    
    li a1, 5
    li a2, 5
    lw a0, green
    jal setLED    
    li a1, 5
    li a2, 6
    lw a0, green
    jal setLED    
    li a1, 5
    li a2, 7
    lw a0, green
    jal setLED    
    li a1, 5
    li a2, 8
    lw a0, green
    jal setLED    
    li a1, 5
    li a2, 9
    lw a0, green
    jal setLED    
    li a1, 6
    li a2, 0
    lw a0, green
    jal setLED    
    li a1, 6
    li a2, 1
    lw a0, green
    jal setLED    
    li a1, 6
    li a2, 2
    lw a0, green
    jal setLED    
    li a1, 6
    li a2, 3
    lw a0, green
    jal setLED    
    li a1, 6
    li a2, 4
    lw a0, green
    jal setLED    
    li a1, 6
    li a2, 5
    lw a0, green
    jal setLED    
    li a1, 6
    li a2, 6
    lw a0, green
    jal setLED    
    li a1, 6
    li a2, 7
    lw a0, green
    jal setLED    
    li a1, 6
    li a2, 8
    lw a0, green
    jal setLED    
    li a1, 6
    li a2, 9
    lw a0, green
    jal setLED    
    li a1, 7
    li a2, 0
    lw a0, green
    jal setLED    
    li a1, 7
    li a2, 1
    lw a0, green
    jal setLED    
    li a1, 7
    li a2, 2
    lw a0, green
    jal setLED    
    li a1, 7
    li a2, 3
    lw a0, green
    jal setLED    
    li a1, 7
    li a2, 4
    lw a0, green
    jal setLED    
    li a1, 7
    li a2, 5
    lw a0, green
    jal setLED    
    li a1, 7
    li a2, 6
    lw a0, green
    jal setLED    
    li a1, 7
    li a2, 7
    lw a0, green
    jal setLED    
    li a1, 7
    li a2, 8
    lw a0, green
    jal setLED    
    li a1, 7
    li a2, 9
    lw a0, green
    jal setLED    
    li a1, 8
    li a2, 0
    lw a0, green
    jal setLED    
    li a1, 8
    li a2, 1
    lw a0, green
    jal setLED    
    li a1, 8
    li a2, 2
    lw a0, green
    jal setLED    
    li a1, 8
    li a2, 3
    lw a0, green
    jal setLED    
    li a1, 8
    li a2, 4
    lw a0, green
    jal setLED    
    li a1, 8
    li a2, 5
    lw a0, green
    jal setLED    
    li a1, 8
    li a2, 6
    lw a0, green
    jal setLED    
    li a1, 8
    li a2, 7
    lw a0, green
    jal setLED    
    li a1, 8
    li a2, 8
    lw a0, green
    jal setLED    
    li a1, 8
    li a2, 9
    lw a0, green
    jal setLED    
    li a1, 9
    li a2, 0
    lw a0, green
    jal setLED    
    li a1, 9
    li a2, 1
    lw a0, green
    jal setLED    
    li a1, 9
    li a2, 2
    lw a0, green
    jal setLED    
    li a1, 9
    li a2, 3
    lw a0, green
    jal setLED    
    li a1, 9
    li a2, 4
    lw a0, green
    jal setLED    
    li a1, 9
    li a2, 5
    lw a0, green
    jal setLED    
    li a1, 9
    li a2, 6
    lw a0, green
    jal setLED    
    li a1, 9
    li a2, 7
    lw a0, green
    jal setLED    
    li a1, 9
    li a2, 8
    lw a0, green
    jal setLED    
    li a1, 9
    li a2, 9
    lw a0, green
    jal setLED
    
    jr s2
    

.text
output: .asciz "%c"
back: .asciz "\033[38;5;%dm"
font: .asciz "\033[48;5;%dm"
effect: .asciz "\033[%dm"

.include "final.s"


.global main

# ********************
# Subroutine: decode                                         *
# Description: decodes message as defined in Assignment 3    *
#   - 2 byte unknown                                         *
#   - 4 byte index                                           *
#   - 1 byte amount                                          *
#   - 1 byte character                                       *
# Parameters:                                                *
#   first: the address of the message to read                *
#   return: no return value                                  *
# ********************

main:
pushq %rbp # push the base pointer (and align the stack)
movq %rsp, %rbp # copy stack pointer value to base pointer

movq $MESSAGE, %rdi # first parameter: address of the message

 


movq $0, %r8
movq $0, %r9
movq $0, %r10
movq $0, %r14
movq $0, %r15           
movq $0, %rcx           # so that when the subroutine is called, it will start at memory block 0
call decode             # call decode

//popq %r15
//popq %r14 #popping it all again since we pushed them in the beginning and only now did we return to main (only returned to main after everything is done)

popq %rbp # restore base pointer location
movq $0, %rdi # load program exit code

call exit # exit the program

decode:
# prologue
pushq %rbp # push the base pointer (and align the stack)
movq %rsp, %rbp # copy stack pointer value to base pointer

pushq %r14
pushq %r15 #pushing all registers that will be used to store the values

movq 0(%rdi, %rcx, 8), %r8 # moving all 64 bits of the memory block that rcx shows into r8. the 0 shows that the bztes 0 to 8 should be taken

pushq %r14
pushq %r15 #pushing the calee registers or else the values will be shuffled

movq %r8, %r9
movq %r8, %r10
movq %r8, %r14
movq %r8, %r15  # making copies of data in r8, into r9, 10, 14, 15

shl $56, %r8
shr $56, %r8 # shifting to isolate the 8th byte (character)

shl $48, %r9
shr $56, %r9 # shifting to isolate the 7th byte (number of times the character needs to be printed)

shl $8, %r14 # shifting to isolate the 2nd byte (character color)
shr $56, %r14 

shr $56, %r15 # shifting to isolate the 1st byte (background color)

movq $0, %r11
movq %rdi, %r11 # we need to preserve the current value of rdi before using it for print f

loop:
cmpq $0, %r9 # when the value in the r9 register(the number of times character needs to be printed)
je endloop # is equal to 0, the loop will end
decq %r9 # otherwise, the number will be decremented

pushq %r8
pushq %r9
pushq %r10
pushq %r11 
pushq %rcx #pushing all to store values (caller registers)

cmpq %r14, %r15
je eff #checking if the color is the same or not, if so jump to the char section

movq $0, %rax
movq $0, %rsi
movq $back, %rdi # rdi first parameter. the output declares that the ascii character that needs to be printed is a character
movq %r14, %rsi
call printf

popq %rcx
popq %r11
popq %r10
popq %r9
popq %r8 #popping all the caller registers

pushq %r8
pushq %r9
pushq %r10
pushq %r11 
pushq %rcx #same thing, since printf would shuffle these

movq $0, %rax
movq $0, %rsi
movq $font, %rdi # rdi first parameter. the output declares that the ascii character that needs to be printed is a character
movq %r15, %rsi
call printf

popq %rcx
popq %r11
popq %r10
popq %r9
popq %r8 #popping them after printf

char:

pushq %r8
pushq %r9
pushq %r10
pushq %r11 
pushq %rcx #same thing again since printf would shuffle the caller registers

movq $0, %rax
movq $0, %rsi
movq $output, %rdi # rdi first parameter. the output declares that the ascii character that needs to be printed is a character
movq %r8, %rsi
call printf

popq %rcx
popq %r11
popq %r10
popq %r9
popq %r8 #again, same thing - popping after printf


jmp loop

endloop:

movq %r11, %rdi # the original value of rdi from before the loop was started, is in r11 and this is being put back into the rdi before we call decode again
movq (%rdi, %rcx, 8), %r10 # moving all 64 bits of the memory block that rcx shows into r10. the 0 shows that the bztes 0 to 8 should be taken

shl $16, %r10
shr $32, %r10 # shifting to isolate the 3-6th bytes (next memory block to visit)

cmpq $0, %r10 # if the next memory block that needs to be visited is 0, then jump to finish
je finish
movq %r10, %rcx # the next memory block that needs to be visited is put into rcx and decode is called again

call decode

finish:
# epilogue
popq %r15
popq %r14

movq %rbp, %rsp # clear local variables from stack
popq %rbp # restore base pointer location

ret #return to main

eff:
cmpq $0, %r14
je case_reset

cmpq $37, %r14
je case_stopblinking

cmpq $42, %r14
je case_bold

cmpq $66, %r14
je case_faint

cmpq $105, %r14
je case_conceal

cmpq $153, %r14
je case_reveal

cmpq $182, %r14
je case_blink

jmp char

case_reset:

pushq %r8
pushq %r9
pushq %r10
pushq %r11 
pushq %rcx #same thing again since printf would shuffle the caller registers

movq $0, %rax
movq $0, %rsi
movq $effect, %rdi # rdi first parameter. the output declares that the ascii character that needs to be printed is a character
movq $0, %rsi
call printf

popq %rcx
popq %r11
popq %r10
popq %r9
popq %r8 #again, same thing - popping after printf

jmp char

case_stopblinking:

pushq %r8
pushq %r9
pushq %r10
pushq %r11 
pushq %rcx #same thing again since printf would shuffle the caller registers

movq $0, %rax
movq $0, %rsi
movq $effect, %rdi # rdi first parameter. the output declares that the ascii character that needs to be printed is a character
movq $25, %rsi
call printf

popq %rcx
popq %r11
popq %r10
popq %r9
popq %r8 #again, same thing - popping after printf

jmp char

case_bold:

pushq %r8
pushq %r9
pushq %r10
pushq %r11 
pushq %rcx #same thing again since printf would shuffle the caller registers

movq $0, %rax
movq $0, %rsi
movq $effect, %rdi # rdi first parameter. the output declares that the ascii character that needs to be printed is a character
movq $1, %rsi
call printf

popq %rcx
popq %r11
popq %r10
popq %r9
popq %r8 #again, same thing - popping after printf

jmp char

case_faint:

pushq %r8
pushq %r9
pushq %r10
pushq %r11 
pushq %rcx #same thing again since printf would shuffle the caller registers

movq $0, %rax
movq $0, %rsi
movq $effect, %rdi # rdi first parameter. the output declares that the ascii character that needs to be printed is a character
movq $2, %rsi
call printf

popq %rcx
popq %r11
popq %r10
popq %r9
popq %r8 #again, same thing - popping after printf

jmp char

case_conceal:

pushq %r8
pushq %r9
pushq %r10
pushq %r11 
pushq %rcx #same thing again since printf would shuffle the caller registers

movq $0, %rax
movq $0, %rsi
movq $effect, %rdi # rdi first parameter. the output declares that the ascii character that needs to be printed is a character
movq $8, %rsi
call printf

popq %rcx
popq %r11
popq %r10
popq %r9
popq %r8 #again, same thing - popping after printf

jmp char

case_reveal:

pushq %r8
pushq %r9
pushq %r10
pushq %r11 
pushq %rcx #same thing again since printf would shuffle the caller registers

movq $0, %rax
movq $0, %rsi
movq $effect, %rdi # rdi first parameter. the output declares that the ascii character that needs to be printed is a character
movq $28, %rsi
call printf

popq %rcx
popq %r11
popq %r10
popq %r9
popq %r8 #again, same thing - popping after printf

jmp char

case_blink:

pushq %r8
pushq %r9
pushq %r10
pushq %r11 
pushq %rcx #same thing again since printf would shuffle the caller registers

movq $0, %rax
movq $0, %rsi
movq $effect, %rdi # rdi first parameter. the output declares that the ascii character that needs to be printed is a character
movq $6, %rsi
call printf

popq %rcx
popq %r11
popq %r10
popq %r9
popq %r8 #again, same thing - popping after printf

jmp char
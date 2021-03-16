## ASM Code Scraps
## Copyright (C) 2021 Tomasz "TFKls" Kulis

##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program.  If not, see <https://www.gnu.org/licenses/>.

	.global _start
	## -- MAIN --
_start:
	push $fstr 										# String A buffer
	push $3												# String A len
	call read											# String A read call
	push $sstr										# String B buffer
	push $3												# String B len
	call read											# String B read call
	push $fstr
	call parse
	pop %r10
	push $sstr
	call parse
	pop %r11
	## Here we expect 2 registers with numbers entered
	add %r11, %r10
	cmp $21, %r10
	je blackjackcase
	push $fstr
	push %r10
	call unparse
 	pop %rdx
	push $fstr
	push %rdx
	call print
	jmp exit
blackjackcase:
	push $blackjack
	push $bjlen
	call print
	jmp exit
exit:
	push $newline
	push $nllen
	call print
	mov $60, %rax 								# Set exit syscall
	mov $0, %rdi									# Return code
	syscall												# Call sys_exit







	
	## -- DATA --
.data
blackjack:
	.ascii "Blackjack!"
	bjlen = . - blackjack
newline:
	.ascii "\n"
	nllen = . - blackjack
	## -- BSS --
	.bss
	.lcomm fstr, 3
	.lcomm sstr, 3
	.lcomm readbuf, 1

	## -- PROC --
	.text

print:
	## Print subroutine
	## :: Stack : Buffer : Size -> Stack
	## :: Takes: None
	## :: Returns: None
	## :: Modifies: %rdx %rsi 
	pop %rbx											# Push call location into register
	pop %rdx											# Pop the stack information - length
	pop %rsi											# Pop the string address
	push %rax											# Push %rax
	push %rdi											# Push %rdi
	mov $1, %rax									# Set write syscall 
	mov $1, %rdi									# Set stdout as file
	syscall												# Syscall to sys_write
	pop %rdi											# Restore %rdi
	pop %rax 											# Restore %rax
	push %rbx											# Restore original call location 
	ret														# Return from subroutine

read:
	## Read subroutine
	## :: Stack : Buffer : Size -> Stack
	## :: Takes: None
	## ::	Returns: None
	## :: Modifies: %rax %rcx %rdx %rdi %rsi %r8
	pop %rbx 											# Pop call location from stack
	pop %rdx											# Pop length of buffer
	pop %rax 											# Pop buffer to reg.
	push %rbx											# Return call location to stack
	mov $0, %r9										# Initialize counter
read_loop:
	push %rax											# Save buffer to stack
	push %rdx											# Save buffer size to stack
	call readchar
	pop %rdx											# Restore buffer size
	pop %rax											# Restore buffer
	cmp $0x0A, %r8b								# Check if the char is a newline
	je read_loopexit							# Break
	movb %r8b, (%rax)							# Set byte to buffer
	inc %rax											# Increment arrayptr
	inc %r9												# Increment counter
	cmp %r9, %rdx									# Check if is counter size of buffer
	je read_loopexit							# Break
	jmp read_loop									# Loop back
read_loopexit:
	pop %rbx											# Swap return on stack
	push %r9											# Set return on stack
	push %rbx 										# Restore call on stack
	ret														# Return from subroutine

readchar:												# Reads a singular character and returns it on the stack
	## :: Stack -> Stack
	## :: Takes: None
	## :: Returns: %r8b (%r8)
	## :: Modifies: %rax %rdx %rdi %rsi %r8
	mov $0, %rax									# Set syscall to read
	mov $0, %rdi									# Set FD to stdin
	mov $readbuf, %rsi						# Set temporary buffer
	mov $1, %rdx									# Set buffer size to 1
	syscall												# Syscall to sys_read
	cmp $0, %rax 									# Check if is EOF
	je readchar_eof								# Jump if equal
readchar_noeof:	
	movb (readbuf), %r8b					# If not EOF, push readbuf* to dl reg  
	jmp readchar_eofskip					# Skip the EOF case
readchar_eof:
	movb $0x0A, %r8b							# Set character to newline if it is EOF
readchar_eofskip:
	ret														# Return from subroutine

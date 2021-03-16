## ac.s - ASM Code Scraps
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
	push $prompt
	push $lenprompt
	call print
	push $name
	push $32
	call read
	pop %rdx
	cmp $32, %rdx
	je _start_longname
	push %rdx
	push $respbeg
	push $respbeglen
	call print
	pop %rdx
	push $name
	push %rdx
	call print
	push $respend
	push $respendlen
	call print
	mov $0, %rdi
	jmp _exit
_start_longname:
	push $toolong
	push $toolonglen
	call print
	mov $0, %rdi
	jmp _exit

	## -- DATA -- 
	.data
prompt:
	.ascii "Hello, what's your name?\n"
	lenprompt = . - prompt
respend:
	.ascii ".\n"
	respendlen  = . - respend
toolong:
	.ascii "Wow, that's a long name.\n"
	toolonglen = . - toolong
respbeg:
	.ascii "Hello there, "
	respbeglen = . - respbeg
	
	.text
	
	## -- PROC --
_exit: 													# Exit with status at %rdi
	mov $60, %rax
	syscall

print:													# Print subroutine
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

read:														# Read subroutine
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



	## -- BSS --
	.bss
	.lcomm name, 32
	.lcomm readbuf, 1

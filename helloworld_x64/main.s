	.global _start

_start:
	mov $1, %rax
	mov $1, %rdi
	mov $msg, %rsi
	mov $msglen, %rdx
	syscall

	mov $60, %rax
	mov $0, %rdi
	syscall
	
	.data
msg:
	.ascii "Hello, world!\n"
	msglen = . - msg

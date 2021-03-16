	.global _start

	.text
_start:													
	movl $4, %eax									/* write syscall */
	movl $1, %ebx									/* stdout	*/
	movl $msg, %ecx								/* hello world string */
	movl $msglen, %edx						/* hello world length */
	int  $0x80 										/* syscall */
	
	movl $1, %eax									/* exit syscall */
	movl $0, %ebx 								/* error code 0 */
	int $0x80											/* syscall */
	
	.data
msg:
	.ascii "Hello, world!\n"
	msglen = . - msg

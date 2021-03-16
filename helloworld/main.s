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

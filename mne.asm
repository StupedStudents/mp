[bits 16]
global _print
section .text
_print:

	mov ax,4f02h
	mov bx,13h
	int 10h

	mov ah,9
	mov al,'m'
	mov bh,0
	mov cx,1
	mov bl,3
	int 10h

ret


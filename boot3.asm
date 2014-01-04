[BITS 16]
[ORG 0x700]

	mov ah,9
	mov cx,1
	mov al,'5'
	mov bh,0
	mov bl,4
	int 10h

incbin 'boot1.bin'


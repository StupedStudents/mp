[BITS 16]
[ORG 0x700]

cli 
mov ax, 0
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x700
sti

	mov ah,9
	mov cx,1
	mov al,'2'
	mov bh,0
	mov bl,4
	int 10h

incbin 'boot3.bin'

[BITS 16]
[ORG 0]	

jmp	entry 

	msg_loading 		db "Loading", 0
	msg_loading_proc 		db ".", 0
	msg_crlf 			db 0x0a, 0x0d
entry:
	cli				
	mov		ax, 0x07c0		
	mov		ds, ax
	mov 	ax, 0x9000		
	mov 	es, ax
	xor 	si, si		
	xor 	di, di
	sti		

	mov 	cx, 128		
	rep 	movsd

	jmp 	0x9000:start	

start:
	mov		si, msg_loading	
	call	print

	mov 	ax, cs		
	mov 	ds, ax
	mov		ss, ax

	mov 	di, 1			
	mov 	ax, 0x290
	xor 	bx, bx

.loop:
	mov		si, msg_loading_proc
	call	print

	mov 	cx, 0x50
	mov 	es, cx

	push 	di
		
	shr 	di, 1
	setc 	dh
	mov 	cx, di
	xchg 	cl, ch

	pop	di
	cmp 	di, 10
	je 	.quit

	call 	read_cylinder		

	pusha
	push 	ds

	mov 	cx, 0x50			
	mov 	ds, cx
	mov 	es, ax
	xor 	di, di
	xor 	si, si
	mov 	cx, 0x2400
	rep 	movsb

	pop 	ds
	popa

	inc 	di				
	add 	ax, 0x240
	jmp 	short .loop			

.quit:
	mov 	ax, 0x50			
	mov 	es, ax
	mov 	bx, 0
	mov 	ch, 0
	mov 	dh, 0
	call 	read_cylinder

	jmp 	0x0000:0x0700		

read_cylinder:				

	pusha

.start:
	mov 	ah, 0x02
	mov 	al, 18
	mov 	cl, 1
	int 	0x13

	popa
	ret

printc:					;Выведим один символ al
	pusha
	mov 	ah, 0x0E
	int 	0x10
	popa
	ret

print:					;Выведим строку si
	pusha
.loop:
	lodsb
	or 		al, al
	jz 		.quit
	mov 	ah, 0x0e
	mov 	bx, 0x7
	int 	0x10
	jmp 	.loop
.quit:
	popa
	ret


TIMES 510 - ($-$$) db 0			;Ставим нулевые байты до 510го байта
dw 0xaa55					;Ставим сигнатуру, говорим BIOS, что это загрузочный сектор

incbin   'main.bin'
TIMES 1474560 - 512 - ($-$$) db 0
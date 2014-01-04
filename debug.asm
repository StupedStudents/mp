
org 100h
global _VideoMode
global _VideoVesa
global _setPix
global _setChar
global _setPos
global _getKey
global _setPage
global _powOff
global _hardType
global _countDrives
global _outTime
global _setAlarm
section .text

_main:
	
	mov eax,0x3
	push eax
	push 0
	call _VideoMode
	pop ax
	add sp,4

	mov eax,0x102
	push eax
	push 0
	call _VideoVesa
	pop ax
	add sp,4

	mov eax,4
	push eax
	mov eax,0
	push eax
	mov eax,5
	push eax
	mov eax,5
	push eax
	push 0
	call _setPix
	pop ax
	add sp,16

	mov eax,'a'
	push eax
	mov eax,1
	push eax
	mov eax,5
	push eax
	mov eax,0
	push eax
	push 0
	call _setChar
	pop ax

	add sp,16

	mov eax,0
	push eax
	mov eax,5
	push eax
	mov eax,6
	push eax
	push 0
	call _setPos
	pop ax
	add sp,12

	call _getKey

	mov eax,0
	push eax
	push 0
	call _setPage
	pop ax
	add sp,4

	call _powOff

	call _hardType

	call _countDrives

	call _outTime

	call _setAlarm

	ret


	_setAlarm:
		push 	ebp
		mov 	bp,sp
		xor 	dx,dx
		mov 	al,5h
		out 	70h,al
		call 	_reader
		out 	71h,al
		mov 	al,3h
		out 	70h,al
		call 	_reader
		out 	71h,al
		mov 	al,1h
		out 	70h,al
		call 	_reader
		out 	71h,al
		call 	_get_pos
		inc 	dh
		mov 	dl,0
		call 	_set_pos
		mov 	sp,bp
		pop 	ebp
	
	ret

_reader:
	call 	_rw
	call 	_get_pos
	call 	_inc_pos
	sub 	al,48
	mov 	dl,16
	mul 	dl
	mov 	dl,al
	call 	_rw
	sub 	dl,48
	add 	al,dl
	call 	_get_pos
	call 	_inc_pos
	call 	_inc_pos
ret

_rw:
	mov 	ah,0
	int 	16h
	mov 	ah,9
	mov 	bl,4h
	mov 	bh,1
	mov 	cx,1
	int 	10h
ret

	_outTime:
		push 	ebp
		mov 	bp,sp
		mov 	bl,4
		mov 	al,09h
		out 	70h,al
		in 		al,71h
		call 	_print_num
		mov 	al,'.'
		call 	_setPoint
		mov 	al,08
		out 	70h,al
		in 		al,71h
		call	_print_num
		mov 	al,'.'
		call 	_setPoint
		mov 	al,07
		out 	70h,al
		in 		al,71h
		call	_print_num
		call 	_inc_pos
		mov 	al,04h
		out 	70h,al
		in 		al,71h
		call 	_print_num
		mov 	al,':'
		call 	_setPoint
		mov 	al,02h
		out 	70h,al
		in 		al,71h
		call 	_print_num
		mov		 al,':'
		call 	_setPoint
		mov 	al,00h
		out 	70h,al
		in 		al,71h
		call 	_print_num
		
		mov 	sp,bp
		pop 	ebp
	ret


_setPoint:
	mov 	ah,9
	mov 	cx,1
	int 	10h
	call 	_inc_pos;
ret

_set_pos:
	mov 	ah,2
	mov 	bh,0
	int 	10h
ret

_inc_pos:
	mov 	ah,2
	inc 	dl
	int 	10h
	mov 	ah,9
ret

_get_pos:
	mov 	ah,3
	mov 	bh,1
	int 	10h
ret

_print_num:
		mov 	ah,0
		push 	-1
		mov 	cx,16
	point_l:
		xor 	dx,dx
		div 	cx 
		push 	dx
		cmp 	ax,0
		jne 	point_l
	point_2:
		pop 	ax
		cmp 	ax,-1
		je 		exit
		call 	_get_pos
		mov 	cx,1
		mov 	ah,9
		add 	al,'0'
		int 	10h
		call	 _inc_pos
		jmp		point_2
	exit:
ret


	_countDrives:
		push 	ebp
		mov 	bp,sp
		mov 	ah,9	
		mov 	al, 14h
		out 	70h,al
		in 		al,71h
		and 	al,11000000b
		cmp 	al,0
		jz 		n_1
		cmp 	al,1
		jz 		n_2
		cmp 	al,2
		jz 		n_3
		cmp 	al,3
		jz 		n_4
	n_1:
		mov 	ax,1
		jmp 	n_end
	n_2:
		mov 	ax,2
		jmp 	n_end
	n_3:
		mov 	ax,3
		jmp 	n_end
	n_4:
		mov 	ax,4
		jmp 	n_end
	n_end:
		mov 	sp,bp
		pop 	ebp
	ret

	_hardType:

		push 	ebp
		mov 	bp,sp
		mov 	ah,15h
		mov 	dl,80h
		int 	13h
		cmp 	ah, 0
		jz 		dev0
		cmp 	ah, 1
		jz 		dev1
		cmp 	ah,2
		jz 		dev2
		cmp 	ah,3
		jz 		dev3
		mov 	ax,4
		jmp 	next2
	dev0:
		mov 	ax,0
		jmp 	next2
	dev1:
		mov 	ax,1
		jmp 	next2
	dev2:
		mov 	ax,2
		jmp 	next2
	dev3:
		mov 	ax,3
		jmp 	next2
	next2:
		
		mov 	sp,bp
		pop 	ebp	
	ret

	_powOff:
		push 	ebp
		mov 	bp,sp
		mov 	ax, 5307h
		xor 	bx, bx
		inc 	bx
		mov 	cx, 3
		int 	15h
		mov 	sp,bp
		pop 	ebp
	ret

	_setPage:
		push 	ebp
		mov 	bp,sp
		mov 	ah,5
		mov 	al,[bp + 8]
		int 	10h
		mov 	sp,bp
		pop 	ebp
	ret

	_getKey:
		push 	ebp
		mov 	bp,sp
		mov 	ah,0
		int 	16h
		mov 	ah,0
		mov 	sp,bp
		pop 	ebp
	ret

	_setPos:
		push 	ebp
		mov 	bp,sp
		xor 	bx,bx
		mov 	ah,2
		mov 	bh,[bp + 8]
		mov 	dh,[bp + 12]
		mov 	dl,[bp + 16]
		int 	10h
		mov 	sp,bp
		pop 	ebp
	ret

	_VideoMode:
		push 	ebp
		mov 	bp, sp
		mov 	ax, [bp+8]
		int 	10h
		mov 	sp,bp
		pop 	ebp
	ret

	_VideoVesa:
		push 	ebp
		mov 	bp, sp
		mov 	ax, 4f02h
		mov 	bx, [bp+8]
		int 	10h
		mov 	sp,bp
		pop 	ebp
	ret

	_setPix:
		push 	ebp
		mov 	bp,sp
		mov 	ah,0ch
		mov 	al,[bp + 8]
		mov 	bh,[bp + 12]
		mov 	cx,[bp + 16]
		mov 	dx,[bp + 20]
		int 	10h
		mov 	sp,bp
		pop 	ebp
	ret

	_setChar:
		push 	ebp
		mov 	bp,sp
		mov 	ah,9
		mov 	al,[bp + 8]
		mov 	cx,[bp + 12]
		mov 	bl,[bp + 16]
		mov 	bh,[bp + 20]
		int 	10h
		mov 	sp,bp
		pop 	ebp
	ret
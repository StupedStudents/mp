[BITS 16]	;Говорим что 16 битный код
[ORG 0]	;Начало с 0000:0000

jmp	entry ;Пропускаем данные и передаем управление коду по метке entry, а так же для корректировки на 0000:07c0

	cyls_read			db 10	;Кол-во цилиндров для чтения
	max_errors			db 5	;Максимальное кол-во ошибок

	;Сообщения для информирования пользователя
	msg_loading 		db "Loading", 0
	msg_loading_proc 		db ".", 0
	msg_reading_error 	db "Error reading from floppy. Errcode:", 0
	msg_giving_up 		db "Too many errors, giving up", 0x0a, 0x0d, "Reboot your system, please", 0
	msg_crlf 			db 0x0a, 0x0d ;Всем знакомые 2 байты, для переноса строки и каретки.

entry:
	cli				;Запрещаем прерывания BIOS
	mov	ax, 0x07c0	;Указываем адрес куда нас BIOS загрузил
	mov	ds, ax
	mov 	ax, 0x9000		;Адрес сегмента
	mov 	es, ax
	xor 	si, si		;Копируем с нуля
	xor 	di, di
	sti				;Разрешаем прерывания BIOS

	mov 	cx, 128		;Говорим перенести 128 двойных слов ( 128 * 2 * 2 байт ) по адресу 9000:0000
	rep 	movsd

	jmp 	0x9000:start	;Передаем управление скопированному коду


start:
	mov	si, msg_loading	;Вывод сообщения
	call	print

	mov 	ax, cs		;Новые значения в сегментные регистры
	mov 	ds, ax
	mov	ss, ax

	mov 	di, 1			;Начнем копирование с дискеты в 0290:0000 с первого цилиндра
	mov 	ax, 0x290
	xor 	bx, bx

.loop:
	mov	si, msg_loading_proc	;Выводим точку :)
	call	print

	mov 	cx, 0x50
	mov 	es, cx

	push 	di
		
	shr 	di, 1
	setc 	dh
	mov 	cx, di
	xchg 	cl, ch

	pop	di

	cmp 	di, 10	;Все ли цилиндры прочитаны
	je 	.quit

	call 	read_cylinder		;Читаем дальше цилиндр	0050:0000 - 0050:2400

	pusha
	push 	ds

	mov 	cx, 0x50			;Копируем данный блок дальше в 0290:0000
	mov 	ds, cx
	mov 	es, ax
	xor 	di, di
	xor 	si, si
	mov 	cx, 0x2400
	rep 	movsb

	pop 	ds
	popa

	inc 	di				;Увеличиваем значения
	add 	ax, 0x240
	jmp 	short .loop			;Продолжаем читать

.quit:



	mov 	ax, 0x50			;Скопированы все цилиндры, прочитаем нулевой цилиндр
	mov 	es, ax
	mov 	bx, 0
	mov 	ch, 0
	mov 	dh, 0
	call 	read_cylinder



	jmp 	0x0000:0x0700		;Все теперь передаем управление коду "вторичного" загрузчика

read_cylinder:				;Функция чтения цилиндра прерывание BIOS 0x13
	mov 	[.errors_counter], byte 0
	pusha

.start:
	mov 	ah, 0x02
	mov 	al, 18
	mov 	cl, 1

	int 	0x13
	jc 	.read_error

	popa
	ret



.errors_counter: db 0			;Кол-во ошибок
.read_error:
	inc 	byte [.errors_counter]
	mov 	si, msg_reading_error
	call 	print
	call 	printh
	mov 	si, msg_crlf
	call 	print

	cmp 	byte [.errors_counter], max_errors
	jl 	.start

	mov 	si, msg_giving_up		;Получили много ошибок, выведим сообщение и повесим систему
	call 	print
	hlt
	jmp	$



hex_table:	db "0123456789ABCDEF"
printh:					;Выведим хекс значение
	pusha
	xor 	bx, bx
	mov 	bl, ah
	and 	bl, 11110000b
	shr 	bl, 4
	mov 	al, [hex_table+bx]
	call 	printc

	mov 	bl, ah
	and 	bl, 00001111b
	mov 	al, [hex_table+bx]
	call 	printc

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
	or 	al, al
	jz 	.quit
	mov 	ah, 0x0e
	mov 	bx, 0x7
	int 	0x10
	jmp 	.loop
.quit:
	popa
	ret


TIMES 510 - ($-$$) db 0			;Ставим нулевые байты до 510го байта
dw 0xaa55					;Ставим сигнатуру, говорим BIOS, что это загрузочный сектор

incbin   'mbr1.o'


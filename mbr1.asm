[BITS 16]
[ORG 0x700]
cli 
mov ax, 0
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x700
sti

; Установим базовый вектор контроллера прерываний в 0x20
mov al,00010001b 
out 0x20,al 
mov al,0x20 
out 0x21,al 
mov al,00000100b 
out 0x21,al
mov al,00000001b 
out 0x21,al 

mov ah,9
mov cx,1
mov al,'0'
mov bh,0
mov bl,4
int 10h

	;mov bx, 0x6000
	jmp 0x200000

; Отключим прерывания
cli
; Загрузка регистра GDTR: 
lgdt [gd_reg]
; Включение A20: 
in al, 0x92
or al, 2
out 0x92, al
; Установка бита PE регистра CR0
mov eax, cr0 
or al, 1 
mov cr0, eax 

; С помощью длинного прыжка мы загружаем селектор нужного сегмента в регистр CS
jmp 0x8: _protect

; Следующий код - 32-битный
[BITS 32]
; При переходе в защищенный режим, сюда будет отдано управление
_protect: 
; Загрузим регистры DS и SS селектором сегмента данных
mov ax, 0x10
mov ds, ax
mov es, ax
mov ss, ax
; Наше ядро слинковано по адресу 2мб, переносим его туда. ker_bin - метка, после которой вставлено ядро
mov esi, kernel
; Адрес, по которому копируем
mov edi, 0x200000
; Размер ядра в двойных словах (65536 байт)
mov ecx, kernel_size
rep movsd
; Ядро скопировано, передаем управление ему

;mov eax, cr0
;and eax, 0xFFFFFFFE
;mov cr0, eax
;mov     ax, 0FEh        ; команда отключения
;out     64h, ax
;sti
  ;mov     ax,000dh        ; разрешаем немаскируемые прерывания
  ;out     71h,al
  ;in      al,21h ; разрешаем маскируемые прерывания
  ;and     al,0
  ;out     21h,al
 ; sti

jmp 0x200000
gdt:
dw 0, 0, 0, 0 
; Нулевой дескриптор
db 0xFF 
; Сегмент кода с DPL=0 Базой=0 и Лимитом=4 Гб 
db 0xFF 
db 0x00
db 0x00
db 0x00
db 10011010b
db 0xCF
db 0x00
db 0xFF 
; Сегмент данных с DPL=0 Базой=0 и Лимитом=4Гб 
db 0xFF 
db 0x00 
db 0x00
db 0x00
db 10010010b
db 0xCF
db 0x00
;Значение, которое мы загрузим в GDTR: 
gd_reg:
dw 	gd_reg - gdt - 1
	dd 	gdt
kernel:
	incbin 'kernel.bin'
kernel_size equ $-kernel
;TIMES 1474560 - 512 - ($-$$) db 0
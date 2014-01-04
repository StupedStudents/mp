;;
;; enableA20.s (adapted from Visopsys OS-loader)
;;
;; Copyright (c) 2000, J. Andrew McLaughlin
;; You're free to use this code in any manner you like, as 
;; long as this notice is included (and you give credit where
;; it is due), and as long as you understand and accept that
;; it comes with NO WARRANTY OF ANY KIND. 
;; Contact me at jamesamc@yahoo.com about any bugs or problems.
;;

enableA20:
;; Эта процедура включит A20 через контроллер клавиатуры
;; Аргументы: нет.  Возвращает: 0 в EAX в случае успеха,
;; -1 при ошибке.  Написано для использования в 16-битном коде
;; (32-битные участки помечены как 32-BIT)



pusha

;; Убедимся, что прерывания отключены
cli

;; В CX будет счетчик (мы предпримем до 5 попыток включения A20)
mov CX, 5

.startAttempt1:
;; Подождем пока контроллер готов принимать команды
.commandWait1:
xor AX, AX
in AL, 64h
bt AX, 1
jc .commandWait1

;; Скажем контроллеру, что мы хотим прочитать текущий статус
;; (команда D0h)
mov AL, 0D0h
out 64h, AL

;; Подождем пока контроллер готов
.dataWait1:
xor AX, AX
in AL, 64h
bt AX, 0
jnc .dataWait1

;; Прочитаем текущий статус из порта 60h
xor AX, AX
in AL, 60h

;; сохраним текущее значение (E)AX
push AX; 16-BIT
;; push EAX; 32-BIT

;; Подождем пока контроллер готов
.commandWait2:
in AL, 64h
bt AX, 1
jc .commandWait2

;; Скажем контроллер, что мы снова хотим записать байт статуса
mov AL, 0D1h
out 64h, AL

;; Подождем пока контроллер готов
.commandWait3:
xor AX, AX
in AL, 64h
bt AX, 1
jc .commandWait3

;; Запишем новое значение в порт 60h.  Напоминаю, что предыдущее
;; мы сохранили в стеке
pop AX; 16-BIT
;; pop EAX; 32-BIT

;; Установим бит включения A20
or AL, 00000010b
out 60h, AL

;; И, наконец, прочитаем байт статуса, чтобы убедиться
;; что A20 был включен

;; Подождем пока контроллер готов
.commandWait4:
xor AX, AX
in AL, 64h
bt AX, 1
jc .commandWait4

;; Команда D0h
mov AL, 0D0h
out 64h, AL

;; Подождем пока контроллер готов
.dataWait2:
xor AX, AX
in AL, 64h
bt AX, 0
jnc .dataWait2

;; Прочитаем статус из порта 60h
xor AX, AX
in AL, 60h

;; Шлюз A20 включен?
bt AX, 1

;; Проверим результат.  Если флаг CF установлен, то A20 включен.
jc .success

;; Повторить операцию?  Если счетчик в ECX
;; не дошел до нуля, мы должны повторить
loop .startAttempt1


;; Мда, попытка включить A20 обычным способом провалилась.
;; Теперь мы попробуем запасной метод (на многих чипсетах он
;; не поддерживается, но на некоторых он единственно возможный)


;; Счетчик попыток
mov CX, 5

.startAttempt2:
;; Подождем пока контроллер готов
.commandWait6:
xor AX, AX
in AL, 64h
bt AX, 1
jc .commandWait6

;; Скажем контроллеру, что мы хотим включить A20
mov AL, 0DFh
out 64h, AL

;; Прочитаем статус A20, чтобы убедиться, что A20 включен

;; Подождем пока контроллер готов
.commandWait7:
xor AX, AX
in AL, 64h
bt AX, 1
jc .commandWait7

;; Команда D0h.
mov AL, 0D0h
out 64h, AL

;; Подождем пока контроллер готов
.dataWait3:
xor AX, AX
in AL, 64h
bt AX, 0
jnc .dataWait3

;; Прочитаем байт статуса из порта 60h
xor AX, AX
in AL, 60h

;; A20 включен?
bt AX, 1

;; Проверим CF. Если он установлен, то A20 включен.
;; Предупредим, что пришлось использовать альтернативный метод
jc .warn

;; Повторим операцию, если CX не дошел до нуля
loop .startAttempt2


;; Мда, у нас ничего не получилось. Здесь можно поместить
;; сообщение об ошибке
jmp .fail


.warn:
;; Здесь можно поместить сообщение о том, что пришлось
;; использовать альтернативный метод включения A20

.success:
sti

popa
xor EAX, EAX
ret

.fail:
sti

popa
mov EAX, -1
ret

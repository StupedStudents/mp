nasm -f win32 main.asm -o main1.o 
gcc -ffreestanding -masm=intel -c main.c -o main.o
ld -Ttext=0x0700 main.o main1.o -o main.bin
objcopy main.bin -O binary
nasm -f bin boot.asm -o mbr.img 
nasm -f win32 mne.asm -o mne1.o
gcc -ffreestanding -masm=intel -c mne.c -o mne.o
ld -Ttext=0x100 mne.o mne1.o -o mne.com
objcopy mne.com -O binary



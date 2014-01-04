asm(".code16gcc\n");

void kernel_main() {

	asm("mov ah,9");
	asm("mov al,'1'");
	asm("mov bl,3");
	asm("mov bh,0");
	asm("mov cx,1");
	asm("int 0x10");
}
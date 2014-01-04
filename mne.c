asm(".code16gcc\n");

void print(void);

int _start () {
	int i, j;
	for (i=0; i<1; i++)
		for(j=0; j<1; j++) {}

	print();
return 0;
}
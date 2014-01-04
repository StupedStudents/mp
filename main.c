asm(".code16gcc\n");

typedef unsigned short int uint16;

uint16 setVmode(uint16);
void drawRect(uint16 x, uint16 y, uint16 height, uint16 weight, uint16 page, uint16 color, uint16 fat);
void VideoMode(uint16);
void VideoVesa(uint16);
void setPix(uint16 color, uint16 page, uint16 x, uint16 y);
void setChar(char ch, uint16 num, uint16 color, uint16 page);
void setPos(uint16 page, uint16 x, uint16 y);
uint16 getKey(void);
void setPage(uint16 page);
void drawFillRect(uint16 x_, uint16 y_, uint16 height, uint16 weight, uint16 page, uint16 color);
void drawMenu(void);
void outStr(char* str, uint16 x, uint16 y, uint16 color, uint16 page);
void clrBut(void);
uint16 choseBut(char num);
void powOff(void);
uint16 hardType(void);
uint16 countDrives(void);
void driveStatus(uint16 page, uint16 color);
void clrTxt(uint16 page);
void outTime(void);
void timeAndDate(void);
void setAlarm(void);
void AlarmClock(void);
void keys(void);
void drawScreen(void);

int _main()
{
	char s;
	setVmode(0x102);
	uint16 flag = 0;
	drawScreen();
	drawMenu();
	keys();
	while(1)
	{
		s = getKey();
		if(s >= '1' && s <= '4') { flag = choseBut(s); }
		else if( s == 13 )
		{
			clrTxt(1);
			switch(flag)
			{
				case 1:
					driveStatus(1, 4);
					break;
				case 2:
					timeAndDate();
					break;
				case 3:
					AlarmClock();
					break;
				case 4:
					powOff();
					break;
				default:
					break;
			}
		}
	}
	s = 0;
	return 0;
}

void drawScreen(void)
{
	char buf[8] = {'P', 'r', 'e', 's', 's', ' ', 'X'};
	buf[7] = 0;
	drawRect(50, 50, 500, 700, 0, 4, 15);
	drawFillRect(90, 100, 400, 130, 0, 182);
	drawFillRect(245, 100, 400, 130, 0, 182);
	drawFillRect(425, 100, 400, 130, 0, 182);
	drawFillRect(580, 100, 400, 130, 0, 182);
	drawFillRect(110, 120, 170, 110, 0, 182);
	drawFillRect(90, 310, 170, 110, 0, 182);
	drawFillRect(265, 100, 380, 110, 0, 182);
	drawFillRect(445, 120, 360, 90, 0, 182);
	drawFillRect(600, 120, 170, 110, 0, 182);
	drawFillRect(580, 310, 170, 110, 0, 182);
	outStr(buf, 32, 45, 5, 0);
	char b;
	while(b != 'x')
	{
		b = getKey();
	}
	setVmode(0x102);
	setPage(1);
	return;
}

void keys(void)
{
	char key1[177] = {'P', 'r', 'e', 's', 's', ' ', '1', ' ', 't', 'o', ' ', 'w', 'a', 't', 'c', 'h', ' ', 'i', 'n', 'f', 'o', ' ',
	                  'a', 'b', 'o', 'u', 't', ' ', 'd', 'r', 'i', 'v', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'i', 'r',
	                  ' ', 'n', 'u', 'm', 'b', 'e', 'r', '\n', 'P', 'r', 'e', 's', 's', ' ', '2', ' ', 't', 'o', ' ', 'w', 'a', 't', 'c', 'h', ' ',
	                  'c', 'u', 'r', 'r', 'e', 'n', 't', ' ', 't', 'i', 'm', 'e', '\n', 'P', 'r', 'e', 's', 's', ' ', '3', ' ', 't', 'o', ' ', 's', 'e',
	                  't', ' ', 'a', 'l', 'a', 'r', 'm', '\n', 'P', 'r', 'e', 's', 's', ' ', '4', ' ', 't', 'o', ' ', 's', 'h', 'u', 't', ' ', 'd', 'o',
	                  'w', 'n', ' ', 't', 'h', 'e', ' ', 'O', 'S', '\n', 'T', 'o', ' ', 'c', 'o', 'n', 'f', 'i', 'r', 'm', ' ', 't', 'h', 'e', ' ', 's',
	                  'e', 'l', 'e', 'c', 't', 'i', 'o', 'n', ',', ' ', 'p', 'r', 'e', 's', 's', ' ', 'e', 'n', 't', 'e', 'r'
	                 };
	key1[176] = 0;
	outStr(key1, 18, 5, 4, 1);
}

void AlarmClock(void)
{
	char st[22] = {'S', 'e', 't', ' ', 'A', 'l', 'a', 'r', 'm', '(', 'h', 'h', ' ', 'm', 'm', ' ', 's', 's', ')', ':', ' '};
	st[21] = 0;
	outStr(st, 2, 65, 4, 1);
	setAlarm();
	asm("add sp,2");
	return;
}

void timeAndDate(void)
{
	char tim[15] = {'C', 'u', 'r', 'r', 'e', 'n', 't', ' ', 't', 'i', 'm', 'e', ':', ' '};
	tim[14] = 0;
	outStr(tim, 2, 65, 4, 1);
	setPos(1, 2, 79);
	setChar('2', 1, 4, 1);
	setPos(1, 2, 80);
	setChar('0', 1, 4, 1);
	setPos(1, 2, 81);
	outTime();
	asm("add sp,12");
	return;
}

void clrTxt(uint16 page)
{
	char dev[40] = {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '};
	dev[39] = 0;
	outStr(dev, 2, 65, 0, page);
	outStr(dev, 3, 65, 0, page);
	outStr(dev, 4, 65, 0, page);
	outStr(dev, 5, 65, 0, page);
	return;
}

void driveStatus(uint16 page, uint16 color)
{
	int a;
	char dev1[18] = {'D', 'r', 'i', 'v', 'e', ' ', 'n', 'o', 't', ' ', 'p', 'r', 'e', 's', 'e', 'n', 't'};
	dev1[17] = 0;
	char dev2[28] = {'D', 'i', 's', 'k', 'e', 't', 't', 'e', ',', ' ', 'n', 'o', ' ', 'c', 'h', 'a', 'n', 'g', 'e', ' ', 'p', 'r', 'e', 's', 'e', 'n', 't'};
	dev2[27] = 0;
	char dev3[35] = {'D', 'i', 's', 'k', 'e', 't', 't', 'e', ',', ' ', 'c', 'h', 'a', 'n', 'g', 'e', ' ', 'd', 'e', 't', 'e', 'c', 't', 'i', 'o', 'n', ' ', 'p', 'r', 'e', 's', 'e', 'n', 't'};
	dev3[34] = 0;
	char dev4[19] = {'F', 'i', 'x', 'e', 'd', ' ', 'd', 'i', 's', 'k', ' ', 'p', 'r', 'e', 's', 'e', 'n', 't'};
	dev4[18] = 0;
	char dev5[7] = {'D', 'r', 'i', 'v', 'e', 's'};
	dev5[6] = 0;
	a = hardType();
	switch(a)
	{
		case 0:
			outStr(dev1, 2, 65, color, page);
			break;
		case 1:
			outStr(dev2, 2, 65, color, page);
			break;
		case 2:
			outStr(dev3, 2, 65, color, page);
			break;
		case 3:
			outStr(dev4, 2, 65, color, page);
			break;
		default:
			outStr(dev1, 2, 65, color, page);
			break;
	}
	a = countDrives();
	setPos(page, 3, 65);
	setChar('0' + a, 1, color, page);
	outStr(dev5, 3, 67, color, page);
	asm("add sp,8");
	return;
}

void clrBut(void)
{
	drawRect(93, 101, 53, 109, 1, 0, 4);
	drawRect(93, 197, 53, 109, 1, 0, 4);
	drawRect(293, 101, 53, 109, 1, 0, 4);
	drawRect(293, 197, 53, 109, 1, 0, 4);
}

uint16 choseBut(char num)
{
	uint16 fl;
	clrBut();
	switch(num)
	{
		case '1':
			drawRect(93, 101, 53, 109, 1, 7, 4);
			fl = 1;
			break;
		case '2':
			drawRect(93, 197, 53, 109, 1, 7, 4);
			fl = 2;
			break;
		case '3':
			drawRect(293, 101, 53, 109, 1, 7, 4);
			fl = 3;
			break;
		case '4':
			drawRect(293, 197, 53, 109, 1, 7, 4);
			fl = 4;
			break;
		default:
			fl = 5;
			break;
	}
	return fl;
}

void outStr(char* str, uint16 x, uint16 y, uint16 color, uint16 page)
{
	int i, y_ = y;
	for(i = 0; * (str + i) != 0; i++)
	{
		if(*(str + i) == '\n')
		{
			x++;
			y_ = y;
			continue;
		}
		setPos(page, x, y_);
		asm("add sp,2");
		setChar(*(str + i), 1, color, page);
		asm("add sp,2");
		y_++;
	}
}

void drawMenu(void)
{
	char ptr[4][24] =
	{
		{' ', ' ', '1', '.', 'H', 'a', 'r', 'd', ' ', ' ', ' ', '\n', ' ', ' ', 'D', 'r', 'i', 'v', 'e', 's', ' ', ' ', ' '},
		{' ', ' ', '2', '.', 'D', 'a', 't', 'e', ' ', ' ', ' ', '\n', ' ', ' ', ' ', 'T', 'i', 'm', 'e', ' ', ' ', ' ', ' '},
		{' ', ' ', '3', '.', 'A', 'l', 'a', 'r', 'm', ' ', ' ', '\n', ' ', ' ', ' ', 'C', 'l', 'o', 'c', 'k', ' ', ' ', ' '},
		{' ', ' ', '4', '.', 'S', 'h', 'u', 't', ' ', ' ', ' ', '\n', ' ', ' ', ' ', 'D', 'o', 'w', 'n', ' ', ' ', ' ', ' '}
	};
	ptr[0][23] = 0;
	ptr[1][23] = 0;
	ptr[2][23] = 0;
	ptr[3][23] = 0;
	drawRect(97, 105, 45, 101, 1, 4, 7);
	drawRect(97, 201, 45, 101, 1, 4, 7);
	drawRect(297, 105, 45, 101, 1, 4, 7);
	drawRect(297, 201, 45, 101, 1, 4, 7);
	outStr(ptr[0], 7, 13, 182, 1);
	outStr(ptr[1], 13, 13, 182, 1);
	outStr(ptr[2], 7, 38, 182, 1);
	outStr(ptr[3], 13, 38, 182, 1);
	return;
}

void drawFillRect(uint16 x_, uint16 y_, uint16 height, uint16 weight, uint16 page, uint16 color)
{
	uint16 i, j;
	for(i = x_; i < x_ + weight; i++)
	{
		for(j = y_; j < y_ + height; j++)
		{
			setPix(color, page, i, j);
			if(x_ != x_ + weight - 1 && y_ != y_ + height - 1) { asm("add sp,2"); } // don't touch, it's a magic
		}
	}
}

uint16 setVmode(uint16 mode)
{
	if (mode >= 0x0 && mode <= 0x13) { VideoMode(mode); }
	else if (mode >= 0x100 && mode <= 0x10c) { VideoVesa(mode); }
	else { return 1; }
	return 0;
}

void drawRect(uint16 x_, uint16 y_, uint16 height, uint16 weight, uint16 page, uint16 color, uint16 fat)
{
	uint16 i, j;
	for(j = 0; j < fat; j++)
	{
		for(i = x_; i < x_ + weight; i++)
		{
			setPix(color, page, i, y_);
			asm("add sp,2");
		}
		for(i = y_; i < y_ + height; i++)
		{
			setPix(color, page, x_ + weight, i);
			asm("add sp,2");
		}
		for(i = x_ + weight; i > x_; i--)
		{
			setPix(color, page, i, y_ + height);
			asm("add sp,2");
		}
		for(i = y_ + height; i > y_; i--)
		{
			setPix(color, page, x_, i);
			asm("add sp,2");
		}
		y_++;
		x_++;
		weight -= 2;
		height -= 2;
	}
}


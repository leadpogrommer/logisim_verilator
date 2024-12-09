#pragma once
#define N 30

extern volatile unsigned int VRAM_ADDR;
extern volatile unsigned int VRAM_DATA;

void life(char src[N][N], char dst[N][N]);
void display(char data[N][N]);
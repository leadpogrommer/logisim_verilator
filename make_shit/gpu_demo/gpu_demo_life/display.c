#include "life.h"

void display(char data[N][N]){
  VRAM_ADDR = 0xffff;
  for(int i = 0; i < N; i++){
    for(int j = 0; j < N; j++){
      VRAM_DATA = data[i][j]? '#' : ' ';
    }
    for(int j = 0; j < (80 - N); j++){
      VRAM_DATA = 0;
    }
  }
}
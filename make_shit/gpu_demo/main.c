extern volatile unsigned int VRAM_ADDR;
extern volatile unsigned int VRAM_DATA;

static int cline = 0;
static int ccol = 0;

__attribute__((noinline))
void putc(char c){
    VRAM_DATA = c;
    ccol += 1;
    if (ccol >= 80){
        ccol = 0;
        cline ++;
        if(cline >= 30){
            cline = 0;
        }
    }
}

__attribute__((noinline))
void puts(char *s){
    while (*s != 0){
        if(*s == '\n'){
            int cur_line = cline;
            while(cline == cur_line)putc(' ');
        }else{
            putc(*s);
        }
        s++;
    }
}

__attribute__((noinline))
char n_to_hex(char n){
    return n > 9 ? 'A' + (n-10) : n+'0';
}

__attribute__((noinline))
void print_hext(char i){
    putc(n_to_hex((i >> 4) & 0xf));
    putc(n_to_hex(i & 0xf));
}


__attribute__((noinline))
int main(){
    VRAM_ADDR = 0xffff;
    for(int i = 0; i < 80*30; i++){
        VRAM_DATA = 0;
    }
    VRAM_ADDR = 0xffff;

    puts("CdM16 FizzBuzz v0.0.1\n");
    int _3 = 0;
    int _5 = 0;

    for(int i = 0; i < 29; i++){
        int flag = 0;
        if(_3 == 3){
            puts("Fizz");
            _3 = 0;
            flag = 1;
        }
        if(_5 == 5){
            puts("Buzz");
            _5 = 0;
            flag = 1;
        }

        if(!flag){
            print_hext(i);
        }

        puts("\n");
        _3++;
        _5++;
    }

}
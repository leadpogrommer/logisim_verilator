#include "font.h"
#define N (0x1000)
#define N_DSP 3
#define NI __attribute__((noinline))

extern volatile unsigned int LEDS[4];
extern volatile unsigned int BUTTONS;
extern volatile unsigned int AUDIO_FIRST[N];
extern volatile unsigned int AUDIO_SECOND[N];
extern volatile int DSP_RUNNING;
extern volatile int FREE_HALF;


unsigned int font[] = {F_0, F_1, F_2, F_3, F_4, F_5, F_6, F_7, F_8, F_9, F_A, F_B, F_C, F_D, F_E, F_F};


int current_dsp = 0;

unsigned int dsp_names[][4] = {
    {F_P, F_A, F_5, F_5},
    {F_T, F_R, F_1, 0},
    // {F_H, F_1, 0, 0},
    {F_L, F_0, 0, 0},
};

// pass through
NI void dsp_pass(unsigned int *samples){}

// just a triangle, input ignored
NI void dsp_triangle(unsigned int *samples){
    static unsigned char trinum = 0;
    for(int i = 0; i < N; i++){
        samples[i] = ((unsigned int)(trinum++) << 6)  + (1 << 15) - (1 << (15 - 3)) ;
    }
}

static int prev_val = 0;
static int prev_x = 0;
static int prev_y = 0;

// NI void dsp_hi(unsigned int *samples){
//     for(int i = 0; i < N; i++){
//         int val = (samples[i] >> 1);
//         val -= 0x4000;

//         // int w = val + (prev_val >> 3);
//         // val = w - prev_val;
//         // prev_val = w;

//         // val = prev_val + ((val - prev_val) >> 5);
//         // prev_val = val;
//         int tmp = (prev_y + val - prev_val);

//         int y =  (tmp >> 1);
//         prev_y = y;
//         prev_x = val;
//         val = y;

//         val += 0x4000;
//         samples[i] = val << 1;

//     }
// }

NI void dsp_lo(unsigned int *samples){
    for(int i = 0; i < N; i++){
        int val = (samples[i] >> 1);
        val -= 0x4000;

        val = prev_val + ((val - prev_val) >> 5);
        prev_val = val;

        val += 0x4000;
        samples[i] = val << 1;

    }
}

NI void run_dsp(unsigned int *samples){
    DSP_RUNNING = 1;
    switch (current_dsp){
        case 0: dsp_pass(samples); break;
        case 1: dsp_triangle(samples); break;
        // case 2: dsp_hi(samples); break;
        case 2: dsp_lo(samples); break;
    }
    DSP_RUNNING = 0;
}

static void print_name(int i){
    for(int j = 0; j < 4; j++){
        LEDS[3-j] = dsp_names[i][j];
    }
}

NI void check_buttons(){
    int bv = BUTTONS;
    for(int i = 0; i < N_DSP; i++){
        if(bv & 1){
            current_dsp = i;
            print_name(i);
        }
        bv >>= 1;
    }
}

NI void main(){
    print_name(0);
    while (FREE_HALF == 0);
    while (FREE_HALF == 1)
    while(1){
        check_buttons();
        while(FREE_HALF == 0);
        run_dsp(AUDIO_FIRST);
        check_buttons();
        while(FREE_HALF == 1);
        run_dsp(AUDIO_SECOND);
    }
}
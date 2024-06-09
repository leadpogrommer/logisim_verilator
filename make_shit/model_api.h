#include "stdint.h"

#ifdef __cplusplus
extern "C" {
#endif



void init();
void deinit();

void* create_state();
void destroy_state(void *state);

// inputs + outputs
void eval(void* state, const uint32_t *ins, uint32_t *outs);


int get_input_port_count();
int get_output_port_count();

char **get_port_names();
int *get_port_widths();



#ifdef __cplusplus
}
#endif
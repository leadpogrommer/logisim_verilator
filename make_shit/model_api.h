#include "stdint.h"

#ifdef __cplusplus
extern "C" {
#endif

struct state_t;

void init();
void deinit();

state_t* create_state();
void destroy_state(state_t *state);

// inputs + outputs
void eval(state_t* state, const uint32_t *ins, uint32_t *outs);


int get_input_port_count();
int get_output_port_count();

char **get_port_names();
int *get_port_widths();
char **get_port_metadata();
int *get_port_placement();


#ifdef __cplusplus
}
#endif
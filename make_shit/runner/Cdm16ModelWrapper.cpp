#include "Cdm16ModelWrapper.h"

void Cdm16ModelWrapper::doClockRaise() {
    modelState.input_clock = 1;
    modelState.uc_in_normal = normal_ucode[modelState.ucode_addr];
    modelState.uc_in_exception = exc_ucode[modelState.ucode_addr];
    modelState.eval();

    if(modelState.mem != 0){
        if(modelState.read != 0){
            modelState.data_in = memBus.read(modelState.address, modelState.word);
        } else {
            memBus.write(modelState.address, modelState.data_out, modelState.word);
        }
    }


    updateTrace();
}

void Cdm16ModelWrapper::doClockFall() {
    modelState.input_clock = 0;
    modelState.uc_in_normal = normal_ucode[modelState.ucode_addr];
    modelState.uc_in_exception = exc_ucode[modelState.ucode_addr];
    modelState.eval();
    updateTrace();
}

void Cdm16ModelWrapper::doTick() {
    doClockRaise();
    doClockFall();
}

bool Cdm16ModelWrapper::isHalted() {
    return modelState.status != 0;
}

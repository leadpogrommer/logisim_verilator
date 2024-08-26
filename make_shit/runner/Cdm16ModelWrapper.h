//
// Created by ilya on 22.08.2024.
//

#ifndef RUNNER_CDM16MODELWRAPPER_H
#define RUNNER_CDM16MODELWRAPPER_H

#include <memory>
#include <utility>
#include <verilated.h>
#include "verilated_vcd_c.h"
#include <Vcdm16.h>
#include "MemoryBus.h"

class Cdm16ModelWrapper {
public:
    void doClockRaise();

    void doClockFall();

    void doTick();

    bool isHalted();

    explicit Cdm16ModelWrapper(MemoryBus memBus, std::vector<uint32_t> nu, std::vector<uint32_t> eu, std::string _tracePath) : memBus(
            std::move(memBus)), normal_ucode(std::move(nu)), exc_ucode(std::move(eu)), tracePath(std::move(_tracePath)) {
        doTrace = !tracePath.empty();

        if(doTrace){
            vcdc = new VerilatedVcdC;
            Verilated::traceEverOn(true);
            modelState.trace(vcdc, 99);
            vcdc->open(tracePath.c_str());
        }

    }

    ~Cdm16ModelWrapper(){
        if(doTrace){
            vcdc->close();
            delete vcdc;
        }
    }

private:
    std::string tracePath;
    bool doTrace;
    VerilatedContext verCtx;
    Vcdm16 modelState{&verCtx};
    MemoryBus memBus;
    std::vector<uint32_t> normal_ucode;
    std::vector<uint32_t> exc_ucode;

    VerilatedVcdC* vcdc;
    int ticksPassed = 0;

    void updateTrace(){
        if(doTrace){
            vcdc->dump(ticksPassed++);
        }
    }
};


#endif //RUNNER_CDM16MODELWRAPPER_H

#ifndef RUNNER_MEMORYBUS_H
#define RUNNER_MEMORYBUS_H

#include <cstdint>
#include <memory>
#include <deque>
#include "MMIODevice.h"

struct MapRange{
    uint16_t address;
    std::shared_ptr<MMIODevice> device;
};

class MemoryBus {
public:
    uint16_t read(uint16_t addr, bool isWord);
    void write(uint16_t addr, uint16_t data, bool isWord);
    void pushDevice(uint16_t address, std::shared_ptr<MMIODevice> device);

private:

    std::deque<MapRange> devices;
};

#endif //RUNNER_MEMORYBUS_H

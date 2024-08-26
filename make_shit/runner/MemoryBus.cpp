#include "MemoryBus.h"

#include <utility>

uint16_t MemoryBus::read(uint16_t addr, bool isWord) {
    for(const auto& range: devices){
        if(range.address <= addr && addr < (range.address + range.device->getLength())){
            return range.device->read(addr - range.address, isWord);
        }
    }
    return 0;
}

void MemoryBus::write(uint16_t addr, uint16_t data, bool isWord) {
    for(const auto& range: devices){
        if(range.address <= addr && addr < (range.address + range.device->getLength())){
            range.device->write(addr - range.address, data, isWord);
        }
    }
}

void MemoryBus::pushDevice(uint16_t address, std::shared_ptr<MMIODevice> device) {
    devices.push_front({address, std::move(device)});
}

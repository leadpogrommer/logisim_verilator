//
// Created by ilya on 22.08.2024.
//

#include <iostream>

#include "MMIODevice.h"

// Ram device
uint16_t RamDevice::read(uint16_t offset, bool isWord) {
    if (offset == content.size() - 1) {
        return content[offset];
    }
    return content[offset] | (content[offset + 1] << 8);
}

void RamDevice::write(uint16_t offset, uint16_t data, bool isWord) {
    content[offset] = data & 0xff;
    if(offset < content.size() - 1 && isWord){
        content[offset] = (data >> 8) & 0xff;
    }
}

size_t RamDevice::getLength() {
    return content.size();
}

// IO device
uint16_t StdIODevice::read(uint16_t offset, bool isWord) {
    return 0; // TODO: reading
}

void StdIODevice::write(uint16_t offset, uint16_t data, bool isWord) {
    std::cout << (char)(data & 0xff);
}

size_t StdIODevice::getLength() {
    return 2;
}

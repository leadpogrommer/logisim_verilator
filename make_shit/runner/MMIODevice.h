#ifndef RUNNER_MMIODEVICE_H
#define RUNNER_MMIODEVICE_H

#include <cstdint>
#include <utility>
#include <vector>

class MMIODevice{
public:
    virtual uint16_t read(uint16_t offset, bool isWord) = 0;
    virtual void write(uint16_t offset, uint16_t data, bool isWord) = 0;
    virtual size_t getLength() = 0;
};

class RamDevice: public MMIODevice {
public:
    explicit RamDevice(std::vector<uint8_t> initialContent): content{std::move(initialContent)} {}

    uint16_t read(uint16_t offset, bool isWord) override;
    void write(uint16_t offset, uint16_t data, bool isWord) override;
    size_t getLength() override;

private:
    std::vector<uint8_t> content;
};

class StdIODevice: public MMIODevice {
    uint16_t read(uint16_t offset, bool isWord) override;
    void write(uint16_t offset, uint16_t data, bool isWord) override;
    size_t getLength() override;

};

#endif //RUNNER_MMIODEVICE_H

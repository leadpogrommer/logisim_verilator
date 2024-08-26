#include <iostream>
#include <algorithm>

#include <CLI/CLI.hpp>

#include "MMIODevice.h"
#include "MemoryBus.h"
#include "Cdm16ModelWrapper.h"

template<typename T>
std::vector<T> loadImg(const std::string& path, int addr_width){
    std::ifstream input(path);
//    for(std::string line; getline(input, line);){
//        auto first_ns = std::find_if_not(line.begin(), line.end(), [](char c)->bool {return std::isspace(c);});
//        auto last_ns = std::ranges::find_last_if_not(line.begin(), line.end(), [](char c)->bool {return std::isspace(c);}).begin();
//        last_ns ++;
//
//        std::string stripped;
//        std::copy(first_ns, last_ns, std::back_inserter(stripped));
//
//        std::cout << '|' << stripped << '|' << std::endl;
//
//    }
    std::string dummy;
    getline(input, dummy);

    std::string token;
    bool in_comment = false;

    std::vector<T> res(1<<(addr_width));
    int res_pos = 0;

    while (input){
        char c = input.get();
        if (c < 0)break;
//        std::cout << c;
        if(!std::isspace(c) && c != '#' && !in_comment){
            token.push_back(c);
        } else {
            if(token.size() != 0){
                int spos;
                if ((spos = token.find('*')) == -1){
                    res[res_pos++] = std::stoul(token, nullptr, 16);
                }else{
                    int amt = std::strtoul(token.c_str(), nullptr, 10);
                    T v = std::strtoul(token.c_str()+spos+1, nullptr, 106);
                    for(int i = 0; i < amt; i++){
                        res[res_pos++] = v;
                    }
                }
                token.clear();
            }
        }

        if (in_comment && c == '\n'){
            in_comment = false;
        }
        if (c == '#') {
            in_comment = true;
        }
    }

    return res;
}


int main(int argc, char **argv) {
    CLI::App app{"CdM16 verilog model runner"};
    std::string input_filename;
    std::string trace_filename;
    app.add_option("--trace", trace_filename, "Enable tracing and write results to specified file");
    app.add_option("input", input_filename, "Input file")->required(true);
    CLI11_PARSE(app, argc, argv);
    auto img = loadImg<uint8_t>(input_filename, 16);
    auto normal_ucode = loadImg<uint32_t>("cdm16_decoder.img", 10);
    auto exc_ucode = loadImg<uint32_t>("cdm16_decoder_exc.img", 10);

    MemoryBus bus;
    bus.pushDevice(0x00, std::make_shared<RamDevice>(img));
    bus.pushDevice(0xF000, std::make_shared<StdIODevice>());

    Cdm16ModelWrapper model(std::move(bus), normal_ucode, exc_ucode, trace_filename);

    while (!model.isHalted()){
        model.doTick();
    }

    return 0;
}

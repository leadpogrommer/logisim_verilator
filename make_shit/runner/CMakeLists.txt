cmake_minimum_required(VERSION 3.29)
project(runner)

set(CMAKE_CXX_STANDARD 23)

# https://discourse.cmake.org/t/whats-the-best-way-to-add-thirdparty-lib-with-existing-makefile/3397/2
add_custom_target(BuilCdm16Model ALL
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/..
    COMMAND make build/verilog_top_cdm16
)


foreach (LIB Vcdm16 verilated)
    add_library("Lib${LIB}" STATIC IMPORTED)
    set_target_properties("Lib${LIB}" PROPERTIES
        IMPORTED_LOCATION "${PROJECT_SOURCE_DIR}/../build/verilog_top_cdm16/lib${LIB}.a"
        INTERFACE_INCLUDE_DIRECTORIES "${PROJECT_SOURCE_DIR}/../build/verilog_top_cdm16;/usr/share/verilator/include"
    )
    add_dependencies("Lib${LIB}" BuilCdm16Model)
endforeach ()

find_package(CLI11 REQUIRED)

add_executable(runner main.cpp MemoryBus.cpp
        MMIODevice.cpp
        MMIODevice.h
        Cdm16ModelWrapper.cpp
        Cdm16ModelWrapper.h)
target_link_libraries(runner LibVcdm16 Libverilated CLI11::CLI11)
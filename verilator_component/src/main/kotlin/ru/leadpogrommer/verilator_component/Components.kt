package ru.leadpogrommer.verilator_component

import com.cburch.logisim.tools.AddTool
import com.cburch.logisim.tools.Library
import com.cburch.logisim.tools.Tool

class Components: Library() {
    private val tools = mutableListOf<Tool>(
        AddTool(VerilatorComponent("ALU_epty", "/home/ilya/work/cdm_clang/verilog_shit/make_shit/build/ALU.so")),
        AddTool(VerilatorComponent("branch_logic", "/home/ilya/work/cdm_clang/verilog_shit/make_shit/build/branch_logic.so")),
        AddTool(VerilatorComponent("bus_control", "/home/ilya/work/cdm_clang/verilog_shit/make_shit/build/bus_control.so")),
        AddTool(VerilatorComponent("registers", "/home/ilya/work/cdm_clang/verilog_shit/make_shit/build/registers.so")),
    )

    override fun getTools(): MutableList<out Tool> {
        return tools
    }

    override fun getName(): String {
        return "Verilator Components"
    }
}
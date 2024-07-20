package ru.leadpogrommer.verilator_component

import com.cburch.logisim.tools.AddTool
import com.cburch.logisim.tools.Library
import com.cburch.logisim.tools.Tool
import kotlin.io.path.Path
import kotlin.io.path.absolute
import kotlin.io.path.readText


class Components: Library() {
    val basDir = Path( System.getProperty("user.home"), ".config", "logisim_verilator_libs_path").readText().trim()

    private val tooNamesLibs = mapOf("ALU_epty" to "ALU", "branch_logic" to "branch_logic", "bus_control" to "bus_control", "registers" to "registers")
//
//    private val tools = mutableListOf<Tool>(
//        AddTool(VerilatorComponent("ALU_epty", "/home/ilya/work/cdm_clang/verilog_shit/make_shit/build/ALU.so")),
//        AddTool(VerilatorComponent("branch_logic", "/home/ilya/work/cdm_clang/verilog_shit/make_shit/build/branch_logic.so")),
//        AddTool(VerilatorComponent("bus_control", "/home/ilya/work/cdm_clang/verilog_shit/make_shit/build/bus_control.so")),
//        AddTool(VerilatorComponent("registers", "/home/ilya/work/cdm_clang/verilog_shit/make_shit/build/registers.so")),
//    )

    private val tools = tooNamesLibs.map { (name, lib)  -> AddTool(VerilatorComponent(name, Path(basDir, "$lib.so").absolute().toString())) }

    override fun getTools(): List<Tool> {
        return tools
    }

    override fun getName(): String {
        return "Verilator Components"
    }
}
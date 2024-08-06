package ru.leadpogrommer.verilator_component

import com.cburch.logisim.tools.AddTool
import com.cburch.logisim.tools.Library
import com.cburch.logisim.tools.Tool
import kotlin.io.path.Path
import kotlin.io.path.absolute
import kotlin.io.path.readText


class Components : Library() {
    override fun getTools(): List<Tool> {
        return Components.tools
    }

    override fun getName(): String {
        return "Verilator Components"
    }

    companion object {
        val baseDir = Path(System.getProperty("user.home"), ".config", "logisim_verilator_libs_path").readText().trim()
        private val tooNamesLibs = mapOf(
            "ALU_epty" to "ALU",
            "branch_logic" to "branch_logic",
            "bus_control" to "bus_control",
            "registers" to "registers",
            "decoder" to "decoder",
            "cdm16" to "cdm16"
        )
        private val tools = tooNamesLibs.map { (name, lib) ->
            AddTool(
                VerilatorComponent(
                    name,
                    Path(baseDir, "$lib.so").absolute().toString()
                )
            )
        }
    }
}
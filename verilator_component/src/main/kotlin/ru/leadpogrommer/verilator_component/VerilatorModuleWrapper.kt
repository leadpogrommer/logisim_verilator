package ru.leadpogrommer.verilator_component

import java.lang.foreign.*
import java.lang.invoke.MethodHandle
import java.nio.file.Path

class VerilatorModuleWrapper(path: String) {
    private val lookup = SymbolLookup.libraryLookup(Path.of(path), Arena.global())
    private val linker = Linker.nativeLinker()

    private val initF = getVoidF("init")
    private val deinitF = getVoidF("deinit") // TODO: actually call it

    private val createStateF = getF("create_state", ValueLayout.ADDRESS)
    private val destroyStateF = getVoidF("destroy_state", ValueLayout.ADDRESS) // TODO: actually call it

    private val evalF = getVoidF("eval", ValueLayout.ADDRESS, ValueLayout.ADDRESS, ValueLayout.ADDRESS)

    private val getInputPortCountF = getF("get_input_port_count", ValueLayout.JAVA_INT)
    private val getOutputPortCountF = getF("get_output_port_count", ValueLayout.JAVA_INT)

    private val getPortNamesF = getF("get_port_names", ValueLayout.ADDRESS)
    private val getPortWidthsF = getF("get_port_widths", ValueLayout.ADDRESS)
    private val getPortMetadataF = getF("get_port_metadata", ValueLayout.ADDRESS)
    private val getPortPlacementF = getF("get_port_placement", ValueLayout.ADDRESS)

    init {
        initF.invoke()
    }

    fun createState(): MemorySegment {
        return createStateF.invoke() as MemorySegment
    }

    fun destroyState(state: MemorySegment) {
        destroyStateF.invoke(state)
    }

    fun eval(state: MemorySegment, ins: IntArray): IntArray {
        if(ins.size != inputPortCount){
            throw IllegalArgumentException("Invalid number of input ports: ${ins.size} instead of $inputPortCount")
        }
        val arena = Arena.global()
        val insArr = arena.allocateFrom(ValueLayout.JAVA_INT, *ins)
        val outsArr = arena.allocate(ValueLayout.JAVA_INT, outputPortCount.toLong())

        evalF.invoke(state, insArr, outsArr)

        return outsArr.toArray(ValueLayout.JAVA_INT)
    }

    val inputPortCount: Int by lazy { getInputPortCountF.invoke() as Int }
    val outputPortCount: Int by lazy { getOutputPortCountF.invoke() as Int }
    val totalPorts = inputPortCount + outputPortCount

    val portNames = callStringArrayFunction(getPortNamesF, totalPorts)
    val portWidths = callIntArrayFunction(getPortWidthsF, totalPorts)
    val portMetadata = callStringArrayFunction(getPortMetadataF, totalPorts)
    val portPlacement = callIntArrayFunction(getPortPlacementF, totalPorts)



    private fun getF(name: String, resLayout: MemoryLayout, vararg argsLayout: MemoryLayout): MethodHandle =
        linker.downcallHandle(lookup.find(name).get(), FunctionDescriptor.of(resLayout, *argsLayout))
    private fun getVoidF(name: String, vararg argsLayout: MemoryLayout): MethodHandle =
        linker.downcallHandle(lookup.find(name).get(), FunctionDescriptor.ofVoid(*argsLayout))


    override fun toString(): String {
        return "{inputs = ${(0 until inputPortCount).map { "${portNames[it]}[${portWidths[it]}]" }.joinToString(", ")}; outputs = ${(inputPortCount until totalPorts).map { "${portNames[it]}[${portWidths[it]}]" }.joinToString(", ")}}"
    }

    private fun callIntArrayFunction(f: MethodHandle, size: Int): List<Int> {
        val res = (f.invoke() as MemorySegment).reinterpret(totalPorts * ValueLayout.JAVA_INT.byteSize())
        return (0 until size).map {
            res.getAtIndex(ValueLayout.JAVA_INT, it.toLong())
        }
    }

    private fun callStringArrayFunction(f: MethodHandle, size: Int): List<String> {
        val res = (f.invoke() as MemorySegment).reinterpret(totalPorts * ValueLayout.ADDRESS.byteSize())
        return (0 until size).map {
            res.getAtIndex(ValueLayout.ADDRESS, it.toLong()).reinterpret(100).getString(0)
        }
    }
}
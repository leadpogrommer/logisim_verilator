package ru.leadpogrommer.verilator_component

import com.cburch.logisim.data.BitWidth
import com.cburch.logisim.data.Bounds
import com.cburch.logisim.data.Value
import com.cburch.logisim.instance.InstanceData
import com.cburch.logisim.instance.InstanceFactory
import com.cburch.logisim.instance.InstancePainter
import com.cburch.logisim.instance.InstanceState
import com.cburch.logisim.instance.Port
import com.cburch.logisim.util.GraphicsUtil
import ru.leadpogrommer.verilator_component.VerilatorModuleWrapper
import java.lang.foreign.MemorySegment


class VerilatorInstanceData(val state: MemorySegment): InstanceData {


    override fun clone(): Any {
        TODO("cannot be implemented")
    }

}

class VerilatorComponent(name: String, path: String): InstanceFactory(name) {
    private val lib = VerilatorModuleWrapper(path)


    init {
        setOffsetBounds(Bounds.create(0, 0, WIDTH, lib.totalPorts * PORT_HEIGHT));
        val ports = arrayListOf<Port>()
        for(i in 0 until lib.totalPorts){
            ports.add(Port(WIDTH, i* PORT_HEIGHT + PORT_HEIGHT/2, if(i < lib.inputPortCount) Port.INPUT else Port.OUTPUT, lib.portWidths[i]))
        }

        setPorts(ports.toTypedArray())
    }


    override fun paintInstance(painter: InstancePainter?) {
        if (painter == null) return;
        painter.drawBounds()
        painter.drawPorts()

        val bds = painter.location

        for(i in 0 until lib.totalPorts){
            GraphicsUtil.drawText(painter.graphics, "${lib.portNames[i]} ${if(i < lib.inputPortCount)"<" else ">"}", WIDTH + bds.x, i * PORT_HEIGHT + PORT_HEIGHT/2 + bds.y, GraphicsUtil.H_RIGHT, GraphicsUtil.V_CENTER);
        }
    }

    override fun propagate(state: InstanceState?) {
        if(state == null) {
            return
        }

        if(state.data == null){
            state.data = VerilatorInstanceData(lib.createState())
        }

        val ins = (0 until lib.inputPortCount).map { state.getPort(it).toIntValue() }.toIntArray()
        val res = lib.eval( (state.data as VerilatorInstanceData).state, ins)

        for (i in 0 until lib.outputPortCount) {
            val portI = i + lib.inputPortCount
            state.setPort(portI, Value.createKnown(BitWidth.create(lib.portWidths[portI]), res[i]), 0)
        }
    }

    companion object {
        const val WIDTH = 50
        const val PORT_HEIGHT = 20
    }
}
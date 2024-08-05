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
import kotlin.math.max


class VerilatorInstanceData(val state: MemorySegment): InstanceData {


    override fun clone(): Any {
        TODO("cannot be implemented")
    }

    protected fun finalize(){
//        println("TODO: destroy state")

    }

}

interface StringEnum{
    val s: String
}

enum class Side(override val s: String, val axis: Int, val otherAxisIsZero: Boolean): StringEnum{
    TOP("t", 0, true), BOTTOM("b", 0, false), LEFT("l", 1, true), RIGHT("r", 1, false);
}

//enum class Alignment(override val s: String): StringEnum{
//    BEGIN("b"), CENTER("c"), END("e");
//}

inline fun <reified T> byName(s: String): T where T: Enum<T>, T: StringEnum{
    return enumValues<T>().first { it.s == s }
}

class SectionInfo(var length: Int, val ports: MutableList<PlacementSpec>)

data class PlacementSpec(val step: Int, val text: String?)

data class TextSpec(val text: String, val x: Int, val y: Int, val halign: Int, val valign: Int)

fun Value.toIntNoError(): Int {
    if(this.isFullyDefined) return this.toIntValue()
    return 0;
}

class VerilatorComponent(name: String, path: String): InstanceFactory(name) {
    private val lib = VerilatorModuleWrapper(path)
    private val labels = mutableListOf<TextSpec>()
    var width = 100
    var height = -1

    init {


        // lib.portPlacement: .so index -> logisim index
        // orderMap: logisim index -> .so index

        val orderMap = IntArray(lib.totalPorts)
        for (i in 0 until lib.totalPorts){
            orderMap[lib.portPlacement[i]] = i
        }



        val portPlacements = Side.entries.associateWith { s -> mutableListOf<PlacementSpec>() }.toMutableMap()
        var currentSide: Side = Side.RIGHT
        var currentStep = 20
        val ports = arrayListOf<Port>()
        var sideOffsets = mutableMapOf(Side.TOP to CORNER_GAP, Side.BOTTOM to CORNER_GAP, Side.LEFT to CORNER_GAP + TEXT_HEIGHT, Side.RIGHT to CORNER_GAP + TEXT_HEIGHT)
        val portCoords = mutableListOf<IntArray>()


        for(i in 0 until lib.totalPorts){
            val libIndex = orderMap[i]
            var overrideText: String? = null
            for (pair in lib.portMetadata[libIndex].split(',')){
                if (pair == "") continue
                val (flag, value) = pair.split(':')
                when(flag){
                    "p" -> currentSide = byName(value)
//                    "a" -> currentAlign = byName(value)
                    "s" -> currentStep = value.toInt()
                    "t" -> overrideText = value
                    "w" -> width = value.toInt()
                    else -> throw IllegalArgumentException("Unknown port metadata flag: $flag")
                }
            }
            var text = overrideText ?: if(currentSide == Side.RIGHT || currentSide == Side.LEFT) lib.portNames[libIndex] else null
            val isInput = libIndex < lib.inputPortCount
            text = when(currentSide to isInput){
                Side.LEFT to true -> ">" + text
                Side.LEFT to false -> "<" + text
                Side.RIGHT to true -> text + "<"
                Side.RIGHT to false -> text + ">"
                else -> text
            }

            val axisCoords = intArrayOf(width, height)
            val coords = IntArray(2)
            coords[currentSide.axis] = sideOffsets[currentSide]!!
            sideOffsets[currentSide] = sideOffsets[currentSide]!! + currentStep
            coords[1 xor currentSide.axis] = if(currentSide.otherAxisIsZero) 0 else axisCoords[1 xor currentSide.axis]

            portCoords.add(coords)

            if(text != null){
                val textPlacement = when(currentSide){
                    Side.TOP -> TextSpec(text, coords[0], coords[1], GraphicsUtil.H_LEFT, GraphicsUtil.V_TOP)
                    Side.BOTTOM -> TextSpec(text, coords[0], coords[1], GraphicsUtil.H_LEFT, GraphicsUtil.V_BOTTOM)
                    Side.LEFT -> TextSpec(text, coords[0], coords[1], GraphicsUtil.H_LEFT, GraphicsUtil.V_CENTER)
                    Side.RIGHT -> TextSpec(text, coords[0], coords[1], GraphicsUtil.H_RIGHT, GraphicsUtil.V_CENTER)
                }
                labels.add(textPlacement)
            }

        }
        height = max(sideOffsets[Side.LEFT]!!, sideOffsets[Side.RIGHT]!!) + TEXT_HEIGHT*2 + CORNER_GAP
        for(i in 0 until lib.totalPorts) {
            val libIndex = orderMap[i]
            val y = portCoords[i][1]
            ports.add(Port(portCoords[i][0], if(y >= 0) y else height, if(libIndex < lib.inputPortCount) Port.INPUT else Port.OUTPUT, lib.portWidths[libIndex]))
        }




        setPorts(ports.toTypedArray())
        setOffsetBounds(Bounds.create(0, 0, width, height));
    }



    override fun paintInstance(painter: InstancePainter?) {
        if (painter == null) return;
        painter.drawBounds()
        painter.drawPorts()

        val bds = painter.location

        for(l in labels){
            GraphicsUtil.drawText(painter.graphics, l.text, bds.x + l.x, bds.y + if(l.y >= 0)l.y else height, l.halign, l.valign)
//            GraphicsUtil.drawText(painter.graphics, "${lib.portNames[i]} ${if(i < lib.inputPortCount)"<" else ">"}", WIDTH + bds.x, i * PORT_HEIGHT + PORT_HEIGHT/2 + bds.y, GraphicsUtil.H_RIGHT, GraphicsUtil.V_CENTER);
        }

        val textX = width / 2 + bds.x
        val textY = height - TEXT_HEIGHT + bds.y

        val textBds = GraphicsUtil.getTextBounds(painter.graphics, name, textX, textY, GraphicsUtil.H_CENTER, GraphicsUtil.V_BOTTOM)
        painter.graphics.drawRect(textBds.x-1, textBds.y-1, textBds.width+1, textBds.height+1)
        GraphicsUtil.drawText(painter.graphics, name, textX, textY, GraphicsUtil.H_CENTER, GraphicsUtil.V_BOTTOM)
    }

    override fun propagate(state: InstanceState?) {
        if(state == null) {
            return
        }

        if(state.data == null){
            state.data = VerilatorInstanceData(lib.createState())
        }

        val ins = (0 until lib.inputPortCount).map { state.getPort(lib.portPlacement[it]).toIntNoError() }.toIntArray()
        val res = lib.eval( (state.data as VerilatorInstanceData).state, ins)

        for (i in 0 until lib.outputPortCount) {
            val portI = i + lib.inputPortCount
            state.setPort(lib.portPlacement[portI], Value.createKnown(BitWidth.create(lib.portWidths[portI]), res[i]), 0)
        }
    }

    companion object {
        const val CORNER_GAP = 10
        const val TEXT_HEIGHT = 20
    }
}
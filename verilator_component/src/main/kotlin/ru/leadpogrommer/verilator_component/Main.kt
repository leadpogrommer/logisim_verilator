package ru.leadpogrommer.verilator_component

//import jdk.incubator.foreign.SymbolLookup

fun main(){
    println("Hello")

//    System.load("/home/ilya/work/cdm_clang/verilog_shit/make_shit/build/adder16.so")
//    val loader = SymbolLookup.loaderLookup()

//    val initSym = loader.lookup("init").get()

//    val l = Linker.nativeLinker()
//    SymbolLookup.libraryLookup(Path.of("/home/ilya/work/cdm_clang/verilog_shit/make_shit/build/adder16.so"), Arena.global())
    val c1 = VerilatorModuleWrapper("/home/ilya/work/cdm_clang/verilog_shit/make_shit/build/adder16.so")
    val c2 = VerilatorModuleWrapper("/home/ilya/work/cdm_clang/verilog_shit/make_shit/build/test.so")
//    c1.test()
//    c2.test()
    println(c1)
//    println(c1.eval(intArrayOf(10, 5)).toList())
//    println(c1.eval(intArrayOf(1337, 228)).toList())
//
//    println(c2)
//    println(c2.eval(intArrayOf(-10)).toList())
}



from functools import reduce
from dataclasses import dataclass

from colorama import Fore
from sys import argv
import sys

old_argv = argv
sys.argv = argv[:2]
from synthm.args import args as _
sys.argv = argv


# Найс парсинг аргументов в библиотеке
from synthm.parser import parse
from synthm.synth import epilog, preamble, synth
from synthm.util import log2


@dataclass
class Args:
    defs: str
    res_file: str
    color: bool = True
    debug: bool = False
    fill: str = '0'


def wl(f, n, s):
    f.write(' '*4*n + s + '\n')


def main():
    args = Args(argv[1], argv[2], fill=argv[3])
    fname = args.defs
    if fname.endswith('.def'):
        fname = fname[:-4]

    with open(fname + '.def') as fd:
        rules, seqwidth, phases, triggers = parse(fd.read())

    def hasreps(x):
        if not x:
            return ""
        if x[0] not in x[1:]:
            return hasreps(x[1:])
        else:
            return x[0]

    def err(msg):
        if args.color:
            print(Fore.RED + msg + Fore.RESET)
        else:
            print(msg)

        quit(-1)

    def print_colored(msg, color: Fore):
        if args.color:
            print(color + msg + Fore.RESET)
        else:
            print(msg)

    repeated = hasreps(triggers)
    if repeated:
        err("Trigger '" + repeated + "' occurs more than once on trigger list")

    triggers.sort()
    triggers.append('CUT')

    opcodes = [op for (op, _) in rules]

    repeated = hasreps(opcodes)
    if repeated:
        err("Opcode '" + repeated + "' occurs more than once on activation list")

    trval = {}
    v = 1
    for tr in triggers:
        trval[tr] = v
        v = 2 * v

    print_colored("*** SECONDARY DECODER SYNTH ***", Fore.BLUE)

    print("\tSequencer width: " + str(seqwidth))
    print("\tMaximum phases per instruction: " + str(phases))
    print("\tTrigger list:")
    print('\t\t' + (', \n\t\t'.join(["%s(0x%X)" % (tr, trval[tr]) for tr in triggers])))
    print("\nProcessing action lists...")

    fill_value = 0
    try:
        fill_value = int(args.fill, 16)
    except ValueError:
        err(f"Invalid fill value: {args.fill}, expected hex number")


    rule_bits = log2(len(rules))
    phase_bits = log2(phases)

    preamble = f"""`timescale 1ns / 1ps
module {args.res_file.split("/")[-1].split(".")[0]}(
    input wire [{rule_bits+phase_bits-1}:0] addr,
    output reg [{len(triggers)-1}:0] S
);

wire [{rule_bits-1}:0] rule = addr[{rule_bits-1}:0];
wire [{phase_bits-1}:0] phase = addr[{phase_bits+rule_bits-1}:{rule_bits}];

always_comb begin
    case (rule)
        default: S = {len(triggers)}\'h{fill_value:07x};
"""
    
    res_f = open(args.res_file, 'w')
    res_f.write(preamble)

    for rule_num, rule in enumerate(rules):
        opc, optrigs = rule

        if len(optrigs) > phases:
            err(str(len(optrigs)) + " phases specified for opcode '" + opc + "', greater than maximum declared")

        if len(optrigs) == 0:
            continue
        

        wl(res_f, 2, f'{rule_num}: begin  // {opc}')
        wl(res_f, 3, f'case (phase)')
        

        for phno in range(phases):
            if args.debug and phno == 0:
                print('\t' + opc + ': ' + '; '.join([', '.join(p) for p in optrigs]))

            val = 0
            if phno < len(optrigs):
                phtrigs = optrigs[phno]
                repeated = hasreps(phtrigs)
                if repeated:
                    err(f"Trigger '{repeated}' occurs more than once for opcode '{opc}' in phase {str(phno)}")

                for trig in phtrigs:
                    if trig not in trval:
                        err("Undeclared trigger '" + trig + "' for op-code '" + opc + "'")
                    val |= trval[trig]

            if phno == len(optrigs) - 1:  # last phase for op
                val |= trval['CUT']  # tell sequencer to cut the sequence

            if val == 0:
                continue
            
            wl(res_f, 4, f'{phno}: S = {len(triggers)}\'h{val:07x};  // {", ".join(phtrigs)}')

        wl(res_f, 4, f'default: S = {len(triggers)}\'h{fill_value:07x};')
        wl(res_f, 3, 'endcase')
        wl(res_f, 2, 'end')

    res_f.write("    endcase\nend\nendmodule\n")
    res_f.close()
    


    

if __name__ == "__main__":
    main()

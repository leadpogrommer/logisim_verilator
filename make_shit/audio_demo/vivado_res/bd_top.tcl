
################################################################
# This is a generated script based on design: bd_top
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2023.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source bd_top_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7a15tftg256-1
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name bd_top

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:blk_mem_gen:8.4\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set cdm_ram_addr [ create_bd_port -dir I -from 14 -to 0 -type data cdm_ram_addr ]
  set cdm_ram_clock [ create_bd_port -dir I -type clk -freq_hz 32768000 cdm_ram_clock ]
  set cdm_ram_din [ create_bd_port -dir I -from 15 -to 0 -type data cdm_ram_din ]
  set cdm_ram_dout [ create_bd_port -dir O -from 15 -to 0 cdm_ram_dout ]
  set cdm_ram_en [ create_bd_port -dir I -type data cdm_ram_en ]
  set cdm_ram_wr [ create_bd_port -dir I -from 1 -to 0 -type data cdm_ram_wr ]
  set audio_ram_clock [ create_bd_port -dir I -type clk -freq_hz 12000000 audio_ram_clock ]
  set audio_ram_addr [ create_bd_port -dir I -from 14 -to 0 -type data audio_ram_addr ]
  set audio_ram_din [ create_bd_port -dir I -from 15 -to 0 -type rst audio_ram_din ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $audio_ram_din
  set audio_ram_en [ create_bd_port -dir I -type data audio_ram_en ]
  set audio_ram_wr [ create_bd_port -dir I -from 1 -to 0 -type data audio_ram_wr ]
  set audio_ram_dout [ create_bd_port -dir O -from 15 -to 0 -type data audio_ram_dout ]

  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0 ]
  set_property -dict [list \
    CONFIG.Algorithm {Minimum_Area} \
    CONFIG.Byte_Size {8} \
    CONFIG.Coe_File {/home/ilya/work/5_fpga/cdm_audio/cdm_audio.srcs/sources_1/bd/bd_top/ip/bd_top_blk_mem_gen_0_1/test.coe} \
    CONFIG.Fill_Remaining_Memory_Locations {true} \
    CONFIG.Load_Init_File {true} \
    CONFIG.Memory_Type {True_Dual_Port_RAM} \
    CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
    CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
    CONFIG.Remaining_Memory_Locations {1337} \
    CONFIG.Use_Byte_Write_Enable {true} \
    CONFIG.Write_Depth_A {32768} \
    CONFIG.use_bram_block {Stand_Alone} \
  ] $blk_mem_gen_0


  # Create port connections
  connect_bd_net -net audio_ram_addr_1 [get_bd_ports audio_ram_addr] [get_bd_pins blk_mem_gen_0/addrb]
  connect_bd_net -net audio_ram_clock_1 [get_bd_ports audio_ram_clock] [get_bd_pins blk_mem_gen_0/clkb]
  connect_bd_net -net audio_ram_din_1 [get_bd_ports audio_ram_din] [get_bd_pins blk_mem_gen_0/dinb]
  connect_bd_net -net audio_ram_en_1 [get_bd_ports audio_ram_en] [get_bd_pins blk_mem_gen_0/enb]
  connect_bd_net -net audio_ram_wr_1 [get_bd_ports audio_ram_wr] [get_bd_pins blk_mem_gen_0/web]
  connect_bd_net -net blk_mem_gen_0_douta [get_bd_pins blk_mem_gen_0/douta] [get_bd_ports cdm_ram_dout]
  connect_bd_net -net blk_mem_gen_0_doutb [get_bd_pins blk_mem_gen_0/doutb] [get_bd_ports audio_ram_dout]
  connect_bd_net -net cdm_ram_addr_1 [get_bd_ports cdm_ram_addr] [get_bd_pins blk_mem_gen_0/addra]
  connect_bd_net -net cdm_ram_clock_1 [get_bd_ports cdm_ram_clock] [get_bd_pins blk_mem_gen_0/clka]
  connect_bd_net -net cdm_ram_din_1 [get_bd_ports cdm_ram_din] [get_bd_pins blk_mem_gen_0/dina]
  connect_bd_net -net cdm_ram_en_1 [get_bd_ports cdm_ram_en] [get_bd_pins blk_mem_gen_0/ena]
  connect_bd_net -net cdm_ram_wr_1 [get_bd_ports cdm_ram_wr] [get_bd_pins blk_mem_gen_0/wea]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
create_project -in_memory -part xc7z010clg400-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/vivado/vivado.cache/wt [current_project]
set_property parent.project_path /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/vivado/vivado.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property board_part digilentinc.com:arty-z7-10:part0:1.1 [current_project]
set_property ip_output_repo /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/vivado/vivado.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_vhdl -library xil_defaultlib {
  /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/codigo/rotacion/cordic/arctan_rom.vhdl
  /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/codigo/rotacion/cordic/cordic.vhdl
  /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/codigo/rotacion/cordic/cordic_iter.vhdl
  /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/codigo/dp_ram/dp_ram.vhdl
  /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/codigo/uart/receive.vhdl
  /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/codigo/uart/timing.vhdl
  /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/codigo/uart/uart.vhdl
  /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/codigo/uart/uart_controler.vhdl
  /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/codigo/rotacion/cordic/pre_cordic.vhdl
  /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/codigo/rotacion/rotador_equ.vhdl
  /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/codigo/rotacion/rotador.vhdl
  /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/codigo/rotacion/rotador_controler.vhdl
  /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/codigo/vga/vga_sync.vhdl
  /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/codigo/vga/gen_pixels.vhdl
  /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/codigo/vga/vga_ctrl.vhdl
  /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/codigo/driver.vhdl
  /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/codigo/toplvl.vhdl
}
read_ip -quiet /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/vivado/vivado.srcs/sources_1/ip/vio_0_1/vio_0.xci
set_property used_in_implementation false [get_files -all /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/vivado/vivado.srcs/sources_1/ip/vio_0_1/vio_0.xdc]
set_property used_in_implementation false [get_files -all /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/vivado/vivado.srcs/sources_1/ip/vio_0_1/vio_0_ooc.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/constrains.xdc
set_property used_in_implementation false [get_files /home/santy/Documentos/facultad/Sistemas-digitales/Tp_Final/constrains.xdc]

read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]
set_param ips.enableIPCacheLiteLoad 0
close [open __synthesis_is_running__ w]

synth_design -top toplvl -part xc7z010clg400-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef toplvl.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file toplvl_utilization_synth.rpt -pb toplvl_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]

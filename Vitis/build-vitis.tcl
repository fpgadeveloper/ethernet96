#!/usr/bin/tclsh

# Description
# -----------
# This Tcl script will create Vitis workspace with software applications for each of the
# exported hardware designs in the ../Vivado directory.

# Set the Vivado directories containing the Vivado projects
set vivado_dirs_rel [list "../Vivado"]
set vivado_dirs {}
foreach d $vivado_dirs_rel {
  set d_abs [file join [pwd] $d]
  append vivado_dirs [file normalize $d_abs] " "
}

# Set the application postfix
# Applications will be named using the app_postfix appended to the board name
set app_postfix "_echo"

# Specify the postfix on the Vivado projects so that the workspace builder can find them
set vivado_postfix ""

# Set the app template used to create the application
set support_app "lwip_echo_server"
set template_app "lwIP Echo Server"

# Microblaze designs: Generate combined .bit and .elf file
set mb_combine_bit_elf 0

# ----------------------------------------------------------------------------------------------
# Custom modifications functions
# ----------------------------------------------------------------------------------------------
# Use these functions to make custom changes to the platform or standard application template 
# such as modifying files or copying sources into the platform/application.
# These functions are called after creating the platform/application and before build.

proc custom_platform_mods {platform_name} {
  # Enable and configure the FSBL domain
  # STDIO must be set to psu_uart_1 on Ultra96
  domain active {zynqmp_fsbl}
  bsp config stdin psu_uart_1
  bsp config stdout psu_uart_1
  bsp regenerate
  # Enable and configure the Standalone domain
  # STDIO must be set to psu_uart_1 on Ultra96
  domain active {standalone_domain}
  bsp config stdin psu_uart_1
  bsp config stdout psu_uart_1
  bsp regenerate
  # Enable and configure the PMU FW domain
  # STDIO must be set to psu_uart_1 on Ultra96
  domain active {zynqmp_pmufw}
  bsp config stdin psu_uart_1
  bsp config stdout psu_uart_1
  bsp regenerate

  # Extra compiler flags are needed
  platform config -extra-compiler-flags fsbl "-MMD -MP      -Wall -fmessage-length=0 -DARMA53_64 -Os -flto -ffat-lto-objects  "
  platform config -extra-compiler-flags pmufw "-MMD -MP      -mlittle-endian -mxl-barrel-shift -mxl-pattern-compare -mcpu=v9.2 -mxl-soft-mul -Os -flto -ffat-lto-objects  "
  platform write
}

proc custom_app_mods {platform_name app_name} {
  # No custom mods required
}

# Call the workspace builder script
source tcl/workspace.tcl


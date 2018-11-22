################################################################
# Block diagram build script
################################################################

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

create_bd_design $design_name

current_bd_design $design_name

set parentCell [get_bd_cells /]

# Get object for parentCell
set parentObj [get_bd_cells $parentCell]
if { $parentObj == "" } {
   puts "ERROR: Unable to find parent cell <$parentCell>!"
   return
}

# Make sure parentObj is hier blk
set parentType [get_property TYPE $parentObj]
if { $parentType ne "hier" } {
   puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
   return
}

# Save current instance; Restore later
set oldCurInst [current_bd_instance .]

# Set parent object as current
current_bd_instance $parentObj

# Add the Processor System and apply board preset
create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e zynq_ultra_ps_e_0
apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e -config {apply_board_preset "1" }  [get_bd_cells zynq_ultra_ps_e_0]

# Disable all of the GP ports, enable GEM0, GEM1
set_property -dict [list CONFIG.PSU__USE__M_AXI_GP0 {0} \
CONFIG.PSU__USE__M_AXI_GP1 {0} \
CONFIG.PSU__USE__M_AXI_GP2 {0} \
CONFIG.PSU__ENET0__GRP_MDIO__ENABLE {1} \
CONFIG.PSU__ENET0__GRP_MDIO__IO {EMIO} \
CONFIG.PSU__ENET0__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__ENET0__PERIPHERAL__IO {EMIO} \
CONFIG.PSU__ENET1__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__ENET1__PERIPHERAL__IO {EMIO} \
CONFIG.PSU__ENET1__GRP_MDIO__ENABLE {1} \
CONFIG.PSU__ENET1__GRP_MDIO__IO {EMIO} \
CONFIG.PSU__ENET2__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__ENET2__PERIPHERAL__IO {EMIO} \
CONFIG.PSU__ENET2__GRP_MDIO__ENABLE {1} \
CONFIG.PSU__ENET2__GRP_MDIO__IO {EMIO}] [get_bd_cells zynq_ultra_ps_e_0]

# Add the SGMII cores
create_bd_cell -type ip -vlnv xilinx.com:ip:gig_ethernet_pcs_pma gig_ethernet_pcs_pma_0
create_bd_cell -type ip -vlnv xilinx.com:ip:gig_ethernet_pcs_pma gig_ethernet_pcs_pma_1

set_property -dict [list CONFIG.Standard {SGMII} \
CONFIG.Ext_Management_Interface {true} \
CONFIG.EMAC_IF_TEMAC {GEM} \
CONFIG.SupportLevel {Include_Shared_Logic_in_Core} \
CONFIG.NumOfLanes {2} \
CONFIG.TxLane0_Placement {DIFF_PAIR_0} \
CONFIG.TxLane1_Placement {DIFF_PAIR_1} \
CONFIG.RxLane0_Placement {DIFF_PAIR_0} \
CONFIG.RxLane1_Placement {DIFF_PAIR_1} \
CONFIG.Tx_In_Upper_Nibble {1} \
CONFIG.ClockSelection {Async}] [get_bd_cells gig_ethernet_pcs_pma_0]

set_property -dict [list CONFIG.Standard {SGMII} \
CONFIG.Ext_Management_Interface {true} \
CONFIG.EMAC_IF_TEMAC {GEM} \
CONFIG.SupportLevel {Include_Shared_Logic_in_Example_Design} \
CONFIG.NumOfLanes {1} \
CONFIG.TxLane0_Placement {DIFF_PAIR_0} \
CONFIG.TxLane1_Placement {DIFF_PAIR_1} \
CONFIG.RxLane0_Placement {DIFF_PAIR_0} \
CONFIG.RxLane1_Placement {DIFF_PAIR_1} \
CONFIG.Tx_In_Upper_Nibble {0} \
CONFIG.ClockSelection {Async}] [get_bd_cells gig_ethernet_pcs_pma_1]

connect_bd_net [get_bd_pins gig_ethernet_pcs_pma_0/tx_bsc_rst_out] [get_bd_pins gig_ethernet_pcs_pma_1/tx_bsc_rst]
connect_bd_net [get_bd_pins gig_ethernet_pcs_pma_0/rx_bsc_rst_out] [get_bd_pins gig_ethernet_pcs_pma_1/rx_bsc_rst]
connect_bd_net [get_bd_pins gig_ethernet_pcs_pma_0/tx_bs_rst_out] [get_bd_pins gig_ethernet_pcs_pma_1/tx_bs_rst]
connect_bd_net [get_bd_pins gig_ethernet_pcs_pma_0/rx_bs_rst_out] [get_bd_pins gig_ethernet_pcs_pma_1/rx_bs_rst]
connect_bd_net [get_bd_pins gig_ethernet_pcs_pma_0/tx_rst_dly_out] [get_bd_pins gig_ethernet_pcs_pma_1/tx_rst_dly]
connect_bd_net [get_bd_pins gig_ethernet_pcs_pma_0/rx_rst_dly_out] [get_bd_pins gig_ethernet_pcs_pma_1/rx_rst_dly]
connect_bd_net [get_bd_pins gig_ethernet_pcs_pma_0/riu_clk_out] [get_bd_pins gig_ethernet_pcs_pma_1/riu_clk]
connect_bd_net [get_bd_pins gig_ethernet_pcs_pma_0/riu_wr_en_out] [get_bd_pins gig_ethernet_pcs_pma_1/riu_wr_en]
connect_bd_net [get_bd_pins gig_ethernet_pcs_pma_0/tx_pll_clk_out] [get_bd_pins gig_ethernet_pcs_pma_1/tx_pll_clk]
connect_bd_net [get_bd_pins gig_ethernet_pcs_pma_0/rx_pll_clk_out] [get_bd_pins gig_ethernet_pcs_pma_1/rx_pll_clk]
connect_bd_net [get_bd_pins gig_ethernet_pcs_pma_0/tx_rdclk_out] [get_bd_pins gig_ethernet_pcs_pma_1/tx_rdclk]
connect_bd_net [get_bd_pins gig_ethernet_pcs_pma_0/riu_addr_out] [get_bd_pins gig_ethernet_pcs_pma_1/riu_addr]
connect_bd_net [get_bd_pins gig_ethernet_pcs_pma_0/riu_wr_data_out] [get_bd_pins gig_ethernet_pcs_pma_1/riu_wr_data]
connect_bd_net [get_bd_pins gig_ethernet_pcs_pma_0/riu_nibble_sel_out] [get_bd_pins gig_ethernet_pcs_pma_1/riu_nibble_sel]
connect_bd_net [get_bd_pins gig_ethernet_pcs_pma_0/rx_btval_1] [get_bd_pins gig_ethernet_pcs_pma_1/rx_btval]
connect_bd_net [get_bd_pins gig_ethernet_pcs_pma_0/tx_bsc_en_vtc_out] [get_bd_pins gig_ethernet_pcs_pma_1/tx_bsc_en_vtc]
connect_bd_net [get_bd_pins gig_ethernet_pcs_pma_0/rx_bsc_en_vtc_out] [get_bd_pins gig_ethernet_pcs_pma_1/rx_bsc_en_vtc]
connect_bd_net [get_bd_pins gig_ethernet_pcs_pma_0/tx_bs_en_vtc_out] [get_bd_pins gig_ethernet_pcs_pma_1/tx_bs_en_vtc]
connect_bd_net [get_bd_pins gig_ethernet_pcs_pma_0/rx_bs_en_vtc_out] [get_bd_pins gig_ethernet_pcs_pma_1/rx_bs_en_vtc]
connect_bd_net [get_bd_pins gig_ethernet_pcs_pma_0/clk125_out] [get_bd_pins gig_ethernet_pcs_pma_1/clk125m]
connect_bd_net [get_bd_pins gig_ethernet_pcs_pma_0/clk312_out] [get_bd_pins gig_ethernet_pcs_pma_1/clk312]

# Add proc system reset
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_0
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins proc_sys_reset_0/slowest_sync_clk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins proc_sys_reset_0/ext_reset_in]
connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_reset] [get_bd_pins gig_ethernet_pcs_pma_0/reset]

create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_1
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins proc_sys_reset_1/slowest_sync_clk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins proc_sys_reset_1/ext_reset_in]
connect_bd_net [get_bd_pins proc_sys_reset_1/peripheral_reset] [get_bd_pins gig_ethernet_pcs_pma_1/reset]

# Constants for the PHY addresses
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant const_phyaddr_0
set_property -dict [list CONFIG.CONST_WIDTH {5} CONFIG.CONST_VAL {01}] [get_bd_cells const_phyaddr_0]
connect_bd_net [get_bd_pins const_phyaddr_0/dout] [get_bd_pins gig_ethernet_pcs_pma_0/phyaddr_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant const_phyaddr_1
set_property -dict [list CONFIG.CONST_WIDTH {5} CONFIG.CONST_VAL {02}] [get_bd_cells const_phyaddr_1]
connect_bd_net [get_bd_pins const_phyaddr_1/dout] [get_bd_pins gig_ethernet_pcs_pma_0/phyaddr_1]

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant const_phyaddr_2
set_property -dict [list CONFIG.CONST_WIDTH {5} CONFIG.CONST_VAL {03}] [get_bd_cells const_phyaddr_2]
connect_bd_net [get_bd_pins const_phyaddr_2/dout] [get_bd_pins gig_ethernet_pcs_pma_1/phyaddr_0]

# Create SGMII ports
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:sgmii_rtl:1.0 sgmii_port_0
connect_bd_intf_net [get_bd_intf_pins gig_ethernet_pcs_pma_0/sgmii_0] [get_bd_intf_ports sgmii_port_0]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:sgmii_rtl:1.0 sgmii_port_1
connect_bd_intf_net [get_bd_intf_pins gig_ethernet_pcs_pma_0/sgmii_1] [get_bd_intf_ports sgmii_port_1]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:sgmii_rtl:1.0 sgmii_port_2
connect_bd_intf_net [get_bd_intf_pins gig_ethernet_pcs_pma_1/sgmii_0] [get_bd_intf_ports sgmii_port_2]

# Create MDIO ports
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_port_0
connect_bd_intf_net [get_bd_intf_pins gig_ethernet_pcs_pma_0/ext_mdio_pcs_pma_0] [get_bd_intf_ports mdio_port_0]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_port_1
connect_bd_intf_net [get_bd_intf_pins gig_ethernet_pcs_pma_0/ext_mdio_pcs_pma_1] [get_bd_intf_ports mdio_port_1]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_port_2
connect_bd_intf_net [get_bd_intf_pins gig_ethernet_pcs_pma_1/ext_mdio_pcs_pma_0] [get_bd_intf_ports mdio_port_2]

# Create the ref clk port
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 ref_clk_port_0
set_property CONFIG.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_intf_pins gig_ethernet_pcs_pma_0/refclk625_in]] [get_bd_intf_ports ref_clk_port_0]
connect_bd_intf_net [get_bd_intf_pins gig_ethernet_pcs_pma_0/refclk625_in] [get_bd_intf_ports ref_clk_port_0]

# Connect the GMII and MDIO interfaces from the PS
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/GMII_ENET0] [get_bd_intf_pins gig_ethernet_pcs_pma_0/gmii_pcs_pma_0]
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/MDIO_ENET0] [get_bd_intf_pins gig_ethernet_pcs_pma_0/mdio_pcs_pma_0]
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/GMII_ENET1] [get_bd_intf_pins gig_ethernet_pcs_pma_0/gmii_pcs_pma_1]
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/MDIO_ENET1] [get_bd_intf_pins gig_ethernet_pcs_pma_0/mdio_pcs_pma_1]
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/GMII_ENET2] [get_bd_intf_pins gig_ethernet_pcs_pma_1/gmii_pcs_pma_0]
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/MDIO_ENET2] [get_bd_intf_pins gig_ethernet_pcs_pma_1/mdio_pcs_pma_0]

# Restore current instance
current_bd_instance $oldCurInst

save_bd_design

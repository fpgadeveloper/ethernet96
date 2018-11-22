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
CONFIG.PSU__ENET2__GRP_MDIO__IO {EMIO} \
CONFIG.PSU__ENET3__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__ENET3__PERIPHERAL__IO {EMIO} \
CONFIG.PSU__ENET3__GRP_MDIO__ENABLE {1} \
CONFIG.PSU__ENET3__GRP_MDIO__IO {EMIO}] [get_bd_cells zynq_ultra_ps_e_0]

# Add the SGMII cores
create_bd_cell -type ip -vlnv xilinx.com:ip:gig_ethernet_pcs_pma gig_ethernet_pcs_pma_0
create_bd_cell -type ip -vlnv xilinx.com:ip:gig_ethernet_pcs_pma gig_ethernet_pcs_pma_1

set_property -dict [list CONFIG.Standard {SGMII} \
CONFIG.Ext_Management_Interface {true} \
CONFIG.EMAC_IF_TEMAC {GEM} \
CONFIG.SupportLevel {Include_Shared_Logic_in_Core} \
CONFIG.NumOfLanes {3} \
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
CONFIG.NumOfLanes {2} \
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

# Create the ref clk 125MHz port
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 ref_clk_125mhz
set_property CONFIG.FREQ_HZ 125000000 [get_bd_intf_ports /ref_clk_125mhz]

# IBUFDS for 125MHz
create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf util_ds_buf_0
set_property -dict [list CONFIG.C_BUF_TYPE {IBUFDS}] [get_bd_cells util_ds_buf_0]
connect_bd_intf_net [get_bd_intf_ports ref_clk_125mhz] [get_bd_intf_pins util_ds_buf_0/CLK_IN_D]

# BUFGCE for 125MHz
create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf util_ds_buf_1
set_property -dict [list CONFIG.C_BUF_TYPE {BUFG}] [get_bd_cells util_ds_buf_1]
connect_bd_net [get_bd_pins util_ds_buf_0/IBUF_OUT] [get_bd_pins util_ds_buf_1/BUFG_I]

# Create clock wizard
create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz clk_wiz_0
set_property -dict [list CONFIG.PRIM_IN_FREQ.VALUE_SRC USER] [get_bd_cells clk_wiz_0]
set_property -dict [list CONFIG.PRIM_SOURCE {No_buffer} \
CONFIG.PRIM_IN_FREQ {125} \
CONFIG.CLKOUT2_USED {true} \
CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125} \
CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {625} \
CONFIG.CLKOUT1_DRIVES {Buffer} \
CONFIG.USE_LOCKED {true} \
CONFIG.USE_RESET {false} \
CONFIG.CLKIN1_JITTER_PS {80.0} \
CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
CONFIG.MMCM_DIVCLK_DIVIDE {1} \
CONFIG.MMCM_CLKFBOUT_MULT_F {10.000} \
CONFIG.MMCM_CLKIN1_PERIOD {8.000} \
CONFIG.MMCM_CLKOUT0_DIVIDE_F {10.000} \
CONFIG.MMCM_CLKOUT1_DIVIDE {2} \
CONFIG.NUM_OUT_CLKS {2} \
CONFIG.CLKOUT1_JITTER {105.587} \
CONFIG.CLKOUT1_PHASE_ERROR {83.589} \
CONFIG.CLKOUT2_JITTER {78.432} \
CONFIG.CLKOUT2_PHASE_ERROR {83.589}] [get_bd_cells clk_wiz_0]
connect_bd_net [get_bd_pins util_ds_buf_1/BUFG_O] [get_bd_pins clk_wiz_0/clk_in1]

# Add proc system reset
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_0
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins proc_sys_reset_0/slowest_sync_clk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins proc_sys_reset_0/ext_reset_in]
connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_reset] [get_bd_pins gig_ethernet_pcs_pma_0/reset]
connect_bd_net [get_bd_pins clk_wiz_0/locked] [get_bd_pins proc_sys_reset_0/dcm_locked]

create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_1
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins proc_sys_reset_1/slowest_sync_clk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins proc_sys_reset_1/ext_reset_in]
connect_bd_net [get_bd_pins proc_sys_reset_1/peripheral_reset] [get_bd_pins gig_ethernet_pcs_pma_1/reset]
connect_bd_net [get_bd_pins clk_wiz_0/locked] [get_bd_pins proc_sys_reset_1/dcm_locked]

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

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant const_phyaddr_3
set_property -dict [list CONFIG.CONST_WIDTH {5} CONFIG.CONST_VAL {04}] [get_bd_cells const_phyaddr_3]
connect_bd_net [get_bd_pins const_phyaddr_3/dout] [get_bd_pins gig_ethernet_pcs_pma_0/phyaddr_2]
connect_bd_net [get_bd_pins const_phyaddr_3/dout] [get_bd_pins gig_ethernet_pcs_pma_1/phyaddr_1]

# Create SGMII ports
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:sgmii_rtl:1.0 sgmii_port_0
connect_bd_intf_net [get_bd_intf_pins gig_ethernet_pcs_pma_0/sgmii_0] [get_bd_intf_ports sgmii_port_0]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:sgmii_rtl:1.0 sgmii_port_1
connect_bd_intf_net [get_bd_intf_pins gig_ethernet_pcs_pma_0/sgmii_1] [get_bd_intf_ports sgmii_port_1]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:sgmii_rtl:1.0 sgmii_port_2
connect_bd_intf_net [get_bd_intf_pins gig_ethernet_pcs_pma_1/sgmii_0] [get_bd_intf_ports sgmii_port_2]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:sgmii_rtl:1.0 sgmii_port_3_tx
connect_bd_intf_net [get_bd_intf_pins gig_ethernet_pcs_pma_1/sgmii_1] [get_bd_intf_ports sgmii_port_3_tx]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:sgmii_rtl:1.0 sgmii_port_3_rx
connect_bd_intf_net [get_bd_intf_pins gig_ethernet_pcs_pma_0/sgmii_2] [get_bd_intf_ports sgmii_port_3_rx]

# Create MDIO ports
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_port_0
connect_bd_intf_net [get_bd_intf_pins gig_ethernet_pcs_pma_0/ext_mdio_pcs_pma_0] [get_bd_intf_ports mdio_port_0]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_port_1
connect_bd_intf_net [get_bd_intf_pins gig_ethernet_pcs_pma_0/ext_mdio_pcs_pma_1] [get_bd_intf_ports mdio_port_1]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_port_2
connect_bd_intf_net [get_bd_intf_pins gig_ethernet_pcs_pma_1/ext_mdio_pcs_pma_0] [get_bd_intf_ports mdio_port_2]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_port_3
connect_bd_intf_net [get_bd_intf_pins gig_ethernet_pcs_pma_1/ext_mdio_pcs_pma_1] [get_bd_intf_ports mdio_port_3]

# Create the ref clk 625MHz port
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 ref_clk_625mhz
set_property CONFIG.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_intf_pins gig_ethernet_pcs_pma_0/refclk625_in]] [get_bd_intf_ports ref_clk_625mhz]
connect_bd_intf_net [get_bd_intf_pins gig_ethernet_pcs_pma_0/refclk625_in] [get_bd_intf_ports ref_clk_625mhz]

# Connect the GMII and MDIO interfaces from the PS
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/GMII_ENET0] [get_bd_intf_pins gig_ethernet_pcs_pma_0/gmii_pcs_pma_0]
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/MDIO_ENET0] [get_bd_intf_pins gig_ethernet_pcs_pma_0/mdio_pcs_pma_0]
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/GMII_ENET1] [get_bd_intf_pins gig_ethernet_pcs_pma_0/gmii_pcs_pma_1]
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/MDIO_ENET1] [get_bd_intf_pins gig_ethernet_pcs_pma_0/mdio_pcs_pma_1]
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/GMII_ENET2] [get_bd_intf_pins gig_ethernet_pcs_pma_1/gmii_pcs_pma_0]
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/MDIO_ENET2] [get_bd_intf_pins gig_ethernet_pcs_pma_1/mdio_pcs_pma_0]
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/GMII_ENET3] [get_bd_intf_pins gig_ethernet_pcs_pma_1/gmii_pcs_pma_1]
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/MDIO_ENET3] [get_bd_intf_pins gig_ethernet_pcs_pma_1/mdio_pcs_pma_1]

# Restore current instance
current_bd_instance $oldCurInst

save_bd_design

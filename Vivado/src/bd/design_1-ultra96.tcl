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
CONFIG.PSU__ENET1__GRP_MDIO__ENABLE {0} \
CONFIG.PSU__ENET1__GRP_MDIO__IO {EMIO} \
CONFIG.PSU__ENET2__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__ENET2__PERIPHERAL__IO {EMIO} \
CONFIG.PSU__ENET2__GRP_MDIO__ENABLE {0} \
CONFIG.PSU__ENET2__GRP_MDIO__IO {EMIO} \
CONFIG.PSU__ENET3__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__ENET3__PERIPHERAL__IO {EMIO} \
CONFIG.PSU__ENET3__GRP_MDIO__ENABLE {0} \
CONFIG.PSU__ENET3__GRP_MDIO__IO {EMIO} \
CONFIG.PSU__GPIO_EMIO__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__GPIO_EMIO__PERIPHERAL__IO {8}] [get_bd_cells zynq_ultra_ps_e_0]

# Add the SGMII cores
create_bd_cell -type ip -vlnv xilinx.com:ip:gig_ethernet_pcs_pma eth_pcs_pma_0_1
create_bd_cell -type ip -vlnv xilinx.com:ip:gig_ethernet_pcs_pma eth_pcs_pma_2
create_bd_cell -type ip -vlnv xilinx.com:ip:gig_ethernet_pcs_pma eth_pcs_pma_3_rx
create_bd_cell -type ip -vlnv xilinx.com:ip:gig_ethernet_pcs_pma eth_pcs_pma_3_tx

# Ports 0 and 1 configuration: Asynchronous
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
CONFIG.ClockSelection {Async} \
CONFIG.Ext_Management_Interface {true} \
CONFIG.Auto_Negotiation {true}] [get_bd_cells eth_pcs_pma_0_1]

# Port 2 configuration: Asynchronous
set_property -dict [list CONFIG.Standard {SGMII} \
CONFIG.Ext_Management_Interface {true} \
CONFIG.EMAC_IF_TEMAC {GEM} \
CONFIG.SupportLevel {Include_Shared_Logic_in_Example_Design} \
CONFIG.NumOfLanes {1} \
CONFIG.TxLane0_Placement {DIFF_PAIR_0} \
CONFIG.TxLane1_Placement {DIFF_PAIR_1} \
CONFIG.RxLane0_Placement {DIFF_PAIR_0} \
CONFIG.RxLane1_Placement {DIFF_PAIR_1} \
CONFIG.Tx_In_Upper_Nibble {1} \
CONFIG.ClockSelection {Async} \
CONFIG.Ext_Management_Interface {true} \
CONFIG.Auto_Negotiation {true}] [get_bd_cells eth_pcs_pma_2]

# Port 3 RX configuration: Asynchronous, Auto-neg disabled
set_property -dict [list CONFIG.Standard {SGMII} \
CONFIG.Ext_Management_Interface {true} \
CONFIG.EMAC_IF_TEMAC {GEM} \
CONFIG.SupportLevel {Include_Shared_Logic_in_Example_Design} \
CONFIG.NumOfLanes {1} \
CONFIG.TxLane0_Placement {DIFF_PAIR_0} \
CONFIG.TxLane1_Placement {DIFF_PAIR_1} \
CONFIG.RxLane0_Placement {DIFF_PAIR_0} \
CONFIG.RxLane1_Placement {DIFF_PAIR_1} \
CONFIG.Tx_In_Upper_Nibble {1} \
CONFIG.ClockSelection {Async} \
CONFIG.Ext_Management_Interface {true} \
CONFIG.Auto_Negotiation {false}] [get_bd_cells eth_pcs_pma_3_rx]

# Port 3 TX configuration: Asynchronous, Auto-neg disabled
set_property -dict [list CONFIG.Standard {SGMII} \
CONFIG.Ext_Management_Interface {true} \
CONFIG.EMAC_IF_TEMAC {GEM} \
CONFIG.SupportLevel {Include_Shared_Logic_in_Example_Design} \
CONFIG.NumOfLanes {1} \
CONFIG.TxLane0_Placement {DIFF_PAIR_0} \
CONFIG.TxLane1_Placement {DIFF_PAIR_1} \
CONFIG.RxLane0_Placement {DIFF_PAIR_0} \
CONFIG.RxLane1_Placement {DIFF_PAIR_1} \
CONFIG.Tx_In_Upper_Nibble {1} \
CONFIG.ClockSelection {Async} \
CONFIG.Ext_Management_Interface {true} \
CONFIG.Auto_Negotiation {false}] [get_bd_cells eth_pcs_pma_3_tx]

# eth_pcs_pma_0_1 to eth_pcs_pma_2
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/tx_bsc_rst_out] [get_bd_pins eth_pcs_pma_2/tx_bsc_rst]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/rx_bsc_rst_out] [get_bd_pins eth_pcs_pma_2/rx_bsc_rst]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/tx_bs_rst_out] [get_bd_pins eth_pcs_pma_2/tx_bs_rst]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/rx_bs_rst_out] [get_bd_pins eth_pcs_pma_2/rx_bs_rst]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/tx_rst_dly_out] [get_bd_pins eth_pcs_pma_2/tx_rst_dly]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/rx_rst_dly_out] [get_bd_pins eth_pcs_pma_2/rx_rst_dly]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/riu_clk_out] [get_bd_pins eth_pcs_pma_2/riu_clk]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/riu_wr_en_out] [get_bd_pins eth_pcs_pma_2/riu_wr_en]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/tx_pll_clk_out] [get_bd_pins eth_pcs_pma_2/tx_pll_clk]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/rx_pll_clk_out] [get_bd_pins eth_pcs_pma_2/rx_pll_clk]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/tx_rdclk_out] [get_bd_pins eth_pcs_pma_2/tx_rdclk]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/riu_addr_out] [get_bd_pins eth_pcs_pma_2/riu_addr]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/riu_wr_data_out] [get_bd_pins eth_pcs_pma_2/riu_wr_data]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/riu_nibble_sel_out] [get_bd_pins eth_pcs_pma_2/riu_nibble_sel]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/rx_btval_1] [get_bd_pins eth_pcs_pma_2/rx_btval]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/tx_bsc_en_vtc_out] [get_bd_pins eth_pcs_pma_2/tx_bsc_en_vtc]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/rx_bsc_en_vtc_out] [get_bd_pins eth_pcs_pma_2/rx_bsc_en_vtc]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/tx_bs_en_vtc_out] [get_bd_pins eth_pcs_pma_2/tx_bs_en_vtc]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/rx_bs_en_vtc_out] [get_bd_pins eth_pcs_pma_2/rx_bs_en_vtc]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/clk125_out] [get_bd_pins eth_pcs_pma_2/clk125m]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/clk312_out] [get_bd_pins eth_pcs_pma_2/clk312]

# eth_pcs_pma_0_1 to eth_pcs_pma_3_rx
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/tx_bsc_rst_out] [get_bd_pins eth_pcs_pma_3_rx/tx_bsc_rst]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/rx_bsc_rst_out] [get_bd_pins eth_pcs_pma_3_rx/rx_bsc_rst]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/tx_bs_rst_out] [get_bd_pins eth_pcs_pma_3_rx/tx_bs_rst]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/rx_bs_rst_out] [get_bd_pins eth_pcs_pma_3_rx/rx_bs_rst]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/tx_rst_dly_out] [get_bd_pins eth_pcs_pma_3_rx/tx_rst_dly]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/rx_rst_dly_out] [get_bd_pins eth_pcs_pma_3_rx/rx_rst_dly]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/riu_clk_out] [get_bd_pins eth_pcs_pma_3_rx/riu_clk]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/riu_wr_en_out] [get_bd_pins eth_pcs_pma_3_rx/riu_wr_en]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/tx_pll_clk_out] [get_bd_pins eth_pcs_pma_3_rx/tx_pll_clk]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/rx_pll_clk_out] [get_bd_pins eth_pcs_pma_3_rx/rx_pll_clk]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/tx_rdclk_out] [get_bd_pins eth_pcs_pma_3_rx/tx_rdclk]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/riu_addr_out] [get_bd_pins eth_pcs_pma_3_rx/riu_addr]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/riu_wr_data_out] [get_bd_pins eth_pcs_pma_3_rx/riu_wr_data]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/riu_nibble_sel_out] [get_bd_pins eth_pcs_pma_3_rx/riu_nibble_sel]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/rx_btval_1] [get_bd_pins eth_pcs_pma_3_rx/rx_btval]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/tx_bsc_en_vtc_out] [get_bd_pins eth_pcs_pma_3_rx/tx_bsc_en_vtc]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/rx_bsc_en_vtc_out] [get_bd_pins eth_pcs_pma_3_rx/rx_bsc_en_vtc]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/tx_bs_en_vtc_out] [get_bd_pins eth_pcs_pma_3_rx/tx_bs_en_vtc]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/rx_bs_en_vtc_out] [get_bd_pins eth_pcs_pma_3_rx/rx_bs_en_vtc]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/clk125_out] [get_bd_pins eth_pcs_pma_3_rx/clk125m]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/clk312_out] [get_bd_pins eth_pcs_pma_3_rx/clk312]

# eth_pcs_pma_0_1 to eth_pcs_pma_3_tx
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/tx_bsc_rst_out] [get_bd_pins eth_pcs_pma_3_tx/tx_bsc_rst]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/rx_bsc_rst_out] [get_bd_pins eth_pcs_pma_3_tx/rx_bsc_rst]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/tx_bs_rst_out] [get_bd_pins eth_pcs_pma_3_tx/tx_bs_rst]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/rx_bs_rst_out] [get_bd_pins eth_pcs_pma_3_tx/rx_bs_rst]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/tx_rst_dly_out] [get_bd_pins eth_pcs_pma_3_tx/tx_rst_dly]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/rx_rst_dly_out] [get_bd_pins eth_pcs_pma_3_tx/rx_rst_dly]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/riu_clk_out] [get_bd_pins eth_pcs_pma_3_tx/riu_clk]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/riu_wr_en_out] [get_bd_pins eth_pcs_pma_3_tx/riu_wr_en]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/tx_pll_clk_out] [get_bd_pins eth_pcs_pma_3_tx/tx_pll_clk]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/rx_pll_clk_out] [get_bd_pins eth_pcs_pma_3_tx/rx_pll_clk]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/tx_rdclk_out] [get_bd_pins eth_pcs_pma_3_tx/tx_rdclk]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/riu_addr_out] [get_bd_pins eth_pcs_pma_3_tx/riu_addr]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/riu_wr_data_out] [get_bd_pins eth_pcs_pma_3_tx/riu_wr_data]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/riu_nibble_sel_out] [get_bd_pins eth_pcs_pma_3_tx/riu_nibble_sel]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/rx_btval_1] [get_bd_pins eth_pcs_pma_3_tx/rx_btval]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/tx_bsc_en_vtc_out] [get_bd_pins eth_pcs_pma_3_tx/tx_bsc_en_vtc]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/rx_bsc_en_vtc_out] [get_bd_pins eth_pcs_pma_3_tx/rx_bsc_en_vtc]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/tx_bs_en_vtc_out] [get_bd_pins eth_pcs_pma_3_tx/tx_bs_en_vtc]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/rx_bs_en_vtc_out] [get_bd_pins eth_pcs_pma_3_tx/rx_bs_en_vtc]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/clk125_out] [get_bd_pins eth_pcs_pma_3_tx/clk125m]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/clk312_out] [get_bd_pins eth_pcs_pma_3_tx/clk312]

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
connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_reset] [get_bd_pins eth_pcs_pma_0_1/reset]
connect_bd_net [get_bd_pins clk_wiz_0/locked] [get_bd_pins proc_sys_reset_0/dcm_locked]

create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_1
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins proc_sys_reset_1/slowest_sync_clk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins proc_sys_reset_1/ext_reset_in]
connect_bd_net [get_bd_pins proc_sys_reset_1/peripheral_reset] [get_bd_pins eth_pcs_pma_2/reset]
connect_bd_net [get_bd_pins proc_sys_reset_1/peripheral_reset] [get_bd_pins eth_pcs_pma_3_rx/reset]
connect_bd_net [get_bd_pins proc_sys_reset_1/peripheral_reset] [get_bd_pins eth_pcs_pma_3_tx/reset]
connect_bd_net [get_bd_pins clk_wiz_0/locked] [get_bd_pins proc_sys_reset_1/dcm_locked]

# Constants for the PHY addresses
# ------------------------------------------------
# External PHYs have addresses: 1,3,12 and 15
# PCS/PMA PHYs have addresses: 2,4,13,16 and 17
# Note that port 3 has two PCS/PMA PHYs
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant const_phyaddr_0
set_property -dict [list CONFIG.CONST_WIDTH {5} CONFIG.CONST_VAL {0x02}] [get_bd_cells const_phyaddr_0]
connect_bd_net [get_bd_pins const_phyaddr_0/dout] [get_bd_pins eth_pcs_pma_0_1/phyaddr_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant const_phyaddr_1
set_property -dict [list CONFIG.CONST_WIDTH {5} CONFIG.CONST_VAL {0x04}] [get_bd_cells const_phyaddr_1]
connect_bd_net [get_bd_pins const_phyaddr_1/dout] [get_bd_pins eth_pcs_pma_0_1/phyaddr_1]

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant const_phyaddr_2
set_property -dict [list CONFIG.CONST_WIDTH {5} CONFIG.CONST_VAL {0x0D}] [get_bd_cells const_phyaddr_2]
connect_bd_net [get_bd_pins const_phyaddr_2/dout] [get_bd_pins eth_pcs_pma_2/phyaddr_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant const_phyaddr_3_rx
set_property -dict [list CONFIG.CONST_WIDTH {5} CONFIG.CONST_VAL {0x10}] [get_bd_cells const_phyaddr_3_rx]
connect_bd_net [get_bd_pins const_phyaddr_3_rx/dout] [get_bd_pins eth_pcs_pma_3_rx/phyaddr_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant const_phyaddr_3_tx
set_property -dict [list CONFIG.CONST_WIDTH {5} CONFIG.CONST_VAL {0x11}] [get_bd_cells const_phyaddr_3_tx]
connect_bd_net [get_bd_pins const_phyaddr_3_tx/dout] [get_bd_pins eth_pcs_pma_3_tx/phyaddr_0]

# Create SGMII ports
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:sgmii_rtl:1.0 sgmii_port_0
connect_bd_intf_net [get_bd_intf_pins eth_pcs_pma_0_1/sgmii_0] [get_bd_intf_ports sgmii_port_0]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:sgmii_rtl:1.0 sgmii_port_1
connect_bd_intf_net [get_bd_intf_pins eth_pcs_pma_0_1/sgmii_1] [get_bd_intf_ports sgmii_port_1]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:sgmii_rtl:1.0 sgmii_port_2
connect_bd_intf_net [get_bd_intf_pins eth_pcs_pma_2/sgmii_0] [get_bd_intf_ports sgmii_port_2]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:sgmii_rtl:1.0 sgmii_port_3_tx
connect_bd_intf_net [get_bd_intf_pins eth_pcs_pma_3_tx/sgmii_0] [get_bd_intf_ports sgmii_port_3_tx]
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:sgmii_rtl:1.0 sgmii_port_3_rx
connect_bd_intf_net [get_bd_intf_pins eth_pcs_pma_3_rx/sgmii_0] [get_bd_intf_ports sgmii_port_3_rx]

# Create MDIO port
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio
connect_bd_intf_net [get_bd_intf_pins eth_pcs_pma_0_1/ext_mdio_pcs_pma_0] [get_bd_intf_pins eth_pcs_pma_0_1/mdio_pcs_pma_1]
connect_bd_intf_net [get_bd_intf_pins eth_pcs_pma_0_1/ext_mdio_pcs_pma_1] [get_bd_intf_pins eth_pcs_pma_2/mdio_pcs_pma_0]
connect_bd_intf_net [get_bd_intf_pins eth_pcs_pma_2/ext_mdio_pcs_pma_0] [get_bd_intf_pins eth_pcs_pma_3_tx/mdio_pcs_pma_0]
connect_bd_intf_net [get_bd_intf_pins eth_pcs_pma_3_tx/ext_mdio_pcs_pma_0] [get_bd_intf_pins eth_pcs_pma_3_rx/mdio_pcs_pma_0]
connect_bd_intf_net [get_bd_intf_pins eth_pcs_pma_3_rx/ext_mdio_pcs_pma_0] [get_bd_intf_ports mdio]

# Create the ref clk 625MHz port
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 ref_clk_625mhz
set_property CONFIG.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_intf_pins eth_pcs_pma_0_1/refclk625_in]] [get_bd_intf_ports ref_clk_625mhz]
connect_bd_intf_net [get_bd_intf_pins eth_pcs_pma_0_1/refclk625_in] [get_bd_intf_ports ref_clk_625mhz]

# Connect the GMII and MDIO interfaces from the PS
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/GMII_ENET0] [get_bd_intf_pins eth_pcs_pma_0_1/gmii_pcs_pma_0]
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/MDIO_ENET0] [get_bd_intf_pins eth_pcs_pma_0_1/mdio_pcs_pma_0]
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/GMII_ENET1] [get_bd_intf_pins eth_pcs_pma_0_1/gmii_pcs_pma_1]
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/GMII_ENET2] [get_bd_intf_pins eth_pcs_pma_2/gmii_pcs_pma_0]

# Connect the GMII RX clocks
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/gmii_rxclk_0] [get_bd_pins zynq_ultra_ps_e_0/emio_enet0_gmii_rx_clk]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/gmii_rxclk_1] [get_bd_pins zynq_ultra_ps_e_0/emio_enet1_gmii_rx_clk]
connect_bd_net [get_bd_pins eth_pcs_pma_2/gmii_rxclk_0] [get_bd_pins zynq_ultra_ps_e_0/emio_enet2_gmii_rx_clk]

# Connect the GMII TX clocks
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/gmii_txclk_0] [get_bd_pins zynq_ultra_ps_e_0/emio_enet0_gmii_tx_clk]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/gmii_txclk_1] [get_bd_pins zynq_ultra_ps_e_0/emio_enet1_gmii_tx_clk]
connect_bd_net [get_bd_pins eth_pcs_pma_2/gmii_txclk_0] [get_bd_pins zynq_ultra_ps_e_0/emio_enet2_gmii_tx_clk]

# Connect GMII RX interface of port 3
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/gmii_rxclk_0] [get_bd_pins zynq_ultra_ps_e_0/emio_enet3_gmii_rx_clk]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/gmii_rx_dv_0] [get_bd_pins zynq_ultra_ps_e_0/emio_enet3_gmii_rx_dv]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/gmii_rx_er_0] [get_bd_pins zynq_ultra_ps_e_0/emio_enet3_gmii_rx_er]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/gmii_rxd_0] [get_bd_pins zynq_ultra_ps_e_0/emio_enet3_gmii_rxd]

# Connect GMII TX interface of port 3
connect_bd_net [get_bd_pins eth_pcs_pma_3_tx/gmii_txclk_0] [get_bd_pins zynq_ultra_ps_e_0/emio_enet3_gmii_tx_clk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/emio_enet3_gmii_tx_en] [get_bd_pins eth_pcs_pma_3_tx/gmii_tx_en_0]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/emio_enet3_gmii_tx_er] [get_bd_pins eth_pcs_pma_3_tx/gmii_tx_er_0]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/emio_enet3_gmii_txd] [get_bd_pins eth_pcs_pma_3_tx/gmii_txd_0]

# PHY RESET for all ports
create_bd_port -dir O reset_port_0_n
connect_bd_net [get_bd_pins /proc_sys_reset_0/peripheral_aresetn] [get_bd_ports reset_port_0_n]
create_bd_port -dir O reset_port_1_n
connect_bd_net [get_bd_pins /proc_sys_reset_0/peripheral_aresetn] [get_bd_ports reset_port_1_n]
create_bd_port -dir O reset_port_2_n
connect_bd_net [get_bd_pins /proc_sys_reset_0/peripheral_aresetn] [get_bd_ports reset_port_2_n]
create_bd_port -dir O reset_port_3_n
connect_bd_net [get_bd_pins /proc_sys_reset_0/peripheral_aresetn] [get_bd_ports reset_port_3_n]

# Create port for the PHY GPIOs
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 phy_gpio
connect_bd_intf_net [get_bd_intf_ports phy_gpio] [get_bd_intf_pins zynq_ultra_ps_e_0/GPIO_0]

# Restore current instance
current_bd_instance $oldCurInst

save_bd_design

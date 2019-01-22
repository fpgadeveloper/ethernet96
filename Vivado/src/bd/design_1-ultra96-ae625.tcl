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

# Enable GP0, HP0 and GPIO EMIO
set_property -dict [list CONFIG.PSU__USE__M_AXI_GP0 {1} \
CONFIG.PSU__USE__M_AXI_GP1 {0} \
CONFIG.PSU__USE__M_AXI_GP2 {0} \
CONFIG.PSU__USE__S_AXI_GP2 {1} \
CONFIG.PSU__USE__IRQ0 {1} \
CONFIG.PSU__USE__IRQ1 {1} \
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
CONFIG.EMAC_IF_TEMAC {TEMAC} \
CONFIG.SupportLevel {Include_Shared_Logic_in_Example_Design} \
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
CONFIG.EMAC_IF_TEMAC {TEMAC} \
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
CONFIG.EMAC_IF_TEMAC {TEMAC} \
CONFIG.SupportLevel {Include_Shared_Logic_in_Core} \
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
CONFIG.EMAC_IF_TEMAC {TEMAC} \
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

# Add the AXI Ethernet Subsystem cores
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_0
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_1
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_2
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_3

# Add the AXI DMAs
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_ethernet_0_dma
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_ethernet_1_dma
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_ethernet_2_dma
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_ethernet_3_dma

# Port 0 configuration
set_property -dict [list CONFIG.Include_IO {false} \
CONFIG.TXCSUM {Full} \
CONFIG.RXCSUM {Full} \
CONFIG.Frame_Filter {false} \
CONFIG.axisclkrate {125}] [get_bd_cells axi_ethernet_0]

# Port 1 configuration
set_property -dict [list CONFIG.Include_IO {false} \
CONFIG.TXCSUM {Full} \
CONFIG.RXCSUM {Full} \
CONFIG.Frame_Filter {false} \
CONFIG.axisclkrate {125}] [get_bd_cells axi_ethernet_1]

# Port 2 configuration
set_property -dict [list CONFIG.Include_IO {false} \
CONFIG.TXCSUM {Full} \
CONFIG.RXCSUM {Full} \
CONFIG.Frame_Filter {false} \
CONFIG.axisclkrate {125}] [get_bd_cells axi_ethernet_2]

# Port 3 configuration
set_property -dict [list CONFIG.Include_IO {false} \
CONFIG.TXCSUM {Full} \
CONFIG.RXCSUM {Full} \
CONFIG.Frame_Filter {false} \
CONFIG.axisclkrate {125}] [get_bd_cells axi_ethernet_3]

# DMA configuration
set_property -dict [list CONFIG.c_sg_length_width {16} \
CONFIG.c_include_mm2s_dre {1} \
CONFIG.c_sg_use_stsapp_length {1} \
CONFIG.c_include_s2mm_dre {1}] [get_bd_cells axi_ethernet_0_dma]
set_property -dict [list CONFIG.c_sg_length_width {16} \
CONFIG.c_include_mm2s_dre {1} \
CONFIG.c_sg_use_stsapp_length {1} \
CONFIG.c_include_s2mm_dre {1}] [get_bd_cells axi_ethernet_1_dma]
set_property -dict [list CONFIG.c_sg_length_width {16} \
CONFIG.c_include_mm2s_dre {1} \
CONFIG.c_sg_use_stsapp_length {1} \
CONFIG.c_include_s2mm_dre {1}] [get_bd_cells axi_ethernet_2_dma]
set_property -dict [list CONFIG.c_sg_length_width {16} \
CONFIG.c_include_mm2s_dre {1} \
CONFIG.c_sg_use_stsapp_length {1} \
CONFIG.c_include_s2mm_dre {1}] [get_bd_cells axi_ethernet_3_dma]


# Constant for the AXI Ethernet clk_en signal
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant const_clk_en
set_property -dict [list CONFIG.CONST_WIDTH {1} CONFIG.CONST_VAL {0x01}] [get_bd_cells const_clk_en]
connect_bd_net [get_bd_pins const_clk_en/dout] [get_bd_pins axi_ethernet_0/clk_en]
connect_bd_net [get_bd_pins const_clk_en/dout] [get_bd_pins axi_ethernet_1/clk_en]
connect_bd_net [get_bd_pins const_clk_en/dout] [get_bd_pins axi_ethernet_2/clk_en]
connect_bd_net [get_bd_pins const_clk_en/dout] [get_bd_pins axi_ethernet_3/clk_en]

# GMII connections for ports 0,1 and 2
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/gmii] [get_bd_intf_pins eth_pcs_pma_0_1/gmii_pcs_pma_0]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/gmii] [get_bd_intf_pins eth_pcs_pma_0_1/gmii_pcs_pma_1]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/gmii] [get_bd_intf_pins eth_pcs_pma_2/gmii_pcs_pma_0]

# GMII connections for port 3
# Connect GMII RX interface of port 3
#connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/gmii_rxclk_0] [get_bd_pins axi_ethernet_3/gmii_rx_clk]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/gmii_rx_dv_0] [get_bd_pins axi_ethernet_3/gmii_rx_dv]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/gmii_rx_er_0] [get_bd_pins axi_ethernet_3/gmii_rx_er]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/gmii_rxd_0] [get_bd_pins axi_ethernet_3/gmii_rxd]

# Connect GMII TX interface of port 3
#connect_bd_net [get_bd_pins eth_pcs_pma_3_tx/gmii_txclk_0] [get_bd_pins axi_ethernet_3/gmii_tx_clk]
connect_bd_net [get_bd_pins axi_ethernet_3/gmii_tx_en] [get_bd_pins eth_pcs_pma_3_tx/gmii_tx_en_0]
connect_bd_net [get_bd_pins axi_ethernet_3/gmii_tx_er] [get_bd_pins eth_pcs_pma_3_tx/gmii_tx_er_0]
connect_bd_net [get_bd_pins axi_ethernet_3/gmii_txd] [get_bd_pins eth_pcs_pma_3_tx/gmii_txd_0]

# eth_pcs_pma_3_rx to eth_pcs_pma_3_tx
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/tx_bsc_rst_out] [get_bd_pins eth_pcs_pma_3_tx/tx_bsc_rst]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/rx_bsc_rst_out] [get_bd_pins eth_pcs_pma_3_tx/rx_bsc_rst]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/tx_bs_rst_out] [get_bd_pins eth_pcs_pma_3_tx/tx_bs_rst]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/rx_bs_rst_out] [get_bd_pins eth_pcs_pma_3_tx/rx_bs_rst]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/tx_rst_dly_out] [get_bd_pins eth_pcs_pma_3_tx/tx_rst_dly]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/rx_rst_dly_out] [get_bd_pins eth_pcs_pma_3_tx/rx_rst_dly]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/riu_clk_out] [get_bd_pins eth_pcs_pma_3_tx/riu_clk]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/riu_wr_en_out] [get_bd_pins eth_pcs_pma_3_tx/riu_wr_en]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/tx_pll_clk_out] [get_bd_pins eth_pcs_pma_3_tx/tx_pll_clk]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/rx_pll_clk_out] [get_bd_pins eth_pcs_pma_3_tx/rx_pll_clk]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/tx_rdclk_out] [get_bd_pins eth_pcs_pma_3_tx/tx_rdclk]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/riu_addr_out] [get_bd_pins eth_pcs_pma_3_tx/riu_addr]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/riu_wr_data_out] [get_bd_pins eth_pcs_pma_3_tx/riu_wr_data]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/riu_nibble_sel_out] [get_bd_pins eth_pcs_pma_3_tx/riu_nibble_sel]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/rx_btval_3] [get_bd_pins eth_pcs_pma_3_tx/rx_btval]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/tx_bsc_en_vtc_out] [get_bd_pins eth_pcs_pma_3_tx/tx_bsc_en_vtc]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/rx_bsc_en_vtc_out] [get_bd_pins eth_pcs_pma_3_tx/rx_bsc_en_vtc]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/tx_bs_en_vtc_out] [get_bd_pins eth_pcs_pma_3_tx/tx_bs_en_vtc]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/rx_bs_en_vtc_out] [get_bd_pins eth_pcs_pma_3_tx/rx_bs_en_vtc]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/clk125_out] [get_bd_pins eth_pcs_pma_3_tx/clk125m]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/clk312_out] [get_bd_pins eth_pcs_pma_3_tx/clk312]

# eth_pcs_pma_3_rx to eth_pcs_pma_2
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/tx_bsc_rst_out] [get_bd_pins eth_pcs_pma_2/tx_bsc_rst]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/rx_bsc_rst_out] [get_bd_pins eth_pcs_pma_2/rx_bsc_rst]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/tx_bs_rst_out] [get_bd_pins eth_pcs_pma_2/tx_bs_rst]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/rx_bs_rst_out] [get_bd_pins eth_pcs_pma_2/rx_bs_rst]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/tx_rst_dly_out] [get_bd_pins eth_pcs_pma_2/tx_rst_dly]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/rx_rst_dly_out] [get_bd_pins eth_pcs_pma_2/rx_rst_dly]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/riu_clk_out] [get_bd_pins eth_pcs_pma_2/riu_clk]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/riu_wr_en_out] [get_bd_pins eth_pcs_pma_2/riu_wr_en]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/tx_pll_clk_out] [get_bd_pins eth_pcs_pma_2/tx_pll_clk]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/rx_pll_clk_out] [get_bd_pins eth_pcs_pma_2/rx_pll_clk]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/tx_rdclk_out] [get_bd_pins eth_pcs_pma_2/tx_rdclk]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/riu_addr_out] [get_bd_pins eth_pcs_pma_2/riu_addr]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/riu_wr_data_out] [get_bd_pins eth_pcs_pma_2/riu_wr_data]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/riu_nibble_sel_out] [get_bd_pins eth_pcs_pma_2/riu_nibble_sel]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/rx_btval_2] [get_bd_pins eth_pcs_pma_2/rx_btval]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/tx_bsc_en_vtc_out] [get_bd_pins eth_pcs_pma_2/tx_bsc_en_vtc]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/rx_bsc_en_vtc_out] [get_bd_pins eth_pcs_pma_2/rx_bsc_en_vtc]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/tx_bs_en_vtc_out] [get_bd_pins eth_pcs_pma_2/tx_bs_en_vtc]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/rx_bs_en_vtc_out] [get_bd_pins eth_pcs_pma_2/rx_bs_en_vtc]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/clk125_out] [get_bd_pins eth_pcs_pma_2/clk125m]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/clk312_out] [get_bd_pins eth_pcs_pma_2/clk312]

# eth_pcs_pma_3_rx to eth_pcs_pma_0_1
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/tx_bsc_rst_out] [get_bd_pins eth_pcs_pma_0_1/tx_bsc_rst]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/rx_bsc_rst_out] [get_bd_pins eth_pcs_pma_0_1/rx_bsc_rst]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/tx_bs_rst_out] [get_bd_pins eth_pcs_pma_0_1/tx_bs_rst]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/rx_bs_rst_out] [get_bd_pins eth_pcs_pma_0_1/rx_bs_rst]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/tx_rst_dly_out] [get_bd_pins eth_pcs_pma_0_1/tx_rst_dly]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/rx_rst_dly_out] [get_bd_pins eth_pcs_pma_0_1/rx_rst_dly]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/riu_clk_out] [get_bd_pins eth_pcs_pma_0_1/riu_clk]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/riu_wr_en_out] [get_bd_pins eth_pcs_pma_0_1/riu_wr_en]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/tx_pll_clk_out] [get_bd_pins eth_pcs_pma_0_1/tx_pll_clk]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/rx_pll_clk_out] [get_bd_pins eth_pcs_pma_0_1/rx_pll_clk]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/tx_rdclk_out] [get_bd_pins eth_pcs_pma_0_1/tx_rdclk]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/riu_addr_out] [get_bd_pins eth_pcs_pma_0_1/riu_addr]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/riu_wr_data_out] [get_bd_pins eth_pcs_pma_0_1/riu_wr_data]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/riu_nibble_sel_out] [get_bd_pins eth_pcs_pma_0_1/riu_nibble_sel]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/rx_btval_1] [get_bd_pins eth_pcs_pma_0_1/rx_btval]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/tx_bsc_en_vtc_out] [get_bd_pins eth_pcs_pma_0_1/tx_bsc_en_vtc]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/rx_bsc_en_vtc_out] [get_bd_pins eth_pcs_pma_0_1/rx_bsc_en_vtc]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/tx_bs_en_vtc_out] [get_bd_pins eth_pcs_pma_0_1/tx_bs_en_vtc]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/rx_bs_en_vtc_out] [get_bd_pins eth_pcs_pma_0_1/rx_bs_en_vtc]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/clk125_out] [get_bd_pins eth_pcs_pma_0_1/clk125m]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/clk312_out] [get_bd_pins eth_pcs_pma_0_1/clk312]

# Shared logic connections
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/riu_rd_data] [get_bd_pins eth_pcs_pma_3_rx/riu_rddata_1]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/riu_valid] [get_bd_pins eth_pcs_pma_3_rx/riu_valid_1]
connect_bd_net [get_bd_pins eth_pcs_pma_2/riu_rd_data] [get_bd_pins eth_pcs_pma_3_rx/riu_rddata_2]
connect_bd_net [get_bd_pins eth_pcs_pma_2/riu_valid] [get_bd_pins eth_pcs_pma_3_rx/riu_valid_2]
connect_bd_net [get_bd_pins eth_pcs_pma_3_tx/riu_rd_data] [get_bd_pins eth_pcs_pma_3_rx/riu_rddata_3]
connect_bd_net [get_bd_pins eth_pcs_pma_3_tx/riu_valid] [get_bd_pins eth_pcs_pma_3_rx/riu_valid_3]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/riu_prsnt] [get_bd_pins eth_pcs_pma_3_rx/riu_prsnt_1]
connect_bd_net [get_bd_pins eth_pcs_pma_2/riu_prsnt] [get_bd_pins eth_pcs_pma_3_rx/riu_prsnt_2]
connect_bd_net [get_bd_pins eth_pcs_pma_3_tx/riu_prsnt] [get_bd_pins eth_pcs_pma_3_rx/riu_prsnt_3]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/tx_dly_rdy] [get_bd_pins eth_pcs_pma_3_rx/tx_dly_rdy_1]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/rx_dly_rdy] [get_bd_pins eth_pcs_pma_3_rx/rx_dly_rdy_1]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/tx_vtc_rdy] [get_bd_pins eth_pcs_pma_3_rx/tx_vtc_rdy_1]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/rx_vtc_rdy] [get_bd_pins eth_pcs_pma_3_rx/rx_vtc_rdy_1]
connect_bd_net [get_bd_pins eth_pcs_pma_2/tx_dly_rdy] [get_bd_pins eth_pcs_pma_3_rx/tx_dly_rdy_2]
connect_bd_net [get_bd_pins eth_pcs_pma_2/rx_dly_rdy] [get_bd_pins eth_pcs_pma_3_rx/rx_dly_rdy_2]
connect_bd_net [get_bd_pins eth_pcs_pma_2/tx_vtc_rdy] [get_bd_pins eth_pcs_pma_3_rx/tx_vtc_rdy_2]
connect_bd_net [get_bd_pins eth_pcs_pma_2/rx_vtc_rdy] [get_bd_pins eth_pcs_pma_3_rx/rx_vtc_rdy_2]
connect_bd_net [get_bd_pins eth_pcs_pma_3_tx/tx_dly_rdy] [get_bd_pins eth_pcs_pma_3_rx/tx_dly_rdy_3]
connect_bd_net [get_bd_pins eth_pcs_pma_3_tx/rx_dly_rdy] [get_bd_pins eth_pcs_pma_3_rx/rx_dly_rdy_3]
connect_bd_net [get_bd_pins eth_pcs_pma_3_tx/tx_vtc_rdy] [get_bd_pins eth_pcs_pma_3_rx/tx_vtc_rdy_3]
connect_bd_net [get_bd_pins eth_pcs_pma_3_tx/rx_vtc_rdy] [get_bd_pins eth_pcs_pma_3_rx/rx_vtc_rdy_3]

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

# Clocks
connect_bd_net [get_bd_pins util_ds_buf_1/BUFG_O] [get_bd_pins axi_ethernet_0/axis_clk]
connect_bd_net [get_bd_pins util_ds_buf_1/BUFG_O] [get_bd_pins axi_ethernet_1/axis_clk]
connect_bd_net [get_bd_pins util_ds_buf_1/BUFG_O] [get_bd_pins axi_ethernet_2/axis_clk]
connect_bd_net [get_bd_pins util_ds_buf_1/BUFG_O] [get_bd_pins axi_ethernet_3/axis_clk]

connect_bd_net [get_bd_pins util_ds_buf_1/BUFG_O] [get_bd_pins axi_ethernet_0/gtx_clk]
connect_bd_net [get_bd_pins util_ds_buf_1/BUFG_O] [get_bd_pins axi_ethernet_1/gtx_clk]
connect_bd_net [get_bd_pins util_ds_buf_1/BUFG_O] [get_bd_pins axi_ethernet_2/gtx_clk]
connect_bd_net [get_bd_pins util_ds_buf_1/BUFG_O] [get_bd_pins axi_ethernet_3/gtx_clk]

connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_ethernet_0/s_axi_lite_clk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_ethernet_1/s_axi_lite_clk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_ethernet_2/s_axi_lite_clk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_ethernet_3/s_axi_lite_clk]

# Resets
create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic reset_invert
set_property -dict [list CONFIG.C_SIZE {1} CONFIG.C_OPERATION {not} CONFIG.LOGO_FILE {data/sym_notgate.png}] [get_bd_cells reset_invert]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins reset_invert/Op1]
connect_bd_net [get_bd_pins reset_invert/Res] [get_bd_pins eth_pcs_pma_3_rx/reset]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/rst_125_out] [get_bd_pins eth_pcs_pma_0_1/reset]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/rst_125_out] [get_bd_pins eth_pcs_pma_2/reset]
connect_bd_net [get_bd_pins eth_pcs_pma_3_rx/rst_125_out] [get_bd_pins eth_pcs_pma_3_tx/reset]

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

# signal_detect tied HIGH
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant const_signal_detect
connect_bd_net [get_bd_pins const_signal_detect/dout] [get_bd_pins eth_pcs_pma_0_1/signal_detect_0]
connect_bd_net [get_bd_pins const_signal_detect/dout] [get_bd_pins eth_pcs_pma_0_1/signal_detect_1]
connect_bd_net [get_bd_pins const_signal_detect/dout] [get_bd_pins eth_pcs_pma_2/signal_detect_0]
connect_bd_net [get_bd_pins const_signal_detect/dout] [get_bd_pins eth_pcs_pma_3_rx/signal_detect_0]
connect_bd_net [get_bd_pins const_signal_detect/dout] [get_bd_pins eth_pcs_pma_3_tx/signal_detect_0]

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
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/mdio] [get_bd_intf_pins eth_pcs_pma_0_1/mdio_pcs_pma_0]
connect_bd_intf_net [get_bd_intf_pins eth_pcs_pma_0_1/ext_mdio_pcs_pma_0] [get_bd_intf_pins eth_pcs_pma_0_1/mdio_pcs_pma_1]
connect_bd_intf_net [get_bd_intf_pins eth_pcs_pma_0_1/ext_mdio_pcs_pma_1] [get_bd_intf_pins eth_pcs_pma_2/mdio_pcs_pma_0]
connect_bd_intf_net [get_bd_intf_pins eth_pcs_pma_2/ext_mdio_pcs_pma_0] [get_bd_intf_pins eth_pcs_pma_3_tx/mdio_pcs_pma_0]
connect_bd_intf_net [get_bd_intf_pins eth_pcs_pma_3_tx/ext_mdio_pcs_pma_0] [get_bd_intf_pins eth_pcs_pma_3_rx/mdio_pcs_pma_0]
connect_bd_intf_net [get_bd_intf_pins eth_pcs_pma_3_rx/ext_mdio_pcs_pma_0] [get_bd_intf_ports mdio]

# Connect the tri-state inputs for the MDIO bus
connect_bd_net [get_bd_pins axi_ethernet_0/mdio_mdio_t] [get_bd_pins eth_pcs_pma_0_1/mdio_t_in_0]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/ext_mdio_t_0] [get_bd_pins eth_pcs_pma_0_1/mdio_t_in_1]
connect_bd_net [get_bd_pins eth_pcs_pma_0_1/ext_mdio_t_1] [get_bd_pins eth_pcs_pma_2/mdio_t_in_0]
connect_bd_net [get_bd_pins eth_pcs_pma_2/ext_mdio_t_0] [get_bd_pins eth_pcs_pma_3_tx/mdio_t_in_0]
connect_bd_net [get_bd_pins eth_pcs_pma_3_tx/ext_mdio_t_0] [get_bd_pins eth_pcs_pma_3_rx/mdio_t_in_0]

# Create the ref clk 625MHz port
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 ref_clk_625mhz
set_property CONFIG.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_intf_pins eth_pcs_pma_3_rx/refclk625_in]] [get_bd_intf_ports ref_clk_625mhz]
connect_bd_intf_net [get_bd_intf_pins eth_pcs_pma_3_rx/refclk625_in] [get_bd_intf_ports ref_clk_625mhz]

# PHY RESET for all ports
create_bd_port -dir O reset_port_0_n
connect_bd_net [get_bd_ports reset_port_0_n] [get_bd_pins axi_ethernet_0/phy_rst_n]
create_bd_port -dir O reset_port_1_n
connect_bd_net [get_bd_ports reset_port_1_n] [get_bd_pins axi_ethernet_1/phy_rst_n]
create_bd_port -dir O reset_port_2_n
connect_bd_net [get_bd_ports reset_port_2_n] [get_bd_pins axi_ethernet_2/phy_rst_n]
create_bd_port -dir O reset_port_3_n
connect_bd_net [get_bd_ports reset_port_3_n] [get_bd_pins axi_ethernet_3/phy_rst_n]

# Create port for the PHY GPIOs
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 phy_gpio
connect_bd_intf_net [get_bd_intf_ports phy_gpio] [get_bd_intf_pins zynq_ultra_ps_e_0/GPIO_0]

# PS GP0 and HP0 port clocks
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_fpd_aclk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins zynq_ultra_ps_e_0/saxihp0_fpd_aclk]

# DMA Connections
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0_dma/M_AXIS_MM2S] [get_bd_intf_pins axi_ethernet_0/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0_dma/M_AXIS_CNTRL] [get_bd_intf_pins axi_ethernet_0/s_axis_txc]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/m_axis_rxd] [get_bd_intf_pins axi_ethernet_0_dma/S_AXIS_S2MM]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/m_axis_rxs] [get_bd_intf_pins axi_ethernet_0_dma/S_AXIS_STS]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1_dma/M_AXIS_MM2S] [get_bd_intf_pins axi_ethernet_1/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1_dma/M_AXIS_CNTRL] [get_bd_intf_pins axi_ethernet_1/s_axis_txc]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/m_axis_rxd] [get_bd_intf_pins axi_ethernet_1_dma/S_AXIS_S2MM]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/m_axis_rxs] [get_bd_intf_pins axi_ethernet_1_dma/S_AXIS_STS]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2_dma/M_AXIS_MM2S] [get_bd_intf_pins axi_ethernet_2/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2_dma/M_AXIS_CNTRL] [get_bd_intf_pins axi_ethernet_2/s_axis_txc]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/m_axis_rxd] [get_bd_intf_pins axi_ethernet_2_dma/S_AXIS_S2MM]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/m_axis_rxs] [get_bd_intf_pins axi_ethernet_2_dma/S_AXIS_STS]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3_dma/M_AXIS_MM2S] [get_bd_intf_pins axi_ethernet_3/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3_dma/M_AXIS_CNTRL] [get_bd_intf_pins axi_ethernet_3/s_axis_txc]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3/m_axis_rxd] [get_bd_intf_pins axi_ethernet_3_dma/S_AXIS_S2MM]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3/m_axis_rxs] [get_bd_intf_pins axi_ethernet_3_dma/S_AXIS_STS]

connect_bd_net [get_bd_pins axi_ethernet_0_dma/mm2s_prmry_reset_out_n] [get_bd_pins axi_ethernet_0/axi_txd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_0_dma/mm2s_cntrl_reset_out_n] [get_bd_pins axi_ethernet_0/axi_txc_arstn]
connect_bd_net [get_bd_pins axi_ethernet_0_dma/s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_0/axi_rxd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_0_dma/s2mm_sts_reset_out_n] [get_bd_pins axi_ethernet_0/axi_rxs_arstn]
connect_bd_net [get_bd_pins axi_ethernet_1_dma/mm2s_prmry_reset_out_n] [get_bd_pins axi_ethernet_1/axi_txd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_1_dma/mm2s_cntrl_reset_out_n] [get_bd_pins axi_ethernet_1/axi_txc_arstn]
connect_bd_net [get_bd_pins axi_ethernet_1_dma/s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_1/axi_rxd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_1_dma/s2mm_sts_reset_out_n] [get_bd_pins axi_ethernet_1/axi_rxs_arstn]
connect_bd_net [get_bd_pins axi_ethernet_2_dma/mm2s_prmry_reset_out_n] [get_bd_pins axi_ethernet_2/axi_txd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_2_dma/mm2s_cntrl_reset_out_n] [get_bd_pins axi_ethernet_2/axi_txc_arstn]
connect_bd_net [get_bd_pins axi_ethernet_2_dma/s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_2/axi_rxd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_2_dma/s2mm_sts_reset_out_n] [get_bd_pins axi_ethernet_2/axi_rxs_arstn]
connect_bd_net [get_bd_pins axi_ethernet_3_dma/mm2s_prmry_reset_out_n] [get_bd_pins axi_ethernet_3/axi_txd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_3_dma/mm2s_cntrl_reset_out_n] [get_bd_pins axi_ethernet_3/axi_txc_arstn]
connect_bd_net [get_bd_pins axi_ethernet_3_dma/s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_3/axi_rxd_arstn]
connect_bd_net [get_bd_pins axi_ethernet_3_dma/s2mm_sts_reset_out_n] [get_bd_pins axi_ethernet_3/axi_rxs_arstn]

connect_bd_net [get_bd_pins util_ds_buf_1/BUFG_O] [get_bd_pins axi_ethernet_0_dma/m_axi_sg_aclk]
connect_bd_net [get_bd_pins util_ds_buf_1/BUFG_O] [get_bd_pins axi_ethernet_0_dma/m_axi_mm2s_aclk]
connect_bd_net [get_bd_pins util_ds_buf_1/BUFG_O] [get_bd_pins axi_ethernet_0_dma/m_axi_s2mm_aclk]
connect_bd_net [get_bd_pins util_ds_buf_1/BUFG_O] [get_bd_pins axi_ethernet_1_dma/m_axi_sg_aclk]
connect_bd_net [get_bd_pins util_ds_buf_1/BUFG_O] [get_bd_pins axi_ethernet_1_dma/m_axi_mm2s_aclk]
connect_bd_net [get_bd_pins util_ds_buf_1/BUFG_O] [get_bd_pins axi_ethernet_1_dma/m_axi_s2mm_aclk]
connect_bd_net [get_bd_pins util_ds_buf_1/BUFG_O] [get_bd_pins axi_ethernet_2_dma/m_axi_sg_aclk]
connect_bd_net [get_bd_pins util_ds_buf_1/BUFG_O] [get_bd_pins axi_ethernet_2_dma/m_axi_mm2s_aclk]
connect_bd_net [get_bd_pins util_ds_buf_1/BUFG_O] [get_bd_pins axi_ethernet_2_dma/m_axi_s2mm_aclk]
connect_bd_net [get_bd_pins util_ds_buf_1/BUFG_O] [get_bd_pins axi_ethernet_3_dma/m_axi_sg_aclk]
connect_bd_net [get_bd_pins util_ds_buf_1/BUFG_O] [get_bd_pins axi_ethernet_3_dma/m_axi_mm2s_aclk]
connect_bd_net [get_bd_pins util_ds_buf_1/BUFG_O] [get_bd_pins axi_ethernet_3_dma/m_axi_s2mm_aclk]

connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_ethernet_0_dma/s_axi_lite_aclk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_ethernet_1_dma/s_axi_lite_aclk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_ethernet_2_dma/s_axi_lite_aclk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_ethernet_3_dma/s_axi_lite_aclk]

# Concats for the interrupts
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat xlconcat_0
set_property -dict [list CONFIG.NUM_PORTS {8}] [get_bd_cells xlconcat_0]
connect_bd_net [get_bd_pins xlconcat_0/dout] [get_bd_pins zynq_ultra_ps_e_0/pl_ps_irq0]

connect_bd_net [get_bd_pins axi_ethernet_0/mac_irq] [get_bd_pins xlconcat_0/In0]
connect_bd_net [get_bd_pins axi_ethernet_0/interrupt] [get_bd_pins xlconcat_0/In1]
connect_bd_net [get_bd_pins axi_ethernet_0_dma/mm2s_introut] [get_bd_pins xlconcat_0/In2]
connect_bd_net [get_bd_pins axi_ethernet_0_dma/s2mm_introut] [get_bd_pins xlconcat_0/In3]

connect_bd_net [get_bd_pins axi_ethernet_1/mac_irq] [get_bd_pins xlconcat_0/In4]
connect_bd_net [get_bd_pins axi_ethernet_1/interrupt] [get_bd_pins xlconcat_0/In5]
connect_bd_net [get_bd_pins axi_ethernet_1_dma/mm2s_introut] [get_bd_pins xlconcat_0/In6]
connect_bd_net [get_bd_pins axi_ethernet_1_dma/s2mm_introut] [get_bd_pins xlconcat_0/In7]

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat xlconcat_1
set_property -dict [list CONFIG.NUM_PORTS {8}] [get_bd_cells xlconcat_1]
connect_bd_net [get_bd_pins xlconcat_1/dout] [get_bd_pins zynq_ultra_ps_e_0/pl_ps_irq1]

connect_bd_net [get_bd_pins axi_ethernet_2/mac_irq] [get_bd_pins xlconcat_1/In0]
connect_bd_net [get_bd_pins axi_ethernet_2/interrupt] [get_bd_pins xlconcat_1/In1]
connect_bd_net [get_bd_pins axi_ethernet_2_dma/mm2s_introut] [get_bd_pins xlconcat_1/In2]
connect_bd_net [get_bd_pins axi_ethernet_2_dma/s2mm_introut] [get_bd_pins xlconcat_1/In3]
connect_bd_net [get_bd_pins axi_ethernet_3/mac_irq] [get_bd_pins xlconcat_1/In4]
connect_bd_net [get_bd_pins axi_ethernet_3/interrupt] [get_bd_pins xlconcat_1/In5]
connect_bd_net [get_bd_pins axi_ethernet_3_dma/mm2s_introut] [get_bd_pins xlconcat_1/In6]
connect_bd_net [get_bd_pins axi_ethernet_3_dma/s2mm_introut] [get_bd_pins xlconcat_1/In7]

# Automation for the S_AXI interfaces of the AXI Ethernet ports
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD} Slave {/axi_ethernet_0/s_axi} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins axi_ethernet_0/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD} Slave {/axi_ethernet_1/s_axi} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins axi_ethernet_1/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD} Slave {/axi_ethernet_2/s_axi} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins axi_ethernet_2/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD} Slave {/axi_ethernet_2/s_axi} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins axi_ethernet_3/s_axi]

# Automation for the S_AXI interfaces of the AXI DMAs
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD} Slave {/axi_ethernet_0_dma/S_AXI_LITE} intc_ip {/ps8_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_ethernet_0_dma/S_AXI_LITE]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD} Slave {/axi_ethernet_1_dma/S_AXI_LITE} intc_ip {/ps8_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_ethernet_1_dma/S_AXI_LITE]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD} Slave {/axi_ethernet_2_dma/S_AXI_LITE} intc_ip {/ps8_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_ethernet_2_dma/S_AXI_LITE]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD} Slave {/axi_ethernet_2_dma/S_AXI_LITE} intc_ip {/ps8_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_ethernet_3_dma/S_AXI_LITE]

# Automation for the M_AXI interfaces of the AXI DMAs
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/util_ds_buf_1/BUFG_O (125 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_xbar {Auto} Master {/axi_ethernet_0_dma/M_AXI_SG} Slave {/zynq_ultra_ps_e_0/S_AXI_HP0_FPD} intc_ip {Auto} master_apm {0}}  [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HP0_FPD]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/util_ds_buf_1/BUFG_O (125 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_xbar {/util_ds_buf_1/BUFG_O (125 MHz)} Master {/axi_ethernet_0_dma/M_AXI_MM2S} Slave {/zynq_ultra_ps_e_0/S_AXI_HP0_FPD} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins axi_ethernet_0_dma/M_AXI_MM2S]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/util_ds_buf_1/BUFG_O (125 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_xbar {/util_ds_buf_1/BUFG_O (125 MHz)} Master {/axi_ethernet_0_dma/M_AXI_S2MM} Slave {/zynq_ultra_ps_e_0/S_AXI_HP0_FPD} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins axi_ethernet_0_dma/M_AXI_S2MM]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/util_ds_buf_1/BUFG_O (125 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_xbar {/util_ds_buf_1/BUFG_O (125 MHz)} Master {/axi_ethernet_1_dma/M_AXI_SG} Slave {/zynq_ultra_ps_e_0/S_AXI_HP0_FPD} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins axi_ethernet_1_dma/M_AXI_SG]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/util_ds_buf_1/BUFG_O (125 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_xbar {/util_ds_buf_1/BUFG_O (125 MHz)} Master {/axi_ethernet_1_dma/M_AXI_MM2S} Slave {/zynq_ultra_ps_e_0/S_AXI_HP0_FPD} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins axi_ethernet_1_dma/M_AXI_MM2S]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/util_ds_buf_1/BUFG_O (125 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_xbar {/util_ds_buf_1/BUFG_O (125 MHz)} Master {/axi_ethernet_1_dma/M_AXI_S2MM} Slave {/zynq_ultra_ps_e_0/S_AXI_HP0_FPD} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins axi_ethernet_1_dma/M_AXI_S2MM]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/util_ds_buf_1/BUFG_O (125 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_xbar {/util_ds_buf_1/BUFG_O (125 MHz)} Master {/axi_ethernet_2_dma/M_AXI_SG} Slave {/zynq_ultra_ps_e_0/S_AXI_HP0_FPD} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins axi_ethernet_2_dma/M_AXI_SG]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/util_ds_buf_1/BUFG_O (125 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_xbar {/util_ds_buf_1/BUFG_O (125 MHz)} Master {/axi_ethernet_2_dma/M_AXI_MM2S} Slave {/zynq_ultra_ps_e_0/S_AXI_HP0_FPD} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins axi_ethernet_2_dma/M_AXI_MM2S]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/util_ds_buf_1/BUFG_O (125 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_xbar {/util_ds_buf_1/BUFG_O (125 MHz)} Master {/axi_ethernet_2_dma/M_AXI_S2MM} Slave {/zynq_ultra_ps_e_0/S_AXI_HP0_FPD} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins axi_ethernet_2_dma/M_AXI_S2MM]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/util_ds_buf_1/BUFG_O (125 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_xbar {/util_ds_buf_1/BUFG_O (125 MHz)} Master {/axi_ethernet_2_dma/M_AXI_SG} Slave {/zynq_ultra_ps_e_0/S_AXI_HP0_FPD} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins axi_ethernet_3_dma/M_AXI_SG]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/util_ds_buf_1/BUFG_O (125 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_xbar {/util_ds_buf_1/BUFG_O (125 MHz)} Master {/axi_ethernet_2_dma/M_AXI_MM2S} Slave {/zynq_ultra_ps_e_0/S_AXI_HP0_FPD} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins axi_ethernet_3_dma/M_AXI_MM2S]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/util_ds_buf_1/BUFG_O (125 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_xbar {/util_ds_buf_1/BUFG_O (125 MHz)} Master {/axi_ethernet_2_dma/M_AXI_S2MM} Slave {/zynq_ultra_ps_e_0/S_AXI_HP0_FPD} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins axi_ethernet_3_dma/M_AXI_S2MM]

# Restore current instance
current_bd_instance $oldCurInst

save_bd_design

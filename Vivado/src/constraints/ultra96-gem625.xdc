#
#     IO standard for Bank 26 Vcco supply is fixed at 1.8V
#     IO standard for Bank 65 Vcco supply is fixed at 1.2V
# 
 
# ----------------------------------------------------------------------------
# High-speed expansion connector
# ---------------------------------------------------------------------------- 

# BYTE usage in BANK 65:
# ----------------------
# BYTE   Nibble   PCS/PMA           Usage
# --------------------------------------------------------------
# 0      Lower    eth_pcs_pma_3_rx  PORT 3 RX, REF CLK 625MHz
#        Upper                      Not connected
# 1      Lower    eth_pcs_pma_0_1   PORT 0,1 RX
#        Upper    eth_pcs_pma_0_1   PORT 0,1 TX
# 2      Lower                      Not connected
#        Upper    eth_pcs_pma_3_tx  PORT 3 TX
# 3      Lower    eth_pcs_pma_2     PORT 2 RX
#        Upper    eth_pcs_pma_2     PORT 2 TX

# Bank 65 (1.2V)

# BANK65_BYTE0 Lower nibble
set_property PACKAGE_PIN T2   [get_ports {sgmii_port_3_rx_rxn}];  # "T2.CSI1_C_N" Clock capable DBC
set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_3_rx_rxn}];
set_property PACKAGE_PIN T3   [get_ports {sgmii_port_3_rx_rxp}];  # "T3.CSI1_C_P" Clock capable DBC
set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_3_rx_rxp}];
set_property PACKAGE_PIN R3   [get_ports {ref_clk_625mhz_clk_n}];  # "R3.CSI1_D0_N"
set_property IOSTANDARD DIFF_SSTL12 [get_ports {ref_clk_625mhz_clk_n}];
set_property PACKAGE_PIN P3   [get_ports {ref_clk_625mhz_clk_p}];  # "P3.CSI1_D0_P"
set_property IOSTANDARD DIFF_SSTL12 [get_ports {ref_clk_625mhz_clk_p}];
set_property PACKAGE_PIN U1   [get_ports {phy_gpio_tri_io[4]}];  # "U1.CSI1_D1_N"
set_property IOSTANDARD SSTL12 [get_ports {phy_gpio_tri_io[4]}];
set_property PACKAGE_PIN U2   [get_ports {phy_gpio_tri_io[5]}];  # "U2.CSI1_D1_P"
set_property IOSTANDARD SSTL12 [get_ports {phy_gpio_tri_io[5]}];

# BANK65_BYTE0 Upper nibble
set_property PACKAGE_PIN T4   [get_ports {sgmii_port_3_rx_txn}];  # T4 Not connected
set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_3_rx_txn}];
set_property PACKAGE_PIN R4   [get_ports {sgmii_port_3_rx_txp}];  # R4 Not connected
set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_3_rx_txp}];
#set_property PACKAGE_PIN T1   [get_ports {sgmii_port_3_rx_txn}];  # T1 Not connected
#set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_3_rx_txn}];
#set_property PACKAGE_PIN R1   [get_ports {sgmii_port_3_rx_txp}];  # R1 Not connected
#set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_3_rx_txp}];

# BANK65_BYTE1 Lower nibble
set_property PACKAGE_PIN P1   [get_ports {sgmii_port_0_rxn}];  # "P1.CSI0_C_N" Clock capable QBC
set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_0_rxn}];
set_property PACKAGE_PIN N2   [get_ports {sgmii_port_0_rxp}];  # "N2.CSI0_C_P" Clock capable QBC
set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_0_rxp}];
set_property PACKAGE_PIN N4   [get_ports {sgmii_port_1_rxn}];  # "N4.CSI0_D0_N"
set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_1_rxn}];
set_property PACKAGE_PIN N5   [get_ports {sgmii_port_1_rxp}];  # "N5.CSI0_D0_P"
set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_1_rxp}];
set_property PACKAGE_PIN M1   [get_ports {phy_gpio_tri_io[2]}];  # "M1.CSI0_D1_N"
set_property IOSTANDARD SSTL12 [get_ports {phy_gpio_tri_io[2]}];
set_property PACKAGE_PIN M2   [get_ports {phy_gpio_tri_io[3]}];  # "M2.CSI0_D1_P"
set_property IOSTANDARD SSTL12 [get_ports {phy_gpio_tri_io[3]}];

# BANK65_BYTE1 Upper nibble
set_property PACKAGE_PIN M4   [get_ports {sgmii_port_0_txn}];  # "M4.CSI0_D2_N" Clock capable QBC
set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_0_txn}];
set_property PACKAGE_PIN M5   [get_ports {sgmii_port_0_txp}];  # "M5.CSI0_D2_P" Clock capable QBC
set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_0_txp}];
set_property PACKAGE_PIN L1   [get_ports {sgmii_port_1_txn}];  # "L1.CSI0_D3_N" Global clock capable
set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_1_txn}];
set_property PACKAGE_PIN L2   [get_ports {sgmii_port_1_txp}];  # "L2.CSI0_D3_P" Global clock capable
set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_1_txp}];
#set_property PACKAGE_PIN L3   [get_ports {sgmii_port_3_rx_txn}];  # L3 Not connected
#set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_3_rx_txn}];
#set_property PACKAGE_PIN L4   [get_ports {sgmii_port_3_rx_txp}];  # L4 Not connected
#set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_3_rx_txp}];

# BANK65_BYTE2 Lower nibble
set_property PACKAGE_PIN J2   [get_ports {sgmii_port_3_tx_rxn}];  # J2 Not connected
set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_3_tx_rxn}];
set_property PACKAGE_PIN J3   [get_ports {sgmii_port_3_tx_rxp}];  # J3 Not connected
set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_3_tx_rxp}];

# BANK65_BYTE2 Upper nibble
set_property PACKAGE_PIN H5   [get_ports {sgmii_port_3_tx_txn}];  # "H5.DSI_CLK_N" Clock capable QBC
set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_3_tx_txn}];
set_property PACKAGE_PIN J5   [get_ports {sgmii_port_3_tx_txp}];  # "J5.DSI_CLK_P" Clock capable QBC
set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_3_tx_txp}];

# BANK65_BYTE3 Lower nibble
set_property PACKAGE_PIN F1   [get_ports {sgmii_port_2_rxn}];  # "F1.DSI_D0_N" Clock capable DBC
set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_2_rxn}];
set_property PACKAGE_PIN G1   [get_ports {sgmii_port_2_rxp}];  # "G1.DSI_D0_P" Clock capable DBC
set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_2_rxp}];
set_property PACKAGE_PIN E3   [get_ports {phy_gpio_tri_io[0]}];  # "E3.DSI_D1_N"
set_property IOSTANDARD SSTL12 [get_ports {phy_gpio_tri_io[0]}];
set_property PACKAGE_PIN E4   [get_ports {phy_gpio_tri_io[1]}];  # "E4.DSI_D1_P"
set_property IOSTANDARD SSTL12 [get_ports {phy_gpio_tri_io[1]}];
set_property PACKAGE_PIN D1   [get_ports {phy_gpio_tri_io[7]}];  # "D1.DSI_D2_N"
set_property IOSTANDARD SSTL12 [get_ports {phy_gpio_tri_io[7]}];
set_property PACKAGE_PIN E1   [get_ports {phy_gpio_tri_io[6]}];  # "E1.DSI_D2_P"
set_property IOSTANDARD SSTL12 [get_ports {phy_gpio_tri_io[6]}];

# BANK65_BYTE3 Upper nibble
set_property PACKAGE_PIN C3   [get_ports {sgmii_port_2_txn}];  # "C3.DSI_D3_N" Clock capable DBC
set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_2_txn}];
set_property PACKAGE_PIN D3   [get_ports {sgmii_port_2_txp}];  # "D3.DSI_D3_P" Clock capable DBC
set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_2_txp}];
#set_property PACKAGE_PIN F2   [get_ports {sgmii_port_3_tx_rxn}];  # F2 Not connected
#set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_3_tx_rxn}];
#set_property PACKAGE_PIN F3   [get_ports {sgmii_port_3_tx_rxp}];  # F3 Not connected
#set_property IOSTANDARD DIFF_SSTL12 [get_ports {sgmii_port_3_tx_rxp}];
#set_property PACKAGE_PIN C2   [get_ports {HSIC_DATA               }];  # "C2.HSIC_DATA"

# Set VREF to VCC/2 = 0.6V in Bank 65 for the SGMII inputs
set_property INTERNAL_VREF 0.60 [get_iobanks 65]

## Bank 66
#set_property PACKAGE_PIN A2   [get_ports {HSIC_STR                }];  # "A2.HSIC_STR"

## Bank 26 (1.8V)
set_property PACKAGE_PIN E8   [get_ports {ref_clk_125mhz_clk_p}];  # "E8.CSI0_MCLK"
set_property IOSTANDARD DIFF_SSTL18_I [get_ports {ref_clk_125mhz_clk_p}];
set_property ODT RTT_48 [get_ports {ref_clk_125mhz_clk_p}];
set_property PACKAGE_PIN D8   [get_ports {ref_clk_125mhz_clk_n}];  # "D8.CSI1_MCLK"
set_property IOSTANDARD DIFF_SSTL18_I [get_ports {ref_clk_125mhz_clk_n}];
set_property ODT RTT_48 [get_ports {ref_clk_125mhz_clk_n}];

# Set VREF to VCC/2 = 0.9V to enable the ref_clk input
set_property INTERNAL_VREF 0.90 [get_iobanks 26]

# ----------------------------------------------------------------------------
# Low-speed expansion connector
# ---------------------------------------------------------------------------- 
# Bank 23 (1.8V)
#set_property PACKAGE_PIN D7   [get_ports {HD_GPIO_0}];  # "D7.HD_GPIO_0"
#set_property IOSTANDARD LVCMOS18 [get_ports {HD_GPIO_0}];
#set_property PACKAGE_PIN F8   [get_ports {HD_GPIO_1}];  # "F8.HD_GPIO_1"
#set_property IOSTANDARD LVCMOS18 [get_ports {HD_GPIO_1}];
#set_property PACKAGE_PIN F7   [get_ports {HD_GPIO_2}];  # "F7.HD_GPIO_2"
#set_property IOSTANDARD LVCMOS18 [get_ports {HD_GPIO_2}];
#set_property PACKAGE_PIN G7   [get_ports {HD_GPIO_3}];  # "G7.HD_GPIO_3"
#set_property IOSTANDARD LVCMOS18 [get_ports {HD_GPIO_3}];
#set_property PACKAGE_PIN F6   [get_ports {HD_GPIO_4}];  # "F6.HD_GPIO_4"
#set_property IOSTANDARD LVCMOS18 [get_ports {HD_GPIO_4}];
#set_property PACKAGE_PIN G5   [get_ports {HD_GPIO_5}];  # "G5.HD_GPIO_5"
#set_property IOSTANDARD LVCMOS18 [get_ports {HD_GPIO_5}];
set_property PACKAGE_PIN A6   [get_ports {reset_port_0_n}];  # "A6.HD_GPIO_6"
set_property IOSTANDARD LVCMOS18 [get_ports {reset_port_0_n}];
set_property PACKAGE_PIN A7   [get_ports {reset_port_2_n}];  # "A7.HD_GPIO_7"
set_property IOSTANDARD LVCMOS18 [get_ports {reset_port_2_n}];
set_property PACKAGE_PIN G6   [get_ports {mdio_mdio_io}];  # "G6.HD_GPIO_8"
set_property IOSTANDARD LVCMOS18 [get_ports {mdio_mdio_io}];
#set_property PACKAGE_PIN E6   [get_ports {HD_GPIO_9}];  # "E6.HD_GPIO_9"
#set_property IOSTANDARD LVCMOS18 [get_ports {HD_GPIO_9}];
#set_property PACKAGE_PIN E5   [get_ports {HD_GPIO_10}];  # "E5.HD_GPIO_10"
#set_property IOSTANDARD LVCMOS18 [get_ports {HD_GPIO_10}];
#set_property PACKAGE_PIN D6   [get_ports {HD_GPIO_11}];  # "D6.HD_GPIO_11"
#set_property IOSTANDARD LVCMOS18 [get_ports {HD_GPIO_11}];
#set_property PACKAGE_PIN D5   [get_ports {HD_GPIO_12}];  # "D5.HD_GPIO_12"
#set_property IOSTANDARD LVCMOS18 [get_ports {HD_GPIO_12}];
set_property PACKAGE_PIN C7   [get_ports {reset_port_1_n}];  # "C7.HD_GPIO_13"
set_property IOSTANDARD LVCMOS18 [get_ports {reset_port_1_n}];
set_property PACKAGE_PIN B6   [get_ports {reset_port_3_n}];  # "B6.HD_GPIO_14"
set_property IOSTANDARD LVCMOS18 [get_ports {reset_port_3_n}];
set_property PACKAGE_PIN C5   [get_ports {mdio_mdc}];  # "C5.HD_GPIO_15"
set_property IOSTANDARD LVCMOS18 [get_ports {mdio_mdc}];

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets ultra96_qgige_i/eth_pcs_pma_0_1/inst/clock_reset_i/iclkbuf/O]

set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets ultra96_qgige_i/util_ds_buf_1/U0/BUFG_O[0]]

# DQS_BIAS is to be set to TRUE if internal DC biasing is used - this is recommended. 
# If the signal is biased externally on the board, should be set to FALSE
set_property DQS_BIAS TRUE [get_ports sgmii_port_0_rxp]
set_property DQS_BIAS TRUE [get_ports sgmii_port_0_rxn]
set_property DQS_BIAS TRUE [get_ports sgmii_port_1_rxp]
set_property DQS_BIAS TRUE [get_ports sgmii_port_1_rxn]
set_property DQS_BIAS TRUE [get_ports sgmii_port_2_rxp]
set_property DQS_BIAS TRUE [get_ports sgmii_port_2_rxn]
set_property DQS_BIAS TRUE [get_ports sgmii_port_3_rx_rxp]
set_property DQS_BIAS TRUE [get_ports sgmii_port_3_rx_rxn]


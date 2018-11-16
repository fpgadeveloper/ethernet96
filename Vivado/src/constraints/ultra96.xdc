#
#     IO standard for Bank 26 Vcco supply is fixed at 1.8V
#     IO standard for Bank 65 Vcco supply is fixed at 1.2V
# 
 
# ----------------------------------------------------------------------------
# High-speed expansion connector
# ---------------------------------------------------------------------------- 
# Bank 65
#set_property PACKAGE_PIN P1   [get_ports {ref_clk_port_0_clk_n}];  # "P1.CSI0_C_N" Clock capable QBC
#set_property IOSTANDARD LVDS [get_ports {ref_clk_port_0_clk_n}];
#set_property PACKAGE_PIN N2   [get_ports {ref_clk_port_0_clk_p}];  # "N2.CSI0_C_P" Clock capable QBC
#set_property IOSTANDARD LVDS [get_ports {ref_clk_port_0_clk_p}];
set_property PACKAGE_PIN P1   [get_ports {sgmii_port_0_rxn}];  # "P1.CSI0_C_N" Clock capable QBC
set_property IOSTANDARD LVDS [get_ports {sgmii_port_0_rxn}];
set_property PACKAGE_PIN N2   [get_ports {sgmii_port_0_rxp}];  # "N2.CSI0_C_P" Clock capable QBC
set_property IOSTANDARD LVDS [get_ports {sgmii_port_0_rxp}];
#set_property PACKAGE_PIN N4   [get_ports {sgmii_port_0_rxn}];  # "N4.CSI0_D0_N"
#set_property IOSTANDARD LVDS [get_ports {sgmii_port_0_rxn}];
#set_property PACKAGE_PIN N5   [get_ports {sgmii_port_0_rxp}];  # "N5.CSI0_D0_P"
#set_property IOSTANDARD LVDS [get_ports {sgmii_port_0_rxp}];
#set_property PACKAGE_PIN M1   [get_ports {sgmii_port_0_txn}];  # "M1.CSI0_D1_N"
#set_property IOSTANDARD LVDS [get_ports {sgmii_port_0_txn}];
#set_property PACKAGE_PIN M2   [get_ports {sgmii_port_0_txp}];  # "M2.CSI0_D1_P"
#set_property IOSTANDARD LVDS [get_ports {sgmii_port_0_txp}];
set_property PACKAGE_PIN M4   [get_ports {sgmii_port_0_txn}];  # "M4.CSI0_D2_N" Clock capable QBC
set_property IOSTANDARD LVDS [get_ports {sgmii_port_0_txn}];
set_property PACKAGE_PIN M5   [get_ports {sgmii_port_0_txp}];  # "M5.CSI0_D2_P" Clock capable QBC
set_property IOSTANDARD LVDS [get_ports {sgmii_port_0_txp}];
set_property PACKAGE_PIN L1   [get_ports {ref_clk_port_0_clk_n}];  # "L1.CSI0_D3_N" Global clock capable
set_property IOSTANDARD LVDS [get_ports {ref_clk_port_0_clk_n}];
set_property PACKAGE_PIN L2   [get_ports {ref_clk_port_0_clk_p}];  # "L2.CSI0_D3_P" Global clock capable
set_property IOSTANDARD LVDS [get_ports {ref_clk_port_0_clk_p}];
#set_property PACKAGE_PIN T2   [get_ports {CSI1_C_N                }];  # "T2.CSI1_C_N" Clock capable DBC
#set_property PACKAGE_PIN T3   [get_ports {CSI1_C_P                }];  # "T3.CSI1_C_P" Clock capable DBC
#set_property PACKAGE_PIN R3   [get_ports {CSI1_D0_N               }];  # "R3.CSI1_D0_N"
#set_property PACKAGE_PIN P3   [get_ports {CSI1_D0_P               }];  # "P3.CSI1_D0_P"
#set_property PACKAGE_PIN U1   [get_ports {CSI1_D1_N               }];  # "U1.CSI1_D1_N"
#set_property PACKAGE_PIN U2   [get_ports {CSI1_D1_P               }];  # "U2.CSI1_D1_P"
#set_property PACKAGE_PIN H5   [get_ports {DSI_CLK_N               }];  # "H5.DSI_CLK_N" Clock capable QBC
#set_property PACKAGE_PIN J5   [get_ports {DSI_CLK_P               }];  # "J5.DSI_CLK_P" Clock capable QBC
set_property PACKAGE_PIN F1   [get_ports {sgmii_port_1_txn}];  # "F1.DSI_D0_N" Clock capable DBC
set_property IOSTANDARD LVDS [get_ports {sgmii_port_1_txn}];
set_property PACKAGE_PIN G1   [get_ports {sgmii_port_1_txp}];  # "G1.DSI_D0_P" Clock capable DBC
set_property IOSTANDARD LVDS [get_ports {sgmii_port_1_txp}];
#set_property PACKAGE_PIN E3   [get_ports {sgmii_port_1_txn}];  # "E3.DSI_D1_N"
#set_property IOSTANDARD LVDS [get_ports {sgmii_port_1_txn}];
#set_property PACKAGE_PIN E4   [get_ports {sgmii_port_1_txp}];  # "E4.DSI_D1_P"
#set_property IOSTANDARD LVDS [get_ports {sgmii_port_1_txp}];
#set_property PACKAGE_PIN D1   [get_ports {sgmii_port_0_txn}];  # "D1.DSI_D2_N"
#set_property IOSTANDARD LVDS [get_ports {sgmii_port_0_txn}];
#set_property PACKAGE_PIN E1   [get_ports {sgmii_port_0_txp}];  # "E1.DSI_D2_P"
#set_property IOSTANDARD LVDS [get_ports {sgmii_port_0_txp}];
set_property PACKAGE_PIN C3   [get_ports {sgmii_port_1_rxn}];  # "C3.DSI_D3_N" Clock capable DBC
set_property IOSTANDARD LVDS [get_ports {sgmii_port_1_rxn}];
set_property PACKAGE_PIN D3   [get_ports {sgmii_port_1_rxp}];  # "D3.DSI_D3_P" Clock capable DBC
set_property IOSTANDARD LVDS [get_ports {sgmii_port_1_rxp}];
#set_property PACKAGE_PIN C2   [get_ports {HSIC_DATA               }];  # "C2.HSIC_DATA"
## Bank 66
#set_property PACKAGE_PIN A2   [get_ports {HSIC_STR                }];  # "A2.HSIC_STR"
## Bank 26
#set_property PACKAGE_PIN E8   [get_ports {CSI0_MCLK               }];  # "E8.CSI0_MCLK"
#set_property PACKAGE_PIN D8   [get_ports {CSI1_MCLK               }];  # "D8.CSI1_MCLK"

# ----------------------------------------------------------------------------
# Low-speed expansion connector
# ---------------------------------------------------------------------------- 
# Bank 23
set_property PACKAGE_PIN D7   [get_ports {mdio_port_0_mdc}];  # "D7.HD_GPIO_0"
set_property IOSTANDARD LVCMOS18 [get_ports {mdio_port_0_mdc}];
set_property PACKAGE_PIN F8   [get_ports {mdio_port_0_mdio_io}];  # "F8.HD_GPIO_1"
set_property IOSTANDARD LVCMOS18 [get_ports {mdio_port_0_mdio_io}];
set_property PACKAGE_PIN F7   [get_ports {mdio_port_1_mdc}];  # "F7.HD_GPIO_2"
set_property IOSTANDARD LVCMOS18 [get_ports {mdio_port_1_mdc}];
set_property PACKAGE_PIN G7   [get_ports {mdio_port_1_mdio_io}];  # "G7.HD_GPIO_3"
set_property IOSTANDARD LVCMOS18 [get_ports {mdio_port_1_mdio_io}];
#set_property PACKAGE_PIN F6   [get_ports {HD_GPIO_4               }];  # "F6.HD_GPIO_4"
#set_property PACKAGE_PIN G5   [get_ports {HD_GPIO_5               }];  # "G5.HD_GPIO_5"
#set_property PACKAGE_PIN A6   [get_ports {HD_GPIO_6               }];  # "A6.HD_GPIO_6"
#set_property PACKAGE_PIN A7   [get_ports {HD_GPIO_7               }];  # "A7.HD_GPIO_7"
#set_property PACKAGE_PIN G6   [get_ports {HD_GPIO_8               }];  # "G6.HD_GPIO_8"
#set_property PACKAGE_PIN E6   [get_ports {HD_GPIO_9               }];  # "E6.HD_GPIO_9"
#set_property PACKAGE_PIN E5   [get_ports {HD_GPIO_10              }];  # "E5.HD_GPIO_10"
#set_property PACKAGE_PIN D6   [get_ports {HD_GPIO_11              }];  # "D6.HD_GPIO_11"
#set_property PACKAGE_PIN D5   [get_ports {HD_GPIO_12              }];  # "D5.HD_GPIO_12"
#set_property PACKAGE_PIN C7   [get_ports {HD_GPIO_13              }];  # "C7.HD_GPIO_13"
#set_property PACKAGE_PIN B6   [get_ports {HD_GPIO_14              }];  # "B6.HD_GPIO_14"
#set_property PACKAGE_PIN C5   [get_ports {HD_GPIO_15              }];  # "C5.HD_GPIO_15"


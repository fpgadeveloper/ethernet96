Pin Configuration
=================

The 96B Quad Ethernet Mezzanine has both the low-speed and high-speed expansion
connectors as defined by the 96Boards Consumer Edition specification. The following
tables define the pinout of those connectors for this mezzanine card.

Low-speed expansion header
--------------------------

The low-speed expansion header connects the main power supply (SYS_DCIN) to the mezzanine 
card and it also provides I/Os that are used for the MDIO bus, the PHY resets and the 
"power good" signals from the mezzanine card's switching regulators.

Only 9 I/O pins of the low-speed expansion header are used by the 96B Quad Ethernet
Mezzanine card. The others are directly passed through to the expansion socket on the top
side of the board which can be used for stacking a second mezzanine card. See the following
section for the pinout of the low-speed expansion socket.

The mezzanine card does not draw power from the +5V pin (37). This pin is directly passed
through to the expansion socket on the top side of the board.

The mezzanine card does not draw power from the 1.8V supply pin (35), but it does use this 
pin to detect power-up of the carrier board. To supply +1.8V power to the Ethernet PHYs, the
mezzanine card generates it's own +1.8VDC supply using an on-board switching regulator that is
powered by SYS_DCIN (the main supply). The +1.8VDC that is generated on the mezzanine card is
also passed through to the top-side expansion socket to provide power to a stacked 
mezzanine if required.

+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| | 96Boards  |        |                                | | 96Boards   |        |                                |
| | pin name  | Pin    | Description                    | | pin name   | Pin    | Description                    |
+=============+========+================================+==============+========+================================+
| GND         |  1     |  Ground                        | GND          |  2     | Ground                         |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| UART0_CTS   |  3     |  Passed through                | PWR_BTN_N    |  4     | Passed through                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| UART0_TXD   |  5     |  Passed through                | RST_BTN_N    |  6     | Passed through                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| UART0_RXD   |  7     |  Passed through                | SPI0_SCL     |  8     | Passed through                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| UART0_RTS   |  9     |  Passed through                | SPI0_DIN     |  10    | Passed through                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| UART1_TXD   |  11    |  Passed through                | SPI0_CS      |  12    | Passed through                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| UART1_RXD   |  13    |  Passed through                | SPI0_DOUT    |  14    | Passed through                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| I2C0_SCL    |  15    |  Passed through                | PCM_FS       |  16    | Passed through                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| I2C0_SDA    |  17    |  Passed through                | PCM_CLK      |  18    | Passed through                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| I2C1_SCL    |  19    |  Passed through                | PCM_DO       |  20    | Passed through                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| I2C1_SDA    |  21    |  Passed through                | PCM_DI       |  22    | Passed through                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| GPIO-A      |  23    |  Passed through                | GPIO-B       |  24    | Passed through                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| GPIO-C      |  25    |  Passed through                | GPIO-D       |  26    | | POWER GOOD 1.0V              |
|             |        |                                |              |        | | (1.8V logic)                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| GPIO-E      |  27    |  | POWER GOOD 2.5V             | GPIO-F       |  28    | | POWER GOOD 1.8V              |
|             |        |  | (1.8V logic)                |              |        | | (1.8V logic)                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| GPIO-G      |  29    |  | Port 0 PHY reset            | GPIO-H       |  30    | | Port 1 PHY reset             |
|             |        |  | (active low)                |              |        | | (active low)                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| GPIO-I      |  31    |  | Port 2 PHY reset            | GPIO-J       |  32    | | Port 3 PHY reset             |
|             |        |  | (active low)                |              |        | | (active low)                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| GPIO-K      |  33    |  MDIO data signal              | GPIO-L       |  34    | MDC clock signal               |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| +1V8        |  35    |  | +1.8V supply                | SYS_DCIN     |  36    | Main power supply              |
|             |        |  | from dev platform           |              |        |                                |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| +5V         |  37    |  | +5.0V supply                | SYS_DCIN     |  38    | Main power supply              |
|             |        |  | from dev platform           |              |        |                                |
|             |        |  | Passed through              |              |        |                                |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| GND         |  39    |  Ground                        | GND          |  40    | Ground                         |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+


Low-speed expansion socket
--------------------------

The low-speed expansion socket is on the top-side of the mezzanine card and can be used for stacking 
a second mezzanine card. It provides access to all of the I/O that the 96B Quad Ethernet mezzanine does
not use, and all of the power supplies.

In the table below, all of the pins with the description "Passed through" can be used by the stacked
mezzanine card. The specific usage of the pins will depend on the development platform being used.

.. NOTE:: The +1.8V power supply pin (35) is connected to the +1.8V that is generated by a switching 
          regulator on the 96B Quad Ethernet Mezzanine, it is not passed through from the development platform. 
          This allows the stacked mezzanine to draw 100mA or more from the supply.

+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| | 96Boards  |        |                                | | 96Boards   |        |                                |
| | pin name  | Pin    | Description                    | | pin name   | Pin    | Description                    |
+=============+========+================================+==============+========+================================+
| GND         |  1     |  Ground                        | GND          |  2     | Ground                         |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| UART0_CTS   |  3     |  Passed through                | PWR_BTN_N    |  4     | Passed through                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| UART0_TXD   |  5     |  Passed through                | RST_BTN_N    |  6     | Passed through                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| UART0_RXD   |  7     |  Passed through                | SPI0_SCL     |  8     | Passed through                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| UART0_RTS   |  9     |  Passed through                | SPI0_DIN     |  10    | Passed through                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| UART1_TXD   |  11    |  Passed through                | SPI0_CS      |  12    | Passed through                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| UART1_RXD   |  13    |  Passed through                | SPI0_DOUT    |  14    | Passed through                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| I2C0_SCL    |  15    |  Passed through                | PCM_FS       |  16    | Passed through                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| I2C0_SDA    |  17    |  Passed through                | PCM_CLK      |  18    | Passed through                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| I2C1_SCL    |  19    |  Passed through                | PCM_DO       |  20    | Passed through                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| I2C1_SDA    |  21    |  Passed through                | PCM_DI       |  22    | Passed through                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| GPIO-A      |  23    |  Passed through                | GPIO-B       |  24    | Passed through                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| GPIO-C      |  25    |  Passed through                | GPIO-D       |  26    | Not connected                  |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| GPIO-E      |  27    |  Not connected                 | GPIO-F       |  28    | Not connected                  |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| GPIO-G      |  29    |  Not connected                 | GPIO-H       |  30    | Not connected                  |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| GPIO-I      |  31    |  Not connected                 | GPIO-J       |  32    | Not connected                  |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| GPIO-K      |  33    |  Not connected                 | GPIO-L       |  34    | Not connected                  |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| +1V8        |  35    |  | +1.8V supply from           | SYS_DCIN     |  36    | Main power supply              |
|             |        |  | 96B Eth mezzanine           |              |        | Passed through                 |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| +5V         |  37    |  | +5.0V supply                | SYS_DCIN     |  38    | Main power supply              |
|             |        |  | from dev platform           |              |        | Passed through                 |
|             |        |  | Passed through              |              |        |                                |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+
| GND         |  39    |  Ground                        | GND          |  40    | Ground                         |
+-------------+--------+--------------------------------+--------------+--------+--------------------------------+


High-speed expansion connector
------------------------------

The high-speed expansion connector routes the SGMII input (Soc-to-PHY) and output (PHY-to-SoC) signals to the development
platform. It also routes the SGMII 625MHz clock (input to SoC), which is generated by the PHY connected to port 3, and is
typically used by the SGMII receiver.

Also routed through the high-speed connector are 2 configurable outputs of the DP83867 PHYs called "GPIO0" and "GPIO1". 
These can be used for start-of-packet detection, loss of sync detection, and receive error detection among other things.
Please refer to the datasheet of the `DP83867 <http://www.ti.com/product/DP83867CS>`_ for more detailed information on 
these pins and their function.

+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| | 96Boards        | Pin   | Description                 | | 96Boards        | Pin  | Description                 |
| | pin name        |       |                             | | pin name        |      |                             |
+===================+=======+=============================+===================+======+=============================+
| SD_DAT0/SPI1_DOUT |  1    |  Not used                   |  CSI0_C+          | 2    |  Port 0 SGMII output data+  |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| SD_DAT1           |  3    |  Not used                   |  CSI0_C-          | 4    |  Port 0 SGMII output data-  |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| SD_DAT2           |  5    |  Not used                   |  GND              | 6    |  Ground                     |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| SD_DAT3/SPI1_CS   |  7    |  Not used                   |  CSI0_D0+         | 8    |  Port 1 SGMII output data+  |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| SD_SCLK/SPI1_SCLK |  9    |  Not used                   |  CSI0_D0-         | 10   |  Port 1 SGMII output data-  |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| SD_CMD/SPI1_DIN   |  11   |  Not used                   |  GND              | 12   |  Ground                     |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| GND               |  13   |  Ground                     |  CSI0_D1+         | 14   |  Port 1 GPIO1 (1.2V output) |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| CLK0/CSI0_MCLK    |  15   |  Not used                   |  CSI0_D1-         | 16   |  Port 1 GPIO0 (1.2V output) |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| CLK1/CSI1_MCLK    |  17   |  Not used                   |  GND              | 18   |  Ground                     |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| GND               |  19   |  Ground                     |  CSI0_D2+         | 20   |  Port 0 SGMII input data+   |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| DSI_CLK+          |  21   |  Port 3 SGMII input data+   |  CSI0_D2-         | 22   |  Port 0 SGMII input data-   |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| DSI_CLK-          |  23   |  Port 3 SGMII input data-   |  GND              | 24   |  Ground                     |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| GND               |  25   |  Ground                     |  CSI0_D3+         | 26   |  Port 1 SGMII input data+   |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| DSI_D0+           |  27   |  Port 2 SGMII output data+  |  CSI0_D3-         | 28   |  Port 1 SGMII input data-   |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| DSI_D0-           |  29   |  Port 2 SGMII output data-  |  GND              | 30   |  Ground                     |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| GND               |  31   |  Ground                     |  I2C2_SCL         | 32   |  Not used                   |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| DSI_D1+           |  33   |  Port 0 GPIO1 (1.2V output) |  I2C2_SDA         | 34   |  Not used                   |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| DSI_D1-           |  35   |  Port 0 GPIO0 (1.2V output) |  I2C3_SCL         | 36   |  Not used                   |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| GND               |  37   |  Ground                     |  I2C3_SDA         | 38   |  Not used                   |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| DSI_D2+           |  39   |  Port 3 GPIO0 (1.2V output) |  GND              | 40   |  Ground                     |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| DSI_D2-           |  41   |  Port 3 GPIO1 (1.2V output) |  CSI1_D0+         | 42   |  SGMII 625MHz clock+        |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| GND               |  43   |  Ground                     |  CSI1_D0-         | 44   |  SGMII 625MHz clock-        |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| DSI_D3+           |  45   |  Port 2 SGMII input data+   |  GND              | 46   |  Ground                     |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| DSI_D3-           |  47   |  Port 2 SGMII input data-   |  CSI1_D1+         | 48   |  Port 2 GPIO1 (1.2V output) |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| GND               |  49   |  Ground                     |  CSI1_D1-         | 50   |  Port 2 GPIO0 (1.2V output) |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| USB_D+            |  51   |  Not used                   |  GND              | 52   |  Ground                     |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| USB_D-            |  53   |  Not used                   |  CSI1_C+          | 54   |  Port 3 SGMII output data+  |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| GND               |  55   |  Ground                     |  CSI1_C-          | 56   |  Port 3 SGMII output data-  |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| HSIC_STR          |  57   |  Not used                   |  GND              | 58   |  Ground                     |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+
| HSIC_DATA         |  59   |  Not used                   |  RESERVED         | 60   |  Not used                   |
+-------------------+-------+-----------------------------+-------------------+------+-----------------------------+


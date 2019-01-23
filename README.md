# Ultra96 Ethernet

This project is still under development.

![96B Quad Ethernet Mezzanine](https://opsero.com/wp-content/uploads/2019/01/96b-quad-ethernet-mezzanine-med-3.jpg "96B Quad Ethernet Mezzanine")

## Requirements

This project is designed for Vivado 2018.2. If you are using an older version of Vivado, then you *MUST* use an older version
of this repository. Refer to the [list of commits](https://github.com/fpgadeveloper/ultra96-ethernet/commits/master "list of commits")
to find links to the older versions of this repository.

* Vivado 2018.2
* 96B Quad Ethernet Mezzanine](expected availability: April 2019)
* [Ultra96](http://zedboard.org/product/ultra96 "Ultra96")
* For designs containing AXI Ethernet Subsystem IP: [Xilinx Soft TEMAC license](http://ethernetfmc.com/getting-a-license-for-the-xilinx-tri-mode-ethernet-mac/ "Xilinx Soft TEMAC license")

## Description

This repo contains example designs for the Opsero 96B Quad Ethernet Mezzanine board when used with the 
Avnet [Ultra96](http://zedboard.org/product/ultra96 "Ultra96").

## Projects in this repo

These are the different projects in the repo at the moment.

* ultra96_axieth: Uses AXI Ethernet + SGMII core, 125MHz clock, no shared logic
* ultra96_ae625: Uses AXI Ethernet + SGMII core, 625MHz clock from port 3 PHY, shared logic in port 3 RX, uses 125MHz clock for AXI streaming interfaces and gtx_clk (no clock wiz)
* ultra96_qgige: Uses PS GEMs + SGMII core, 625MHz clock from port 3 PHY, shared logic in port 0-1, doesnt use 125MHz clock for anything
* ultra96_qg125: Uses PS GEMs + SGMII core, 125MHz clock, no shared logic

## Tested on hardware

These projects have been tested on hardware so far:

* ultra96_ae625: Port 0 has been tested on hardware with lwIP echo server
* ultra96_qgige: All 4 ports have been tested on hardware with lwIP echo server

## Build instructions

To use the sources in this repository, please follow these steps:

1. Download the repo as a zip file and extract the files to a directory
   on your hard drive --OR-- Git users: clone the repo to your hard drive
2. Open Windows Explorer, browse to the repo files on your hard drive.
3. In the Vivado directory, you will find multiple batch files (*.bat).
   Double click on the batch file of the example project that you would
   like to generate - this will generate a Vivado project.
4. Run Vivado and open the project that was just created.
5. Click Generate bitstream.
6. When the bitstream is successfully generated, select `File->Export->Export Hardware`.
   In the window that opens, tick "Include bitstream" and "Local to project".
   DO NOT `Launch SDK` yet.
7. Return to Windows Explorer and browse to the SDK directory in the repo.
8. Double click the `build-sdk.bat` batch file. The batch file will run the
   `build-sdk.tcl` script and build the SDK workspace containing the hardware
   design and the software application.
9. Run Xilinx SDK (DO NOT use the Launch SDK option from Vivado) and select the workspace to be the SDK directory of the repo.
10. Select `Project->Build automatically`.
11. Connect and power up the hardware.
12. Open a Putty terminal to view the UART output.
13. In the SDK, select `Xilinx Tools->Program FPGA`.
14. Right-click on the application and select `Run As->Launch on Hardware (System Debugger)`

The software application used to test these projects is the lwIP Echo Server example that is built into
Xilinx SDK. The application relies on the lwIP library (also built into Xilinx SDK) but with a few modifications.
The modified version of the lwIP library is contained in the `EmbeddedSw` directory, which is added as a
local SDK repository to the SDK workspace. See the readme in the SDK directory for more information.

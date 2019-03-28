# Ultra96 Ethernet

![96B Quad Ethernet Mezzanine](https://opsero.com/wp-content/uploads/2019/01/96b-quad-ethernet-mezzanine-med-3.jpg "96B Quad Ethernet Mezzanine")

## Requirements

This project is designed for Vivado 2018.2. If you are using an older version of Vivado, then you *MUST* use an older version
of this repository. Refer to the [list of commits](https://github.com/fpgadeveloper/ultra96-ethernet/commits/master "list of commits")
to find links to the older versions of this repository.

* Vivado 2018.2
* 96B Quad Ethernet Mezzanine (expected availability: April 2019)
* [Ultra96](http://zedboard.org/product/ultra96 "Ultra96")
* For designs containing AXI Ethernet Subsystem IP: [Xilinx Soft TEMAC license](http://ethernetfmc.com/getting-a-license-for-the-xilinx-tri-mode-ethernet-mac/ "Xilinx Soft TEMAC license")
* [Ultra96 board files](https://github.com/Avnet/bdf "Ultra96 board files") (see install instructions below)

## Description

This repo contains example designs for the Opsero 96B Quad Ethernet Mezzanine board when used with the 
Avnet [Ultra96](http://zedboard.org/product/ultra96 "Ultra96").

## Projects in this repo

These are the different projects in the repo at the moment.

* AXI Ethernet (axi-eth):
  * Uses soft AXI Ethernet IP to implement the MAC
  * Uses PCS/PMA or SGMII IP to implement the SGMII over LVDS links
  * Uses 625MHz clock from port 3 PHY, shared logic in SGMII core for port 3 RX
  * All 4 ports have been tested on hardware with lwIP echo server
* PS GEM (ps-gem):
  * Uses PS integrated Gigabit Ethernet MACs (GEM)
  * Uses PCS/PMA or SGMII IP to implement the SGMII over LVDS links
  * Uses 625MHz clock from port 3 PHY, shared logic in SGMII core for ports 0 and 1
  * All 4 ports have been tested on hardware with lwIP echo server and PetaLinux

## Build instructions

### Install Ultra96 board definition files

To use these projects, you must first install the board definition files for the Ultra96 into your Vivado installation.
The Ultra96 board definition files are hosted on Avnet's Github repo:

https://github.com/Avnet/bdf

Clone or download that repo, then copy the `ultra96v1` and `ultra96v2` directories from it to the 
`<path-to-xilinx-vivado>/data/boards/board_files` directory on your machine.

### AXI Ethernet evaluation license

If you intend to build the AXI Ethernet based design, you will need to get an evaluation (or full)
license for the Tri-mode Ethernet MAC from Xilinx. You can find instructions for that here:
[Xilinx Soft TEMAC license](http://ethernetfmc.com/getting-a-license-for-the-xilinx-tri-mode-ethernet-mac/ "Xilinx Soft TEMAC license")

### Build the Vivado, SDK and PetaLinux projects

Once you have installed the board definition files, and you have installed the required licenses, then
you can use the sources in this repository to build the Vivado, SDK and PetaLinux projects. Start by cloning the repo 
or download it as a zip file and extract the files to your hard drive, then follow these steps depending on your OS:

#### Windows users

1. Open Windows Explorer, browse to the repo files on your hard drive.
2. In the Vivado directory, you will find multiple batch files (*.bat).
   Double click on the batch file of the example project that you would
   like to generate - this will generate a Vivado project.
3. Run Vivado and open the project that was just created.
4. Click Generate bitstream.
5. When the bitstream is successfully generated, select `File->Export->Export Hardware`.
   In the window that opens, tick "Include bitstream" and "Local to project".
   DO NOT `Launch SDK`.
6. Return to Windows Explorer and browse to the SDK directory in the repo.
7. Double click the `build-sdk.bat` batch file. The batch file will run the
   `build-sdk.tcl` script and build the SDK workspace containing the hardware
   design and the software application. Please refer to the `README.md` file in the SDK
   subdirectory for instructions on running the software application on hardware.
8. If you are interested in building PetaLinux, you will need to use a Linux machine
   from this point. Please refer to the `README.md` file in the PetaLinux subdirectory
   for instructions on building PetaLinux.

#### Linux users

1. Launch the Vivado GUI.
2. On the welcome page, there is a Tcl console. In the Tcl console, `cd` to the repo files on your hard drive
   and into the Vivado subdirectory. For example: `cd /media/projects/ultra96-ethernet/Vivado`.
3. In the Vivado subdirectory, you will find multiple Tcl files. To list them, type `exec ls {*}[glob *.tcl]`.
   Determine the Tcl script for the example project that you would
   like to generate (for example: `build-ps-gem.tcl`), then `source` the script in the Tcl console:
   For example: `source build-ps-gem.tcl`
4. Vivado will run the script and generate the project. When it's finished, click Generate bitstream.
5. When the bitstream is successfully generated, select `File->Export->Export Hardware`.
   In the window that opens, tick "Include bitstream" and "Local to project".
   DO NOT `Launch SDK`.
6. To build the SDK workspace, open a Linux command terminal and `cd` to the SDK directory in the repo.
7. The SDK directory contains the `build-sdk.tcl` script that will build the SDK workspace containing the hardware
   design and the software application. Run the build script by typing the following command:
   `<path-of-xilinx-sdk>/bin/xsdk -batch -source build-sdk.tcl`
   Note that you must replace `<path-of-xilinx-sdk>` with the actual path to your Xilinx SDK installation.
8. Please refer to the `README.md` file in the SDK subdirectory for instructions on running the software 
   application on hardware.
9. To build the PetaLinux project, first launch PetaLinux by sourcing the `settings.sh` bash script, 
   eg: `source <path-to-installed-petalinux>/settings.sh`.
10. Now `cd` to the PetaLinux directory in the repo and run the `build-petalinux` 
   script. You may have to add execute permission to the script first using `chmod +x build-petalinux`,
   then run it by typing `./build-petalinux`. Please refer to the `README.md` file in the PetaLinux subdirectory
   for more information on the PetaLinux projects.

### lwIP modifications

The software application used to test these projects is the lwIP Echo Server example that is built into
Xilinx SDK. The application relies on the lwIP library (also built into Xilinx SDK) but with a few modifications.
The modified version of the lwIP library is contained in the `EmbeddedSw` directory, which is added as a
local SDK repository to the SDK workspace. See the `README.md` in the SDK directory for more information.

===============
Getting Started
===============

Example Designs
===============

The example designs for the 96B Quad Ethernet Mezzanine are hosted on Github and
are designed for the Avnet Ultra96 development platform. There are currently two 
examples and they are differentiated by the type of Ethernet MACs used and their 
location in the system.

AXI Ethernet based example
--------------------------

This example design is based on Xilinx's soft (ie. FPGA implemented) MAC,
the AXI Ethernet Subsystem IP, that can be found in the Vivado IP Catalog.
As the MAC is implemented in the FPGA fabric, this example is ideal for 
applications that require some packet processing to be performed in the FPGA.

PS GEM based example
--------------------

This example design utilizes the 4x Gigabit Ethernet MACs (GEMs) that are embedded
into the Processing System (PS) of the Zynq Ultrascale+™ device of the Ultra96.
The MACs in this example design do not use up any of the FPGA fabric, which
makes it ideal for applications that need to use the FPGA for other purposes.

Requirements
============

In order to use the example designs, you will need the following:

* Windows or Linux PC
* Xilinx Vivado
* Xilinx SDK
* 1x Ultra96 development platform
* 1x 96B Quad Ethernet Mezzanine

If you want to build PetaLinux for the example designs, you will also need:

* Linux PC or a virtual Linux machine
* PetaLinux SDK

You will also need a CAT-5e Ethernet cable and a link partner, such as a PC with an Ethernet port 
or a network router.

Additionally, you may need to install the Ultra96 board definition files to your Vivado 
installation, and obtain an AXI Ethernet evaluation license if you intend to use that design.

Install Ultra96 board definition files
--------------------------------------

To use the example projects, you must first install the board definition files for the Ultra96 into your Vivado installation.
The Ultra96 board definition files are hosted on `Avnet's Github repo <https://github.com/Avnet/bdf>`_.

Clone or download that repo, then copy the `ultra96v1` and `ultra96v2` directories from it to the 
`<path-to-xilinx-vivado>/data/boards/board_files` directory on your machine.

AXI Ethernet evaluation license
-------------------------------

If you intend to build the AXI Ethernet based design, you will need to get an evaluation (or full)
license for the Tri-mode Ethernet MAC from Xilinx. You can find instructions for that here:
`Xilinx Soft TEMAC license <http://ethernetfmc.com/getting-a-license-for-the-xilinx-tri-mode-ethernet-mac/>`_

Build instructions
==================

Download the source code
------------------------

The source code for both example designs can be found on our Github page:

`Ultra96 Ethernet Github page <https://github.com/fpgadeveloper/ultra96-ethernet>`_

The repository contains the following directories:

* **Vivado**: Contains the scripts to build the Vivado projects
* **SDK**: Contains a script to generate and build the standalone software applications
* **PetaLinux**: Contains a script and configuration files to build the PetaLinux projects
* **EmbeddedSw**: Contains modifications to the lwIP software library

Build the Vivado and SDK projects
---------------------------------

Once you have installed the board definition files, and you have installed the required licenses, then
you can use the sources in this repository to build the Vivado, SDK and PetaLinux projects. Start by cloning the repo 
or download it as a zip file and extract the files to your hard drive, then follow these steps depending on your OS:

Windows users
^^^^^^^^^^^^^

#. Open Windows Explorer, browse to the repo files on your hard drive.
#. In the Vivado directory, you will find multiple batch files (\*.bat).
   Double click on the batch file of the example project that you would
   like to generate - this will generate a Vivado project.
#. Run Vivado and open the project that was just created.
#. Click Generate bitstream.
#. When the bitstream is successfully generated, select `File->Export->Export Hardware`.
   In the window that opens, tick "Include bitstream" and "Local to project".
   DO NOT `Launch SDK`.
#. Return to Windows Explorer and browse to the SDK directory in the repo.
#. Double click the `build-sdk.bat` batch file. The batch file will run the
   `build-sdk.tcl` script and build the SDK workspace containing the hardware
   design and the software application. Please refer to the `README.md` file in the SDK
   subdirectory for instructions on running the software application on hardware.
#. If you are interested in building PetaLinux, you will need to use a Linux machine and
   follow the steps for Linux users below.

Linux users
^^^^^^^^^^^

#. Launch the Vivado GUI.
#. On the welcome page, there is a Tcl console. In the Tcl console, `cd` to the repo files on your hard drive
   and into the Vivado subdirectory. For example: `cd /media/projects/ultra96-ethernet/Vivado`.
#. In the Vivado subdirectory, you will find multiple Tcl files. To list them, type `exec ls {*}[glob *.tcl]`.
   Determine the Tcl script for the example project that you would
   like to generate (for example: `build-ps-gem.tcl`), then `source` the script in the Tcl console:
   For example: `source build-ps-gem.tcl`
#. Vivado will run the script and generate the project. When it's finished, click Generate bitstream.
#. When the bitstream is successfully generated, select `File->Export->Export Hardware`.
   In the window that opens, tick "Include bitstream" and "Local to project".
   DO NOT `Launch SDK`.
#. To build the SDK workspace, open a Linux command terminal and `cd` to the SDK directory in the repo.
#. The SDK directory contains the `build-sdk.tcl` script that will build the SDK workspace containing the hardware
   design and the software application. Run the build script by typing the following command:
   `<path-of-xilinx-sdk>/bin/xsdk -batch -source build-sdk.tcl`
   Note that you must replace `<path-of-xilinx-sdk>` with the actual path to your Xilinx SDK installation.
#. Please refer to the `README.md` file in the SDK subdirectory for instructions on running the software 
   application on hardware.
#. To build the PetaLinux project, follow the steps in the following section.

Build the PetaLinux projects
----------------------------

Once the Vivado project(s) have been built and exported to SDK, you can now build the PetaLinux project(s).
Note that the PetaLinux projects can only be built on a Linux machine (or virtual Linux machine).

Linux users
^^^^^^^^^^^

#. To build the PetaLinux project, first launch PetaLinux by sourcing the `settings.sh` bash script, 
   eg: `source <path-to-installed-petalinux>/settings.sh`.
#. Now `cd` to the PetaLinux directory in the repo and run the `build-petalinux` 
   script. You may have to add execute permission to the script first using `chmod +x build-petalinux`,
   then run it by typing `./build-petalinux`.


    
    
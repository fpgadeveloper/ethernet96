PetaLinux Project source files
==============================

### How to use the PetaLinux projects

#### Requirements

* Windows or Linux PC with Vivado installed
* Linux PC or virtual machine with PetaLinux installed

#### Build Instructions

The complete build instructions can be found in the 
[Build instructions](https://docs.ethernet96.com/en/latest/getting_started.html#launch-on-hardware "Build instructions") 
section of the Getting Started guide.

#### Launch PetaLinux on hardware

To launch PetaLinux on the hardware, please read the 
[Launch on hardware](https://docs.ethernet96.com/en/latest/getting_started.html#launch-on-hardware "Launch on hardware") 
instructions in the Getting Started guide.

#### Example port usage from Linux command line

For example Linux usage instructions, please refer to the 
[PetaLinux Example Usage](https://docs.ethernet96.com/en/latest/getting_started.html#petalinux-example-usage "PetaLinux Example Usage") 
section of the Getting Started guide.

### Status of the PetaLinux projects

#### PS GEM based design

* All ports working for the ps_gem design
* Port 0-2 will work at link speeds of 10Mbps, 100Mbps and 1000Mbps
* Port 3 will only work at a link speed of 1000Mbps. It's hard coded to work at 1000Mbps only but we're working on a 
fix for this so that the PCS/PMA or SGMII IP will be configured according to the actual negotiated link speed

#### AXI Ethernet based design

* Not yet tested for the axi_eth design (work still needs to be done)
* To do: Need to patch the AXI Ethernet driver to deal with multiple PHYs connected to a single MDIO bus

### How the script works

The PetaLinux directory contains a `build-petalinux` shell script which can be run in Linux to automatically
generate a PetaLinux project for each of the generated/exported Vivado projects in the Vivado directory.

When executed, the build script searches the Vivado directory for all projects containing `*.sdk` sub-directories.
This locates all projects that have been exported to SDK. Then for every exported project, the script
does the following:

1. Verifies that the `.hdf` and the `.bit` files exist.
2. Creates a PetaLinux project, referencing the exported hardware design (.hdf).
3. Copies the relevant configuration files from the `src` directory into the created
PetaLinux project.
4. Builds the PetaLinux project.
5. Generates a BOOT.bin and image.ub file.

For detailed information on the PetaLinux configuration files in the `src` directory, please read the 
[PetaLinux](hhttps://docs.ethernet96.com/en/latest/programming_guide.html#petalinux "PetaLinux") 
section in the Programming guide.

### To do

* U-Boot needs to be patched so that it works for a configuration of multiple PHYs
  on a single MDIO bus
* Need to be using the PCS/PMA or SGMII core's TX and RX locked signals to ensure
  that the 625MHz clock has been properly enabled
  

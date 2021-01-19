# 96B Quad Ethernet Mezzanine

## Description

This repo contains example designs for the Opsero 
[96B Quad Ethernet Mezzanine](https://docs.ethernet96.com "96B Quad Ethernet Mezzanine") board when used with the 
Avnet [Ultra96 v1 and v2](http://zedboard.org/product/ultra96 "Ultra96 v1 and v2").

![96B Quad Ethernet Mezzanine](https://opsero.com/wp-content/uploads/2019/01/96b-quad-ethernet-mezzanine-med-3.jpg "96B Quad Ethernet Mezzanine")

Important links:
* Datasheet and user guide for this project is hosted here: [96B Quad Ethernet Mezzanine documentation](https://docs.ethernet96.com "96B Quad Ethernet Mezzanine docs").
* To report a bug: [Report an issue](https://github.com/fpgadeveloper/ethernet96/issues "Report an issue").
* For technical support: [Contact Opsero](https://opsero.com/contact-us "Contact Opsero").
* To purchase the mezzanine card: [96B Quad Ethernet Mezzanine order page](https://opsero.com/product/96b-quad-ethernet-mezzanine "96B Quad Ethernet Mezzanine order page").

## Requirements

This project is designed for Vivado 2020.2. If you are using an older version of the 
Xilinx tools, then refer to the [release tags](https://github.com/fpgadeveloper/ethernet96/releases "releases")
to find the version of this repository that matches your version of the tools.

* Vivado 2020.2
* Vitis 2020.2 (for standalone lwIP echo server)
* PetaLinux Tools 2020.2
* [96B Quad Ethernet Mezzanine](https://opsero.com/product/96b-quad-ethernet-mezzanine "96B Quad Ethernet Mezzanine")
* [Ultra96 v1 or v2](https://www.96boards.org/product/ultra96/ "Ultra96")
* For designs containing AXI Ethernet Subsystem IP: [Xilinx Soft TEMAC license](http://ethernetfmc.com/getting-a-license-for-the-xilinx-tri-mode-ethernet-mac/ "Xilinx Soft TEMAC license")
* [Ultra96 board files](https://github.com/Avnet/bdf "Ultra96 board files") (see [install instructions](https://docs.ethernet96.com/en/latest/getting_started.html#install-ultra96-board-definition-files ""))

## Projects in this repo

These are the different projects in the repo at the moment.

* AXI Ethernet (axi-eth):
  * Uses soft AXI Ethernet IP to implement the MAC
  * Uses PCS/PMA or SGMII IP to implement the SGMII over LVDS links
  * Uses 625MHz clock from port 3 PHY, shared logic in SGMII core for port 3 RX
  * All 4 ports have been tested on hardware with lwIP echo server and PetaLinux
* PS GEM (ps-gem):
  * Uses PS integrated Gigabit Ethernet MACs (GEM)
  * Uses PCS/PMA or SGMII IP to implement the SGMII over LVDS links
  * Uses 625MHz clock from port 3 PHY, shared logic in SGMII core for ports 0 and 1
  * All 4 ports have been tested on hardware with lwIP echo server and PetaLinux

## Getting started

For build and usage instructions, please refer to the Getting Started section of the user guide:

[Getting started with the 96B Quad Ethernet Mezzanine](https://docs.ethernet96.com/en/latest/getting_started.html "Getting started")

## Technical support

For questions or technical support, please contact Opsero or report an issue on the Github repo:

* [Contact Opsero](https://opsero.com/contact-us "Contact Opsero")
* [Report an issue](https://github.com/fpgadeveloper/ethernet96/issues "Report an issue")

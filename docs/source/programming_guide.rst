=================
Programming Guide
=================

This programming guide is specific to users of the Avnet Ultra96 board. The purpose 
of the guide is to provide the user with the details of the programming requirements 
to enable them to operate the hardware and customise functionality.

Vivado design
=============

We recommend that all users start with our `example Vivado designs 
<https://github.com/fpgadeveloper/ethernet96>`_ when using the mezzanine
card with the Ultra96. For those who wish to better understand the example designs, or
develop their own Vivado designs, this section provides more detail on the critical
elements.

SGMII Implementation
--------------------

The 96B Quad Ethernet Mezzanine card was designed to conform with the `96Boards
specification for mezzanine cards <https://github.com/96boards/documentation/raw/master/mezzanine/files/mezzanine-design-guidelines.pdf>`_,
however the pinout of the high-speed expansion connector was chosen to maximize its
usability when paired with the Ultra96. This section provides an explanation of the pin
selection of the SGMII lanes and how to implement the SGMII interfaces in the Vivado design.

The Ultra96 high-speed expansion connector does not provide access to any gigabit 
transceivers of the Zynq Ultrascale+ device. For this reason, the SGMII interfaces
must be implemented using *SGMII over LVDS*. To implement SGMII over LVDS on the Zynq 
Ultrascale+, the appropriate IP core is the PCS/PMA or SGMII IP. This IP core has several 
requirements on the I/O pins with which it can be used. Two of the critical requirements are:

#. The I/O pair used for TX, and that used for RX must be in the same BYTE_GROUP
#. The I/O pair used for TX must be in the opposite nibble to that used for RX

For example, the TX and RX pairs of a single SGMII interface could be located in BYTE_GROUP
1, with the TX pair in the lower nibble and the RX pair in the upper nibble.

Given these requirements, the possible pin selections can be determined by looking at the
I/O pins that are available to us, and their respective BYTE_GROUPs and nibbles.
The high-speed expansion connector of the Ultra96 makes these I/O pins from bank 65
available for use:

+-------------+----------+-------------------------+
| BYTE_GROUP  | Nibble   |  Available bits (pairs) |
+=============+==========+=========================+
| 0           | Lower    |  0,1,2                  |
|             +----------+-------------------------+
|             | Upper    |  Not connected          |
+-------------+----------+-------------------------+
| 1           | Lower    |  0,1,2                  |
|             +----------+-------------------------+
|             | Upper    |  0,1                    |
+-------------+----------+-------------------------+
| 2           | Lower    |  Not connected          |
|             +----------+-------------------------+
|             | Upper    |  0                      |
+-------------+----------+-------------------------+
| 3           | Lower    |  0,1,2                  |
|             +----------+-------------------------+
|             | Upper    |  0                      |
+-------------+----------+-------------------------+

Considering the requirements of the SGMII IP and the choice of I/O pins on the high-speed 
expansion connector of the Ultra96, it is only possible to connect 3 SGMII interfaces:

* Interface 0: BYTE_GROUP 1, lower pair 0, upper pair 0
* Interface 1: BYTE_GROUP 1, lower pair 1, upper pair 1
* Interface 2: BYTE_GROUP 3, lower pair 0, upper pair 0

The 96B Quad Ethernet Mezzanine card has 4 SGMII interfaces. To connect the 4th interface
to the Ultra96, we in fact use two SGMII interfaces, where only one direction (TX/RX) of each 
interface is actually used. This allows us to satisfy the requirements of the SGMII IP with
the remaining pins that are available to us. Here is how the 4th interface is connected:

* Interface 3 RX: BYTE_GROUP 0, lower pair 0 (RX), upper pair 0 (N/C pins)
* Interface 3 TX: BYTE_GROUP 2, upper pair 0 (TX), lower pair 0 (N/C pins)

With this pin selection, the 4th interface requires two SGMII IPs to function - one
that handles the RX interface and another that handles the TX interface. The unused
TX and RX pins of the SGMII IP cores are assigned to pins that are not
externally connected. To connect the GMII interface between the MAC IP and the two
SGMII IP cores, we open the interfaces and connect only the RX GMII pins to the RX 
SGMII core, and the TX GMII pins to the TX SGMII core.

A single SGMII IP core implements all of the SGMII interfaces connected to a single 
BYTE_GROUP. As interfaces 0 and 1 are connected to BYTE_GROUP 1, they are implemented
by a single SGMII IP core. Interface 2 has its own SGMII IP core, as does interface 3's
RX lane and interface 3's TX lane.

.. NOTE:: It is possible to implement SGMII over LVDS using the AXI Ethernet Subsystem IP.
    However, at the time of this writing, the AXI Ethernet Subsystem IP can only implement a single
    SGMII over LVDS interface. For this reason, the IP cannot be used to implement both interface 0
    and interface 1. Instead, to use both interfaces 0 and 1 with AXI Ethernet Subsystem IP, 
    the SGMII over LVDS interface must be implemented with the PCS/PMA or SGMII IP core, and then
    connected to the AXI Ethernet Subsystem IP cores through internal GMII interfaces. See the 
    AXI Ethernet example design for the required connections.


MDIO bus
--------

The 96B Quad Ethernet Mezzanine card uses a single MDIO bus to connect the development
platform to the Ethernet PHYs. The Vivado design should only contain one MDIO interface
that connects to the external MDIO bus. Communication with all Ethernet PHYs must be
performed through this single bus.

The mezzanine card Ethernet PHYs for ports 0,1,2 and 3 have addresses 0x1, 0x2, 0xC and
0xF respectively. If your Vivado design uses IP cores that themselves have PHY addresses
(such as the PCS/PMA or SGMII IP), and connect to the same MDIO bus as that of the 
external PHYs, ensure that these IP cores have unique addresses with respect to the 
external PHYs.

If using the PCS/PMA or SGMII IP core, the MDIO interfaces of these cores can be chained
together such that the output of one connects to the input of another. Be sure to also
connect the tri-state signal (MDIO_T) from one core to the next, this is essential for
correct operation of the MDIO bus.


Constraints
-----------

For more information on the required constraints, please refer to the XDC files used by the
example designs, located in the 
`constraints directory of the Github repository <https://github.com/fpgadeveloper/ethernet96/tree/master/Vivado/src/constraints>`_.


PetaLinux
=========

This section provides the information required to build PetaLinux or other Linux distributions
for use with the 96B Quad Ethernet Mezzanine card.

Device tree for GEM design
--------------------------

The required additions to the device tree include:

* Create the ``mdio`` node (see multi-PHY patch below)

* Define the ``phy0`` to ``phy3`` nodes within the ``mdio`` node:

  * Define the PHY address
  * Set the TX and RX internal delay
  * Set the FIFO depth
  * Enable SGMII clock for PHY3 (see DP83867 patch below)
  * Disable SGMII auto-negotiation in PHY3 (see DP83867 patch below)
  
* Add these properties to the ``gem0`` to ``gem3`` nodes:

  * Set PHY handle (as defined in the ``mdio`` node)
  * Set PHY mode set to GMII
  * Set PHY reset to connected GPIO
  * Set PHY reset to active-low
  
For more detail, refer to the `device tree for the GEM design 
<https://github.com/fpgadeveloper/ethernet96/blob/master/PetaLinux/src/ports-0123/project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi>`_
in the Github repository.


Device tree for AXI Ethernet design
-----------------------------------

Please note that we are still working on PetaLinux for the AXI Ethernet design, so the device tree
may still require some modifications.

For more detail, refer to the `device tree for the AXI Ethernet design 
<https://github.com/fpgadeveloper/ethernet96/blob/master/PetaLinux/src/ports-0123-axieth/project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi>`_
in the Github repository.

Rootfs configuration
--------------------

In the rootfs configuration, we add the following packages:

* ethtool
* ethtool-dev
* ethtool-dbg
* git
* openamp-fw-echo-testd
* openamp-fw-mat-muld
* openamp-fw-rpc-demo
* packagegroup-petalinux
* packagegroup-petalinux-matchbox
* packagegroup-petalinux-openamp
* packagegroup-petalinux-self-hosted
* packagegroup-petalinux-v4lutils
* packagegroup-petalinux-x11
* libftdi
* cmake
* iperf3
* lmsensors-sensorsdetect
* packagegroup-base-extended
* packagegroup-petalinux-96boards-sensors
* packagegroup-petalinux-ultra96-webapp
* python-pyserial
* python3-pip
* ultra96-ap-setup

In PetaLinux SDK, the rootfs is configured using this command: ``petalinux-config -c rootfs``


Kernel configuration
--------------------

The following options must be set in the Kernel configuration:

* CONFIG_XILINX_DMA_ENGINES=y
* CONFIG_XILINX_DPDMA=y
* CONFIG_XILINX_ZYNQMP_DMA=y
* CONFIG_ETHERNET=y
* CONFIG_NET_VENDOR_XILINX=y
* CONFIG_XILINX_AXI_EMAC=y
* CONFIG_XILINX_PHY=y
* CONFIG_NET_CADENCE=y
* CONFIG_MACB=y
* CONFIG_NETDEVICES=y
* CONFIG_HAS_DMA=y
* CONFIG_CPU_IDLE=n

In PetaLinux SDK, the kernel is configured using this command: ``petalinux-config -c kernel``


DP83867 Ethernet PHY driver patch
---------------------------------

The PCS/PMA or SGMII cores in the Vivado designs rely on the 625MHz SGMII output clock 
of the PHY of port 3 (PHY address 0xF). The DS83867 PHY does not enable this clock output
by default, nor does the standard driver, so we need to modify the driver so that it can
be enabled. Also, SGMII autonegotiation is disabled in the PCS/PMA or SGMII core for port
3, therefore we need to modify the driver so that it can also disable SGMII autonegotiation
in the PHY.

To fix both of these issues, we patch the DP83867 driver to accept two extra properties
in the device tree:

* ``ti,dp83867-sgmii-autoneg-dis``: When added to the GEM node, this will disable the SGMII 
  autonegotiation feature when the PHY is configured (eg. ipconfig eth0 up)

* ``ti,dp83867-sgmii-clk-en``: When added to the GEM node, this will enable the 625MHz
  SGMII clock output of the PHY (ie. enable 3-wire mode)

Both of these properties should be included in the ``gem3`` node or the ``axi_ethernet_3`` node of 
the device tree (depending on the Vivado design being used).

The source code for this patch can be found in this path of the Github repo: 
``PetaLinux/src/common/project-spec/meta-user/recipes-kernel/linux/linux-xlnx``


MACB Multi-PHY patch
--------------------

This patch was developed by Xilinx and allows the MACB driver for ZynqMP GEM to work with 
multiple PHYs that are connected to a single MDIO bus. The 96B Quad Ethernet Mezzanine
uses such an architecture and so this patch is required by the GEM based Vivado design.

When using this patch, the PHYs and their addresses need to be defined in a node
of the device tree called ``mdio``. For an example of how to define the PHYs in the ``mdio``
node, please refer to the device tree of the GEM design, located in this path of the Github
repo: ``PetaLinux/src/ports-0123/project-spec/meta-user/recipes-bsp/device-tree/files``


ZynqMP FSBL hooks patch
-----------------------

This patch modifies the ZynqMP FSBL to add code to the `XFsbl_HookBeforeHandoff` which is
executed before the FSBL hands over control to U-Boot. This code is necessary for 
initialization of the 96B Quad Ethernet Mezzanine and the PCS/PMA or SGMII IP cores,
so that U-Boot and Linux can make use of the Ethernet ports. The added code does the 
following:

1. Initializes GEM0 so that it's MDIO interface can be used (we need it to communicate
   with the external PHYs and the PCS/PMA or SGMII IP cores)
2. Assert reset of PCS/PMA or SGMII IP core
3. Hardware reset the 4x Ethernet PHYs and release from reset
4. Enable the 625MHz SGMII output clock of the PHY of port 3 of the 96B Quad Ethernet
   Mezzanine card (PHY address 0xF). This clock is required by the PCS/PMA or SGMII IP core
5. Release the PCS/PMA or SGMII IP core from reset
6. Disable ISOLATE bit on all PCS/PMA or SGMII IP cores, and enable autonegotiation
   on those cores for ports 0-2. Note that port 3 cannot support SGMII autonegotiation.

The source code for this patch can be found in this path of the Github repo: 
``PetaLinux/src/common/project-spec/meta-user/recipes-bsp/fsbl/files``


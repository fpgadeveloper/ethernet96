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


EMIO GPIOs
----------

In both the PS GEM and AXI Ethernet designs, the EMIO GPIOs are connected to the PHY resets
and the PHY GPIOs as shown in the table below:

+-------------+-------------------+--------------+--------+---------------+
| | EMIO      | | PHY             | | GPIO       | | GPIO | | Pin         |
| | GPIO      | | Connection      | | bank       | | bit  | | mapping     |
+=============+===================+==============+========+===============+
| 0           |  PHY0 RESET_N     | 3            |  0     | 416           |
+-------------+-------------------+--------------+--------+---------------+
| 1           |  PHY1 RESET_N     | 3            |  1     | 417           |
+-------------+-------------------+--------------+--------+---------------+
| 2           |  PHY2 RESET_N     | 3            |  2     | 418           |
+-------------+-------------------+--------------+--------+---------------+
| 3           |  PHY3 RESET_N     | 3            |  3     | 419           |
+-------------+-------------------+--------------+--------+---------------+
| 4           |  PHY0 GPIO_0      | 3            |  4     | 420           |
+-------------+-------------------+--------------+--------+---------------+
| 5           |  PHY0 GPIO_1      | 3            |  5     | 421           |
+-------------+-------------------+--------------+--------+---------------+
| 6           |  PHY1 GPIO_0      | 3            |  6     | 422           |
+-------------+-------------------+--------------+--------+---------------+
| 7           |  PHY1 GPIO_1      | 3            |  7     | 423           |
+-------------+-------------------+--------------+--------+---------------+
| 8           |  PHY2 GPIO_0      | 3            |  8     | 424           |
+-------------+-------------------+--------------+--------+---------------+
| 9           |  PHY2 GPIO_1      | 3            |  9     | 425           |
+-------------+-------------------+--------------+--------+---------------+
| 10          |  PHY3 GPIO_0      | 3            |  10    | 426           |
+-------------+-------------------+--------------+--------+---------------+
| 11          |  PHY3 GPIO_1      | 3            |  11    | 427           |
+-------------+-------------------+--------------+--------+---------------+

The first four EMIO GPIOs are connected to the external PHY RESET_N pins.
These can be driven LOW to place the respective PHY in hardware reset.
The remaining EMIO GPIOs are connected to the external PHY GPIO_x pins.
Although named "GPIO_x", these PHY pins are in fact output-only
and their purpose can be configured by setting the GPIO Mux Control Register
of the PHYs via the MDIO bus. Please refer to the 
`DP83867 datasheet <http://www.ti.com/product/DP83867CS>`_ for more information.


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

* Define the ``phy0`` to ``phy3`` nodes within the ``gem0`` node

* Within each phy node:

  * Define the PHY address (``reg``)
  * Set the TX and RX internal delay
  * Set the FIFO depth
  * Enable SGMII clock for PHY3 (``ti,sgmii-ref-clock-output-enable``)
  * Disable SGMII auto-negotiation in PHY3 (``ti,dp83867-sgmii-autoneg-dis`` see DP83867 patch below)
  
* Add these properties to each of the ``gem0`` to ``gem3`` nodes:

  * Set PHY handle (use labels defined in the ``gem0`` node)
  * Set PHY mode set to GMII
  * Set PHY reset to connected GPIO
  * Set PHY reset to active-low
  
For more detail, refer to the `device tree for the GEM design 
<https://github.com/fpgadeveloper/ethernet96/blob/master/PetaLinux/src/ports-0123/project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi>`_
in the Github repository.


Device tree for AXI Ethernet design
-----------------------------------

* Define the ``phy0`` to ``phy3`` nodes within the ``mdio`` node of the ``axi_ethernet_0`` node

* Within each phy node:

  * Define the PHY address (``reg``)
  * Specify PHY type to SGMII (``xlnx,phy-type = <0x4>;``)
  * Set the TX and RX internal delay
  * Set the FIFO depth
  * Enable SGMII clock for PHY3 (``ti,sgmii-ref-clock-output-enable``)
  * Disable SGMII auto-negotiation in PHY3 (``ti,dp83867-sgmii-autoneg-dis`` see DP83867 patch below)
  
* Add these properties to each of the ``axi_ethernet_0`` to ``axi_ethernet_3`` nodes:

  * Set PHY handle (use labels defined in the ``axi_ethernet_0`` node)
  * Set PHY mode set to GMII
  
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
* iperf3

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

SGMII autonegotiation is disabled in the PCS/PMA or SGMII core for port
3, therefore we need to modify the driver so that it can also disable SGMII autonegotiation
in the PHY.

To allow for this, we patch the DP83867 driver to accept an extra property
in the device tree:

* ``ti,dp83867-sgmii-autoneg-dis``: When added to the GEM node, this will disable the SGMII 
  autonegotiation feature when the PHY is configured (eg. ipconfig eth0 up)

This property should be included in the ``gem3`` node or the ``axi_ethernet_3`` node of 
the device tree (depending on the Vivado design being used).

Since PetaLinux release 2020.1, the DP83867 driver will only configure the PHY for SGMII 
if the ``phy-mode`` property (PHY interface) in the device tree is set to ``sgmii``. In 
earlier releases, it would assume SGMII if ``phy-mode`` was not set to ``rgmii``. In our 
case, we cannot set ``phy-mode="sgmii"`` because that would cause the MACB driver to 
set the SGMIIEN and PCSSEL bits in the GEM. Instead, we use ``phy-mode="gmii"`` and we 
patch the DP83867 driver such that it doesn't require ``phy-mode="sgmii"`` to configure 
for SGMII.

The source code for this patch can be found in this path of the Github repo: 
``PetaLinux/src/common/project-spec/meta-user/recipes-kernel/linux/linux-xlnx``


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


xilinx_uartps: Really fix id assignment patch for 2020.1
--------------------------------------------------------

This patch comes originated here:	https://www.spinics.net/lists/linux-serial/msg39343.html
Without this patch PetaLinux boot hangs after these lines:

.. code-block:: console
  
    console [tty0] enabled
	  bootconsole [cdns0] disabled

This problem occurs with PetaLinux 2020.1 on Ultra96 when using UART1 as the console output (serial0).
Xilinx produced a patch for this problem but it does not properly fix the problem:
https://www.xilinx.com/support/answers/75417.html

The complete solution is described in this Xilinx forum post:
https://forums.xilinx.com/t5/Embedded-Linux/Freeze-in-Xilinx-Linux-2020-1-Serial-UART-Driver/td-p/1130457


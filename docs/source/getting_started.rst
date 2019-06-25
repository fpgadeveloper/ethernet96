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

Clone or download that repo, then copy the ``ultra96v1`` and ``ultra96v2`` directories from it to the 
``<path-to-xilinx-vivado>/data/boards/board_files`` directory on your machine.

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

`96B Quad Ethernet Mezzanine Github page <https://github.com/fpgadeveloper/ethernet96>`_

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
#. You will be asked to select between Ultra96 v1 and v2. It is important to select the
   correct version of the Ultra96 that you are using. Type 1 or 2 (for v1 or v2)
   and press ENTER. The script will now generate the Vivado project for your board.
#. Run Vivado and open the project that was just created.
#. Click Generate bitstream.
#. When the bitstream is successfully generated, select "File->Export->Export Hardware".
   In the window that opens, tick "Include bitstream" and "Local to project".
   **DO NOT** "Launch SDK".
#. Return to Windows Explorer and browse to the SDK directory in the repo.
#. Double click the `build-sdk.bat` batch file. The batch file will run the
   `build-sdk.tcl` script and build the SDK workspace containing the hardware
   design and the software application. Please refer to the "README.md" file in the SDK
   subdirectory for instructions on running the software application on hardware.
#. If you are interested in building PetaLinux, you will need to use a Linux machine and
   follow the steps for Linux users below.

Linux users
^^^^^^^^^^^

#. Launch the Vivado GUI.
#. On the welcome page, there is a Tcl console. In the Tcl console, ``cd`` to the repo files on your hard drive
   and into the Vivado subdirectory. For example: ``cd /media/projects/ethernet96/Vivado``.
#. In the Vivado subdirectory, you will find multiple Tcl files. To list them, type ``exec ls {*}[glob *.tcl]``.
   Determine the Tcl script for the example project that you would
   like to generate (for example: ``build-ps-gem.tcl``), then ``source`` the script in the Tcl console:
   For example: ``source build-ps-gem.tcl``
#. Vivado will run the script and generate the project. When it's finished, click Generate bitstream.
#. When the bitstream is successfully generated, select "File->Export->Export Hardware".
   In the window that opens, tick "Include bitstream" and "Local to project".
   **DO NOT** "Launch SDK".
#. To build the SDK workspace, open a Linux command terminal and ``cd`` to the SDK directory in the repo.
#. The SDK directory contains the ``build-sdk.tcl`` script that will build the SDK workspace containing the hardware
   design and the software application. Run the build script by typing the following command:
   ``<path-of-xilinx-sdk>/bin/xsdk -batch -source build-sdk.tcl``
   Note that you must replace ``<path-of-xilinx-sdk>`` with the actual path to your Xilinx SDK installation.
#. Please refer to the "README.md" file in the SDK subdirectory for instructions on running the software 
   application on hardware.
#. To build the PetaLinux project, follow the steps in the following section.

Build the PetaLinux projects
----------------------------

Once the Vivado project(s) have been built and exported to SDK, you can now build the PetaLinux project(s).

.. NOTE:: The PetaLinux projects can only be built on a Linux machine (or virtual Linux machine).

Linux users
^^^^^^^^^^^

#. To build the PetaLinux project, first launch PetaLinux by sourcing the "settings.sh" bash script, 
   eg: ``source <path-to-installed-petalinux>/settings.sh``.
#. Now ``cd`` to the PetaLinux directory in the repo and run the ``build-petalinux`` 
   script. You may have to add execute permission to the script first using ``chmod +x build-petalinux``,
   then run it by typing ``./build-petalinux``.

.. WARNING:: **UNIX line endings:** The scripts and files in the PetaLinux directory of this repository must 
          have UNIX line endings when they are executed or used under Linux. The best way to ensure UNIX 
          line endings, is to clone the repo directly onto your Linux machine. If instead you have copied 
          the repo from a Windows machine, the files will have DOS line endings and
          you must use the ``dos2unix`` tool to convert the line endings for UNIX.

Launch on hardware
==================

Echo server via JTAG
--------------------

#. Open Xilinx SDK (**DO NOT** use the Launch SDK option from Vivado).
#. Power up your hardware platform and ensure that the JTAG is connected properly.
#. Select "Xilinx Tools->Program FPGA". In the "Program FPGA" dialog box that appears, select the
   "Hardware Platform" that you want to run, this will correspond to name of the Vivado project that
   you built earlier.
#. Click on the software application that you want to run, it should be the one with the postfix "_echo".
#. Select "Run->Run Configurations", then in the dialog box that appears, double-click on the option
   "Xilinx C/C++ application (System Debugger)". This will create a new run configuration for the application.
#. Select the new run configuration and click "Run".



PetaLinux via JTAG
------------------

To launch the PetaLinux project on hardware via JTAG, connect and power up your hardware and then
use the following commands in a Linux command terminal:

#. Change current directory to the PetaLinux project directory: ``cd <petalinux-project-dir>``
#. Download bitstream to the FPGA: ``petalinux-boot --jtag --fpga``
   Note that you don't have to specify the bitstream because this command will use the one that it finds
   in the ``./images/linux`` directory.
#. Download the PetaLinux kernel to the FPGA: ``petalinux-boot --jtag --kernel``

PetaLinux via SD card
---------------------

To boot PetaLinux on hardware via SD card:

#. The SD card must first be prepared with two partitions: one for the boot files and another 
   for the root file system.

   * Partition 1: FAT32, size 1GB, label ``boot``
   * Partition 2: ext4, 4GB or more, label ``rootfs``

#. Copy the following files to the `boot` partition of the SD card:

   * ``/<petalinux-project>/images/linux/BOOT.bin``
   * ``/<petalinux-project>/images/linux/image.ub``

#. Create the root file system using dd:

   .. code-block:: console
   
      $ sudo dd if=rootfs.ext4 of=/dev/sdX2
      $ sync
   
   .. DANGER:: ``sdX2`` will depend on your system (it could be ``sdE2`` or ``sdF2`` or something else) and
       it is very important that you determine the correct label before running the `dd` command because
       you can potentially overwrite the wrong disk.

#. Connect and power your hardware.


Echo Server Example Usage
=========================

Default IP address
------------------

The echo server is designed to attempt to obtain an IP address from a DHCP server. This is useful
if the echo server is connected to a network. Once the IP address is obtained, it is printed out
in the UART console output.

If instead the echo server is connected directly to a PC, the DHCP attempt will fail and the echo
server will default to the IP address 192.168.1.10. To be able to communicate with the echo server
from the PC, the PC should be configured with a fixed IP address on the same subnet, for example:
192.168.1.20.

Ping the port
-------------

The echo server can be "pinged" from a connected PC, or if connected to a network, from
another device on the network. The UART console output will tell you what the IP address of the 
echo server is. To ping the echo server, use the ``ping`` command from a command console.

For example: ``ping 192.168.1.10``

Change the targetted port
-------------------------

The echo server example design currently can only target one Ethernet port at a time.
Selection of the Ethernet port can be changed by modifying the defines contained in the
``platform_config.h`` file in the application sources. Set ``PLATFORM_EMAC_BASEADDR``
to one of the following values:

For designs using the GEMs:

* Port 0: ``XPAR_XEMACPS_0_BASEADDR``
* Port 1: ``XPAR_XEMACPS_1_BASEADDR``
* Port 2: ``XPAR_XEMACPS_2_BASEADDR``
* Port 3: ``XPAR_XEMACPS_3_BASEADDR``

For designs using AXI Ethernet:

* Port 0: ``XPAR_AXIETHERNET_0_BASEADDR``
* Port 1: ``XPAR_AXIETHERNET_1_BASEADDR``
* Port 2: ``XPAR_AXIETHERNET_2_BASEADDR``
* Port 3: ``XPAR_AXIETHERNET_2_BASEADDR``


PetaLinux Example Usage
=======================

In the PetaLinux projects, the Ethernet ports are assigned to the network interfaces *eth0-eth3* as follows:

* **eth0**: Port 0
* **eth1**: Port 1
* **eth2**: Port 2
* **eth3**: Port 3

The following examples demonstrate how to use these network interfaces to configure the Ethernet ports for
use in PetaLinux.

Enable port
-----------
In this example we enable port 0 (eth0).

.. code-block:: console

    root@ps_gem:~# ifconfig eth0 up
    [  209.778955] TI DP83867 ff0b0000.mdio-mii:03: attached PHY driver [TI DP83867] (mii_bus:phy_addr=ff0b0000.mdio-mii:03, irq=POLL)
    [  209.793249] pps pps1: new PPS source ptp1
    [  209.797193] macb ff0b0000.ethernet: gem-ptp-timer ptp clock registered.
    [  209.803995] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
    [  213.868935] macb ff0b0000.ethernet eth0: link up (1000/Full)
    [  213.874547] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
 
Enable port with fixed IP address
---------------------------------
In this example we enable port 1 (eth1) with a fixed IP address.

.. code-block:: console

    root@ps_gem:~# ifconfig eth1 192.168.2.19 up
    [  209.778955] TI DP83867 ff0b0000.mdio-mii:03: attached PHY driver [TI DP83867] (mii_bus:phy_addr=ff0b0000.mdio-mii:03, irq=POLL)
    [  209.793249] pps pps1: new PPS source ptp1
    [  209.797193] macb ff0c0000.ethernet: gem-ptp-timer ptp clock registered.
    [  209.803995] IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
    [  213.868935] macb ff0c0000.ethernet eth1: link up (1000/Full)
    [  213.874547] IPv6: ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready

Check status of a port with ethtool
-----------------------------------
In this example we check the status of port 2 (eth2) with "ethtool".

.. code-block:: console

    root@ps_gem:~# ethtool eth2
    Settings for eth2:
            Supported ports: [ TP MII ]
            Supported link modes:   10baseT/Half 10baseT/Full
                                    100baseT/Half 100baseT/Full
                                    1000baseT/Half 1000baseT/Full
            Supported pause frame use: No
            Supports auto-negotiation: Yes
            Advertised link modes:  10baseT/Half 10baseT/Full
                                    100baseT/Half 100baseT/Full
                                    1000baseT/Half 1000baseT/Full
            Advertised pause frame use: No
            Advertised auto-negotiation: Yes
            Link partner advertised link modes:  10baseT/Half 10baseT/Full
                                                 100baseT/Half 100baseT/Full
                                                 1000baseT/Full
            Link partner advertised pause frame use: No
            Link partner advertised auto-negotiation: Yes
            Speed: 1000Mb/s
            Duplex: Full
            Port: MII
            PHYAD: 1
            Transceiver: internal
            Auto-negotiation: on
            Link detected: yes

Ping link partner using specific port
-------------------------------------
In this example we ping the link partner from port 1 (eth1).

.. code-block:: console

    root@ps_gem:~# ping -I eth1 192.168.1.10
    PING 192.168.1.10 (192.168.1.10): 56 data bytes
    64 bytes from 192.168.1.10: seq=0 ttl=128 time=0.939 ms
    64 bytes from 192.168.1.10: seq=1 ttl=128 time=0.496 ms
    64 bytes from 192.168.1.10: seq=2 ttl=128 time=0.486 ms
    64 bytes from 192.168.1.10: seq=3 ttl=128 time=0.485 ms
    64 bytes from 192.168.1.10: seq=4 ttl=128 time=0.501 ms
    ^C
    --- 192.168.1.10 ping statistics ---
    5 packets transmitted, 5 packets received, 0% packet loss
    round-trip min/avg/max = 0.485/0.581/0.939 ms

Check port configuration
------------------------
In this example we check the configuration of port 1 (eth1).

.. code-block:: console

    root@ps_gem:~# ifconfig eth1
    eth1      Link encap:Ethernet  HWaddr 00:0A:35:00:01:23
              inet addr:192.168.1.11  Bcast:192.168.1.255  Mask:255.255.255.0
              inet6 addr: fe80::20a:35ff:fe00:123%4294741717/64 Scope:Link
              UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
              RX packets:148 errors:0 dropped:0 overruns:0 frame:0
              TX packets:74 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:1000
              RX bytes:17567 (17.1 KiB)  TX bytes:12943 (12.6 KiB)
              Interrupt:31


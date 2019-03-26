PetaLinux Project source files
==============================

### How to build the PetaLinux projects

#### Requirements

* Windows or Linux PC with Vivado installed
* Linux PC or virtual machine with PetaLinux installed

#### Instructions

In order to make use of these source files, you must:

1. First generate the Vivado project hardware design(s) (the bitstream) and export the design(s) to SDK.
2. Launch PetaLinux by sourcing the `settings.sh` bash script, eg: `source <path-to-installed-petalinux>/settings.sh`
3. Build the PetaLinux project(s) by executing the `build-petalinux` script in Linux.

The script will generate a separate PetaLinux project for all of the generated and exported Vivado projects that
it finds in the Vivado directory of this repo.

### Status of the PetaLinux projects

#### PS GEM based design

* All ports working for the ps_gem design
* Port 0-2 will work at link speeds of 10Mbps, 100Mbps and 1000Mbps
* Port 3 will only work at a link speed of 1000Mbps. It's hard coded to work at 1000Mbps only but we're working on a 
fix for this so that the PCS/PMA or SGMII IP will be configured according to the actual negotiated link speed

#### AXI Ethernet based design

* Not yet tested for the axi_eth design (work still needs to be done)
* To do: Need to patch the AXI Ethernet driver to deal with multiple PHYs connected to a single MDIO bus

### UNIX line endings

The scripts and files in the PetaLinux directory of this repository must have UNIX line endings when they are
executed or used under Linux. The best way to ensure UNIX line endings, is to clone the repo directly onto your
Linux machine. If instead you have copied the repo from a Windows machine, the files will have DOS line endings and
you must use the `dos2unix` tool to convert the line endings for UNIX.

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

### Launch PetaLinux on hardware

#### Via JTAG

To launch the PetaLinux project on hardware via JTAG, connect and power up your hardware and then
use the following commands in a Linux command terminal:

1. Change current directory to the PetaLinux project directory:
`cd <petalinux-project-dir>`
2. Download bitstream to the FPGA:
`petalinux-boot --jtag --fpga`
Note that you don't have to specify the bitstream because this command will use the one that it finds
in the `./images/linux` directory.
3. Download the PetaLinux kernel to the FPGA:
`petalinux-boot --jtag --kernel`

#### Via SD card

To boot PetaLinux on hardware via SD card:

1. The SD card must first be prepared with two partitions: one for the boot files and another 
for the root file system.
  * Partition 1: FAT32, size 1GB, label `boot`
  * Partition 2: ext4, 4GB or more, label `rootfs`
2. Copy the following files to the `boot` partition of the SD card:
  * `/<petalinux-project>/images/linux/BOOT.bin`
  * `/<petalinux-project>/images/linux/image.ub`
3. Create the root file system using dd:
```$ sudo dd if=rootfs.ext4 of=/dev/sdX2
$ sync
```
Note that `sdX2` will depend on your system (it could be `sdE2` or `sdF2` or something else) and
it is very important that you determine the correct label before running the `dd` command because
you can potentially overwrite the wrong disk.
4. Connect and power your hardware.

### Configuration files

The configuration files contained in the `src` directory include:

* Device trees
* Rootfs configuration (to include ethtool)
* Interface initializations (sets eth0-3 interfaces to DHCP)
* Kernel configuration
* DP83867 Ethernet PHY driver patch
* ZynqMP FSBL hooks patch

#### DS83867 Ethernet PHY driver patch

The PCS/PMA or SGMII cores in the Vivado designs rely on the 625MHz SGMII output clock 
of the PHY of port 3 (PHY address 0xF). The DS83867 PHY does not enable this clock output
by default, nor does the standard driver, so we need to modify the driver so that it can
be enabled. Also, SGMII autonegotiation is disabled in the PCS/PMA or SGMII core for port
3, therefore we need to modify the driver so that it can also disable SGMII autonegotiation
in the PHY. This patch modifies the driver for DP83867 Gigabit Ethernet PHY so that it will 
accept two extra properties in the device tree:
* ti,dp83867-sgmii-autoneg-dis: When added to the GEM node, this will disable the SGMII 
  autonegotiation feature when the PHY is configured (eg. ipconfig eth0 up)
* ti,dp83867-sgmii-clk-en: When added to the GEM node, this will enable the 625MHz
  SGMII clock output of the PHY (ie. enable 3-wire mode)
Both of these properties should be included in the gem3 node or the axi_ethernet_3 node of 
the device tree (depending on the Vivado design being used).

#### ZynqMP FSBL hooks patch

This patch modifies the ZynqMP FSBL to add code to the XFsbl_HookBeforeHandoff which is
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

### Port configuration

* eth0: 96B Quad Ethernet Mezzanine Port 0
* eth1: 96B Quad Ethernet Mezzanine Port 1
* eth2: 96B Quad Ethernet Mezzanine Port 2
* eth3: 96B Quad Ethernet Mezzanine Port 3

### Example port usage from Linux command line

#### Enable port 0
```root@ps_gem:~# ifconfig eth0 up
[  209.778955] TI DP83867 ff0b0000.mdio-mii:03: attached PHY driver [TI DP83867] (mii_bus:phy_addr=ff0b0000.mdio-mii:03, irq=POLL)
[  209.793249] pps pps1: new PPS source ptp1
[  209.797193] macb ff0b0000.ethernet: gem-ptp-timer ptp clock registered.
[  209.803995] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[  213.868935] macb ff0b0000.ethernet eth0: link up (1000/Full)
[  213.874547] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
```
 
#### Enable port 1 with fixed IP address
```root@ps_gem:~# ifconfig eth1 192.168.2.19 up
[  209.778955] TI DP83867 ff0b0000.mdio-mii:03: attached PHY driver [TI DP83867] (mii_bus:phy_addr=ff0b0000.mdio-mii:03, irq=POLL)
[  209.793249] pps pps1: new PPS source ptp1
[  209.797193] macb ff0c0000.ethernet: gem-ptp-timer ptp clock registered.
[  209.803995] IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
[  213.868935] macb ff0c0000.ethernet eth1: link up (1000/Full)
[  213.874547] IPv6: ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
```

#### Check status of port 2 with ethtool
```root@ps_gem:~# ethtool eth2
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
```

#### Ping link partner using specific port (eg. port 1)
```root@ps_gem:~# ping -I eth1 192.168.1.10
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
```

#### Check port configuration (eg. port 1)
```root@ps_gem:~# ifconfig eth1
eth1      Link encap:Ethernet  HWaddr 00:0A:35:00:01:23
          inet addr:192.168.1.11  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::20a:35ff:fe00:123%4294741717/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:148 errors:0 dropped:0 overruns:0 frame:0
          TX packets:74 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:17567 (17.1 KiB)  TX bytes:12943 (12.6 KiB)
          Interrupt:31
```

### To do

* FSBL hooks patch should be made to work for the AXI Ethernet design also
* U-Boot needs to be patched so that it works for a configuration of multiple PHYs
  on a single MDIO bus
* Need to be using the PCS/PMA or SGMII core's TX and RX locked signals to ensure
  that the 625MHz clock has been properly enabled
  

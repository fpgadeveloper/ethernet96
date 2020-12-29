Modified BSP files
==================

### lwIP modifications

This project uses a modified version of the lwIP library. The modifications allow it to work for our MDIO
bus architecture where a single master is connected to multiple slaves.

### AXI Ethernet driver modifications

The AXI Ethernet driver is also modified to allow support of the common master MDIO architecture. To do this
we add an extra pointer to the XAxiEthernet struct (AXI Ethernet driver instance data) that points to the
base address of the XAxiEthernet that is master of the MDIO bus. The MDIO read and write functions are changed to
refer to this base address rather than the base address of the instance passed.

### EMAC PS driver modifications

The EMAC PS driver is also modified to allow support of the common master MDIO architecture. To do this
we add an extra pointer to the XEmacPs struct (XEmacPs driver instance data) that points to the
base address of the XEmacPs that is master of the MDIO bus. The MDIO read and write functions (XEmacPs_PhyRead,
XEmacPs_PhyWrite) are changed to refer to this base address rather than the base address of the instance passed.

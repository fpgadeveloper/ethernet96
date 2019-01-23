# Ultra96 Ethernet

Example designs for the 96B Quad Ethernet Mezzanine for the Ultra96.

This project is still under development.

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


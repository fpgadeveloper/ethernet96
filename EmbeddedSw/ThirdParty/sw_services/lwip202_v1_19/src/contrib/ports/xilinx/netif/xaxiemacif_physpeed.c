/*
 * Copyright (c) 2007-2008, Advanced Micro Devices, Inc.
 *               All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *    * Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    * Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in
 *      the documentation and/or other materials provided with the
 *      distribution.
 *    * Neither the name of Advanced Micro Devices, Inc. nor the names
 *      of its contributors may be used to endorse or promote products
 *      derived from this software without specific prior written
 *      permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Some portions copyright (c) 2010-2017 Xilinx, Inc.  All rights reserved.
 *
 * Xilinx, Inc.
 * XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A
 * COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
 * ONE POSSIBLE   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR
 * STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION
 * IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE
 * FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.
 * XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO
 * THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO
 * ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
 * FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.
 *
 */

#include "netif/xaxiemacif.h"
#include "lwipopts.h"
#include "sleep.h"
#include "xemac_ieee_reg.h"

/* Definitions related to PCS PMA PL IP*/
#define XPAR_GIGE_PCS_PMA_SGMII_CORE_PRESENT 1U
/* 96B Quad Ethernet Mezzanine PHY addresses */
#define PORT0_SGMII_PHYADDR 2
#define PORT0_EXT_PHY_ADDR 1
#define PORT1_SGMII_PHYADDR 4
#define PORT1_EXT_PHY_ADDR 3
#define PORT2_SGMII_PHYADDR 13
#define PORT2_EXT_PHY_ADDR 12
#define PORT3_SGMII_RX_PHYADDR 16
#define PORT3_SGMII_TX_PHYADDR 17
#define PORT3_EXT_PHY_ADDR 15

/* Generic PHY Registers */
#define IEEE_PHY_CONTROL_REG                                    0x00
#define IEEE_PHY_STATUS_REG                                     0x01
#define IEEE_PHY_STATUS_AUTO_NEGOTIATION_COMPLETE            (0x0020)
#define IEEE_PHY_DETECT_1_REG                                   0x02
#define IEEE_PHY_DETECT_2_REG                                   0x03

#define PHY_R0_ISOLATE  						0x0400
#define PHY_DETECT_REG  						1
#define PHY_IDENTIFIER_1_REG					2
#define PHY_IDENTIFIER_2_REG					3
#define PHY_DETECT_MASK 						0x1808
#define PHY_MARVELL_IDENTIFIER					0x0141
#define PHY_TI_IDENTIFIER					    0x2000

/* Marvel PHY flags */
#define MARVEL_PHY_IDENTIFIER 					0x141
#define MARVEL_PHY_MODEL_NUM_MASK				0x3F0
#define MARVEL_PHY_88E1111_MODEL				0xC0
#define MARVEL_PHY_88E1116R_MODEL				0x240
#define PHY_88E1111_RGMII_RX_CLOCK_DELAYED_MASK	0x0080

/* TI PHY Flags */
#define TI_PHY_DETECT_MASK 						0x796D
#define TI_PHY_IDENTIFIER 						0x2000
#define TI_PHY_DP83867_MODEL					0xA231
#define DP83867_RGMII_CLOCK_DELAY_CTRL_MASK		0x0003
#define DP83867_RGMII_TX_CLOCK_DELAY_MASK		0x0030
#define DP83867_RGMII_RX_CLOCK_DELAY_MASK		0x0003

/* TI DP83867 PHY Registers */
#define DP83867_R32_RGMIICTL1					0x32
#define DP83867_R86_RGMIIDCTL					0x86

#define TI_PHY_REGCR			0xD
#define TI_PHY_ADDDR			0xE
#define TI_PHY_PHYCTRL			0x10
#define TI_PHY_CFGR2			0x14
#define TI_PHY_SGMIITYPE		0xD3
#define TI_PHY_CFGR2_SGMII_AUTONEG_EN	0x0080
#define TI_PHY_SGMIICLK_EN		0x4000
#define TI_PHY_REGCR_DEVAD_EN		0x001F
#define TI_PHY_REGCR_DEVAD_DATAEN	0x4000
#define TI_PHY_CFGR2_MASK		0x003F
#define TI_PHY_REGCFG4			0x31
#define TI_PHY_REGCR_DATA		0x401F
#define TI_PHY_CFG4RESVDBIT7		0x80
#define TI_PHY_CFG4RESVDBIT8		0x100
#define TI_PHY_CFG4_AUTONEG_TIMER	0x60

#define TI_PHY_CFG2_SPEEDOPT_10EN          0x0040
#define TI_PHY_CFG2_SGMII_AUTONEGEN        0x0080
#define TI_PHY_CFG2_SPEEDOPT_ENH           0x0100
#define TI_PHY_CFG2_SPEEDOPT_CNT           0x0800
#define TI_PHY_CFG2_SPEEDOPT_INTLOW        0x2000

#define TI_PHY_CR_SGMII_EN		0x0800

/* TI DP83867 Datasheet Section 8.6.15 page 57 */
#define TI_DP83867_PHYSTS                             0x11
#define TI_DP83867_PHYSTS_SPEED_SELECTION_MASK        0xC000
#define TI_DP83867_PHYSTS_SPEED_SELECTION_1000_MBPS   0x8000
#define TI_DP83867_PHYSTS_SPEED_SELECTION_100_MBPS    0x4000
#define TI_DP83867_PHYSTS_SPEED_SELECTION_10_MBPS     0x0000
#define TI_DP83867_PHYSTS_DUPLEX_FULL                 0x2000
#define TI_DP83867_PHYSTS_LINK_STATUS_UP              0x0400


/* Loop counters to check for reset done
 */
#define RESET_TIMEOUT							0xFFFF
#define AUTO_NEG_TIMEOUT 						0x00FFFFFF

#if XPAR_GIGE_PCS_PMA_1000BASEX_CORE_PRESENT == 1 || \
	XPAR_GIGE_PCS_PMA_SGMII_CORE_PRESENT == 1
#define PCM_PMA_CORE_PRESENT
#else
#undef PCM_PMA_CORE_PRESENT
#endif

#ifdef PCM_PMA_CORE_PRESENT
#define IEEE_CTRL_RESET                         0x9140
#define IEEE_CTRL_ISOLATE_DISABLE               0xFBFF
#endif

#define PHY_XILINX_PCS_PMA_ID1			0x0174
#define PHY_XILINX_PCS_PMA_ID2			0x0C00

extern u32_t phyaddrforemac;

XAxiEthernet *axi_ethernet_0;

static void __attribute__ ((noinline)) AxiEthernetUtilPhyDelay(unsigned int Seconds);

static int detect_phy(XAxiEthernet *xaxiemacp)
{
	u16 phy_reg;
	u16 phy_id;
	u32 phy_addr;

	for (phy_addr = 31; phy_addr > 0; phy_addr--) {
		XAxiEthernet_PhyRead(xaxiemacp, phy_addr, PHY_DETECT_REG,
								&phy_reg);

		if ((phy_reg != 0xFFFF) &&
			((phy_reg & PHY_DETECT_MASK) == PHY_DETECT_MASK)) {
			/* Found a valid PHY address */
			LWIP_DEBUGF(NETIF_DEBUG, ("XAxiEthernet detect_phy: PHY detected at address %d.\r\n", phy_addr));
			LWIP_DEBUGF(NETIF_DEBUG, ("XAxiEthernet detect_phy: PHY detected.\r\n"));
			XAxiEthernet_PhyRead(xaxiemacp, phy_addr, PHY_IDENTIFIER_1_REG,
										&phy_reg);
			if ((phy_reg != PHY_MARVELL_IDENTIFIER) &&
                (phy_reg != TI_PHY_IDENTIFIER)){
				xil_printf("WARNING: Not a Marvell or TI Ethernet PHY. Please verify the initialization sequence\r\n");
			}
			phyaddrforemac = phy_addr;
			return phy_addr;
		}

		XAxiEthernet_PhyRead(xaxiemacp, phy_addr, PHY_IDENTIFIER_1_REG,
				&phy_id);

		if (phy_id == PHY_XILINX_PCS_PMA_ID1) {
			XAxiEthernet_PhyRead(xaxiemacp, phy_addr, PHY_IDENTIFIER_2_REG,
					&phy_id);
			if (phy_id == PHY_XILINX_PCS_PMA_ID2) {
				/* Found a valid PHY address */
				LWIP_DEBUGF(NETIF_DEBUG, ("XAxiEthernet detect_phy: PHY detected at address %d.\r\n",
							phy_addr));
				phyaddrforemac = phy_addr;
				return phy_addr;
			}
		}
	}

	LWIP_DEBUGF(NETIF_DEBUG, ("XAxiEthernet detect_phy: No PHY detected.  Assuming a PHY at address 0\r\n"));

        /* default to zero */
	return 0;
}

void XAxiEthernet_PhyReadExtended(XAxiEthernet *InstancePtr, u32 PhyAddress,
		u32 RegisterNum, u16 *PhyDataPtr)
{
	XAxiEthernet_PhyWrite(InstancePtr, PhyAddress,
			IEEE_MMD_ACCESS_CONTROL_REG, IEEE_MMD_ACCESS_CTRL_DEVAD_MASK);

	XAxiEthernet_PhyWrite(InstancePtr, PhyAddress,
			IEEE_MMD_ACCESS_ADDRESS_DATA_REG, RegisterNum);

	XAxiEthernet_PhyWrite(InstancePtr, PhyAddress,
			IEEE_MMD_ACCESS_CONTROL_REG, IEEE_MMD_ACCESS_CTRL_NOPIDEVAD_MASK);

	XAxiEthernet_PhyRead(InstancePtr, PhyAddress,
			IEEE_MMD_ACCESS_ADDRESS_DATA_REG, PhyDataPtr);

}

void XAxiEthernet_PhyWriteExtended(XAxiEthernet *InstancePtr, u32 PhyAddress,
		u32 RegisterNum, u16 PhyDataPtr)
{
	XAxiEthernet_PhyWrite(InstancePtr, PhyAddress,
			IEEE_MMD_ACCESS_CONTROL_REG, IEEE_MMD_ACCESS_CTRL_DEVAD_MASK);

	XAxiEthernet_PhyWrite(InstancePtr, PhyAddress,
			IEEE_MMD_ACCESS_ADDRESS_DATA_REG, RegisterNum);

	XAxiEthernet_PhyWrite(InstancePtr, PhyAddress,
			IEEE_MMD_ACCESS_CONTROL_REG, IEEE_MMD_ACCESS_CTRL_NOPIDEVAD_MASK);

	XAxiEthernet_PhyWrite(InstancePtr, PhyAddress,
			IEEE_MMD_ACCESS_ADDRESS_DATA_REG, PhyDataPtr);

}

unsigned int get_phy_negotiated_speed (XAxiEthernet *xaxiemacp, u32 phy_addr)
{
	u16 control;
	u16 status;
	u16 partner_capabilities;
	u16 partner_capabilities_1000;
	u16 phylinkspeed;
	u16 temp;

	/*
	xil_printf("Reset PHY\r\n");

	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_CONTROL_REG_OFFSET,
																	&control);

	control |= IEEE_CTRL_RESET_MASK;

	XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, IEEE_CONTROL_REG_OFFSET,
														control);
	AxiEthernetUtilPhyDelay(1);
	*/
	xil_printf("Start PHY autonegotiation \r\n");
	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_CONTROL_REG_OFFSET,
																	&control);

	control |= IEEE_CTRL_AUTONEGOTIATE_ENABLE;
	control |= IEEE_STAT_AUTONEGOTIATE_RESTART;
    control &= IEEE_CTRL_ISOLATE_DISABLE;

	XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, IEEE_CONTROL_REG_OFFSET,
														control);
	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_STATUS_REG_OFFSET, &status);
	xil_printf("Waiting for PHY to  complete autonegotiation \r\n");
	while ( !(status & IEEE_STAT_AUTONEGOTIATE_COMPLETE) ) {
		AxiEthernetUtilPhyDelay(1);
		XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_STATUS_REG_OFFSET,
									&status);
		xil_printf("Status reg: 0x%04X\r\n",status);
	}

	xil_printf("Autonegotiation complete \r\n");

	xil_printf("Waiting for Link to be up; Polling for SGMII core Reg \r\n");
	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_PARTNER_ABILITIES_1_REG_OFFSET, &temp);
	while(!(temp & 0x8000)) {
		XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_PARTNER_ABILITIES_1_REG_OFFSET, &temp);
	}
	if((temp & 0x0C00) == 0x0800) {
		return 1000;
	}
	else if((temp & 0x0C00) == 0x0400) {
		return 100;
	}
	else if((temp & 0x0C00) == 0x0000) {
		return 10;
	} else {
		xil_printf("get_IEEE_phy_speed(): Invalid speed bit value (0x%04X), Deafulting to Speed = 10 Mbps\r\n",temp);
		XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_CONTROL_REG_OFFSET, &temp);
		XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, IEEE_CONTROL_REG_OFFSET, 0x0100);
		return 10;
	}

	/* Read PHY control and status registers is successful. */
	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_CONTROL_REG_OFFSET,
														&control);
	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_STATUS_REG_OFFSET,
														&status);
	if ((control & IEEE_CTRL_AUTONEGOTIATE_ENABLE) && (status &
					IEEE_STAT_AUTONEGOTIATE_CAPABLE)) {
		xil_printf("Waiting for PHY to complete autonegotiation.\r\n");
		while ( !(status & IEEE_STAT_AUTONEGOTIATE_COMPLETE) ) {
							XAxiEthernet_PhyRead(xaxiemacp, phy_addr,
									IEEE_STATUS_REG_OFFSET,
									&status);
	    }

		xil_printf("autonegotiation complete \r\n");

		XAxiEthernet_PhyRead(xaxiemacp, phy_addr,
										IEEE_PARTNER_ABILITIES_1_REG_OFFSET,
										&partner_capabilities);
		if (status & IEEE_STAT_1GBPS_EXTENSIONS) {
			XAxiEthernet_PhyRead(xaxiemacp, phy_addr,
					IEEE_PARTNER_ABILITIES_3_REG_OFFSET,
					&partner_capabilities_1000);
			if (partner_capabilities_1000 &
					IEEE_AN3_ABILITY_MASK_1GBPS)
				return 1000;
		}

		if (partner_capabilities & IEEE_AN1_ABILITY_MASK_100MBPS)
			return 100;
		if (partner_capabilities & IEEE_AN1_ABILITY_MASK_10MBPS)
			return 10;

		xil_printf("%s: unknown PHY link speed, setting TEMAC speed to be 10 Mbps\r\n",
				__FUNCTION__);
		return 10;
	} else {
		/* Update TEMAC speed accordingly */
		if (status & IEEE_STAT_1GBPS_EXTENSIONS) {

			/* Get commanded link speed */
			phylinkspeed = control &
				IEEE_CTRL_1GBPS_LINKSPEED_MASK;

			switch (phylinkspeed) {
				case (IEEE_CTRL_LINKSPEED_1000M):
					return 1000;
				case (IEEE_CTRL_LINKSPEED_100M):
					return 100;
				case (IEEE_CTRL_LINKSPEED_10M):
					return 10;
				default:
					xil_printf("%s: unknown PHY link speed (%d), setting TEMAC speed to be 10 Mbps\r\n",
						__FUNCTION__, phylinkspeed);
					return 10;
			}
		} else {
			return (control & IEEE_CTRL_LINKSPEED_MASK) ? 100 : 10;
		}
	}
}

unsigned int get_phy_speed_TI_DP83867_SGMII(XAxiEthernet *xaxiemacp, u32 sgmii_phy_addr, u32 ext_phy_addr)
{
	u32 link_speed;
	u16 temp;
	u16 physts;
	u16 status;
	u32 control;

	if(sgmii_phy_addr == 0) {
		// Disable SGMII autonegotiation in the external PHY (address 15)
		XAxiEthernet_PhyRead(xaxiemacp, ext_phy_addr, TI_PHY_CFGR2, &control);
		control &= ~TI_PHY_CFG2_SGMII_AUTONEGEN;
		XAxiEthernet_PhyWrite(xaxiemacp, ext_phy_addr, TI_PHY_CFGR2, control);

		// Disable autonegotiation in the PCS/PMA SGMII cores (addresses 16,17)
		XAxiEthernet_PhyWrite(xaxiemacp,0x10,IEEE_CONTROL_REG_OFFSET,0x0160);
		XAxiEthernet_PhyWrite(xaxiemacp,0x11,IEEE_CONTROL_REG_OFFSET,0x0160);
	}

	xil_printf("Waiting for Link to be up \r\n");
	do
	{
		usleep(100);
		XAxiEthernet_PhyRead(xaxiemacp, ext_phy_addr, IEEE_PHY_STATUS_REG, &status);
	} while( !(status & IEEE_PHY_STATUS_AUTO_NEGOTIATION_COMPLETE) );

	xil_printf("Auto negotiation completed for TI PHY\n\r");
	xil_printf("Link speed: ");

	/* Get link state */
	do
	{
		usleep(100);
		XAxiEthernet_PhyRead(xaxiemacp, ext_phy_addr, TI_DP83867_PHYSTS, &physts);
	} while( !(physts & TI_DP83867_PHYSTS_LINK_STATUS_UP) );
	if( (physts & TI_DP83867_PHYSTS_SPEED_SELECTION_MASK) == TI_DP83867_PHYSTS_SPEED_SELECTION_1000_MBPS ) {
		xil_printf("1000 MBPS ");
		link_speed = 1000;
	}
	else if( (physts & TI_DP83867_PHYSTS_SPEED_SELECTION_MASK) == TI_DP83867_PHYSTS_SPEED_SELECTION_100_MBPS ) {
		xil_printf("100 MBPS ");
		link_speed = 100;
	}
	else {
		xil_printf("10 MBPS "); /* TODO: should check for corner case of 0xC000... */
		link_speed = 10;
	}
	if( physts & TI_DP83867_PHYSTS_DUPLEX_FULL )
		xil_printf("full duplex\r\n");
	else
		xil_printf("half duplex\r\n");

	if(sgmii_phy_addr == 0)
		return(link_speed);
	else
		return get_phy_negotiated_speed(xaxiemacp, sgmii_phy_addr);
}


unsigned get_IEEE_phy_speed(XAxiEthernet *xaxiemacp, u32 sgmii_phy_addr, u32 ext_phy_addr)
{
	u16 phy_identifier;
	u16 phy_model;
	u8 phytype;

	/* Get the PHY Identifier and Model number */
	XAxiEthernet_PhyRead(xaxiemacp, ext_phy_addr, PHY_IDENTIFIER_1_REG, &phy_identifier);
	XAxiEthernet_PhyRead(xaxiemacp, ext_phy_addr, PHY_IDENTIFIER_2_REG, &phy_model);

	xil_printf("PHY address (%d), ID (0x%04X), Model (0x%04X)\r\n",ext_phy_addr,phy_identifier,phy_model);

/* Depending upon what manufacturer PHY is connected, a different mask is
 * needed to determine the specific model number of the PHY. */
	if (phy_identifier == TI_PHY_IDENTIFIER) {
		phy_model = phy_model & TI_PHY_DP83867_MODEL;
		phytype = XAxiEthernet_GetPhysicalInterface(xaxiemacp);

		if (phy_model == TI_PHY_DP83867_MODEL && phytype == XAE_PHY_TYPE_GMII) {
			return get_phy_speed_TI_DP83867_SGMII(xaxiemacp, sgmii_phy_addr, ext_phy_addr);
		}
	}
	else {
	    LWIP_DEBUGF(NETIF_DEBUG, ("XAxiEthernet get_IEEE_phy_speed: Detected PHY with unknown identifier/model.\r\n"));
	}
	return 0;
}

unsigned configure_IEEE_phy_speed(XAxiEthernet *xaxiemacp, u32 sgmii_phy_addr, u32 ext_phy_addr, unsigned speed)
{
	u16 control;
	u16 phy_val;

	XAxiEthernet_PhyRead(xaxiemacp, ext_phy_addr,
				IEEE_CONTROL_REG_OFFSET,
				&control);
	control &= ~IEEE_CTRL_LINKSPEED_1000M;
	control &= ~IEEE_CTRL_LINKSPEED_100M;
	control &= ~IEEE_CTRL_LINKSPEED_10M;

	if (speed == 1000) {
		control |= IEEE_CTRL_LINKSPEED_1000M;
	}

	else if (speed == 100) {
		control |= IEEE_CTRL_LINKSPEED_100M;
		/* Dont advertise PHY speed of 1000 Mbps */
		XAxiEthernet_PhyWrite(xaxiemacp, ext_phy_addr,
					IEEE_1000_ADVERTISE_REG_OFFSET,
					0);
		/* Dont advertise PHY speed of 10 Mbps */
		XAxiEthernet_PhyWrite(xaxiemacp, ext_phy_addr,
				IEEE_AUTONEGO_ADVERTISE_REG,
				ADVERTISE_100);

	}
	else if (speed == 10) {
		control |= IEEE_CTRL_LINKSPEED_10M;
		/* Dont advertise PHY speed of 1000 Mbps */
		XAxiEthernet_PhyWrite(xaxiemacp, ext_phy_addr,
				IEEE_1000_ADVERTISE_REG_OFFSET,
					0);
		/* Dont advertise PHY speed of 100 Mbps */
		XAxiEthernet_PhyWrite(xaxiemacp, ext_phy_addr,
				IEEE_AUTONEGO_ADVERTISE_REG,
				ADVERTISE_10);
	}

	XAxiEthernet_PhyWrite(xaxiemacp, ext_phy_addr,
				IEEE_CONTROL_REG_OFFSET,
				control | IEEE_CTRL_RESET_MASK);

	if (XAxiEthernet_GetPhysicalInterface(xaxiemacp) ==
			XAE_PHY_TYPE_SGMII) {
		control &= (~PHY_R0_ISOLATE);
		XAxiEthernet_PhyWrite(xaxiemacp,
				XPAR_AXIETHERNET_0_PHYADDR,
				IEEE_CONTROL_REG_OFFSET,
				control | IEEE_CTRL_AUTONEGOTIATE_ENABLE);
	}

	{
		volatile int wait;
		for (wait=0; wait < 100000; wait++);
		for (wait=0; wait < 100000; wait++);
	}
	return 0;
}

unsigned enable_sgmii_clk (XAxiEthernet *xaxiemacp, u32 phy_addr)
{
	u16 control;
	u16 temp;
	u16 phyregtemp;

	xil_printf("Enabling SGMII clock output of port 3 PHY\r\n");

	/* Enable SGMII Clock */
	XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, TI_PHY_REGCR,
			      TI_PHY_REGCR_DEVAD_EN);
	XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, TI_PHY_ADDDR,
			      TI_PHY_SGMIITYPE);
	XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, TI_PHY_REGCR,
			      TI_PHY_REGCR_DEVAD_EN | TI_PHY_REGCR_DEVAD_DATAEN);
	XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, TI_PHY_ADDDR,
			      TI_PHY_SGMIICLK_EN);

	xil_printf("SGMII clock enabled\n\r");

	return 0;

}

unsigned init_axi_ethernet_0()
{
	XAxiEthernet_Config *mac_config;

	xil_printf("Initializing axi_ethernet_0 for MDIO interface\n\r");

	axi_ethernet_0 = mem_malloc(sizeof *axi_ethernet_0);
	if (axi_ethernet_0 == NULL) {
		xil_printf("Out of memory\n\r");
		return ERR_MEM;
	}

	/* obtain config of this emac */
	mac_config = xaxiemac_lookup_config((unsigned)XPAR_AXI_ETHERNET_0_BASEADDR);

	XAxiEthernet_Initialize(axi_ethernet_0, mac_config,
				mac_config->BaseAddress);

	XAxiEthernet_Reset(axi_ethernet_0);
	xil_printf("MDIO ready\n\r");

	return 0;
}


unsigned phy_setup_axiemac (XAxiEthernet *xaxiemacp)
{
	unsigned link_speed = 1000;
	XAxiEthernet *xaxiemacp_p0;
	u32 sgmii_phy_addr = 0;
	u32 sgmii_p3_rx_phy_addr;
	u32 sgmii_p3_tx_phy_addr;
	u32 ext_phy_addr;
	u32 port_num;

	if (XAxiEthernet_GetPhysicalInterface(xaxiemacp) ==
						XAE_PHY_TYPE_RGMII_1_3) {
		; /* Add PHY initialization code for RGMII 1.3 */
	} else if (XAxiEthernet_GetPhysicalInterface(xaxiemacp) ==
						XAE_PHY_TYPE_RGMII_2_0) {
		; /* Add PHY initialization code for RGMII 2.0 */
	} else if ((XAxiEthernet_GetPhysicalInterface(xaxiemacp) ==
						XAE_PHY_TYPE_SGMII) || (XAxiEthernet_GetPhysicalInterface(xaxiemacp) ==
						XAE_PHY_TYPE_GMII)) {
#ifdef  CONFIG_LINKSPEED_AUTODETECT
		// If the enabled port is not port 0, then we need to initialize
		// axi_ethernet_0 so that we can use it's MDIO interface
		if(xaxiemacp->Config.BaseAddress != XPAR_AXI_ETHERNET_0_BASEADDR){
			// Initialize axi_ethernet_0 which is used for the MDIO interface
			init_axi_ethernet_0();
			xaxiemacp_p0 = axi_ethernet_0;
		}
		// If the enabled port is port 0, then GEM0 is already initialized
		else {
			xaxiemacp_p0 = xaxiemacp;
		}

		// Determine the correct PHY addresses for the enabled port
		if(xaxiemacp->Config.BaseAddress == XPAR_AXI_ETHERNET_0_BASEADDR){
			sgmii_phy_addr = PORT0_SGMII_PHYADDR;
			ext_phy_addr = PORT0_EXT_PHY_ADDR;
			port_num = 0;
		}
		else if(xaxiemacp->Config.BaseAddress == XPAR_AXI_ETHERNET_1_BASEADDR){
			sgmii_phy_addr = PORT1_SGMII_PHYADDR;
			ext_phy_addr = PORT1_EXT_PHY_ADDR;
			port_num = 1;
		}
		else if(xaxiemacp->Config.BaseAddress == XPAR_AXI_ETHERNET_2_BASEADDR){
			sgmii_phy_addr = PORT2_SGMII_PHYADDR;
			ext_phy_addr = PORT2_EXT_PHY_ADDR;
			port_num = 2;
		}
		else{
			ext_phy_addr = PORT3_EXT_PHY_ADDR;
			sgmii_p3_rx_phy_addr = PORT3_SGMII_RX_PHYADDR;
			sgmii_p3_tx_phy_addr = PORT3_SGMII_TX_PHYADDR;
			port_num = 3;
		}

		xil_printf("Enabled port: %d, Ext PHY addr: %d\r\n", port_num, ext_phy_addr);

		// Enable 625MHz SGMII clock
		enable_sgmii_clk(xaxiemacp_p0,PORT3_EXT_PHY_ADDR);

		// Enable SGMII auto negotiation
		u32 phy_wr_data = IEEE_CTRL_AUTONEGOTIATE_ENABLE |
					IEEE_CTRL_LINKSPEED_1000M;
		phy_wr_data &= (~PHY_R0_ISOLATE);

		XAxiEthernet_PhyWrite(xaxiemacp_p0,
				sgmii_phy_addr,
				IEEE_CONTROL_REG_OFFSET,
				phy_wr_data);
#endif
	} else if (XAxiEthernet_GetPhysicalInterface(xaxiemacp) ==
						XAE_PHY_TYPE_1000BASE_X) {
		; /* Add PHY initialization code for 1000 Base-X */
	}
/* set PHY <--> MAC data clock */
#ifdef  CONFIG_LINKSPEED_AUTODETECT
	// If port 3 is enabled, then we will manually configure it to 1Gbps
	if(port_num == 3){
		link_speed = get_IEEE_phy_speed(xaxiemacp_p0, 0, ext_phy_addr);
		//configure_IEEE_phy_speed_port3(xemacpsp_gem0, ext_phy_addr, sgmii_p3_rx_phy_addr, sgmii_p3_tx_phy_addr, link_speed);
	}
	// For ports 0-2 we will let the link auto-negotiate a speed
	else{
		link_speed = get_IEEE_phy_speed(xaxiemacp_p0, sgmii_phy_addr, ext_phy_addr);
	}
	xil_printf("Link speed: %d\r\n", link_speed);
#elif	defined(CONFIG_LINKSPEED1000)
	link_speed = 1000;
	configure_IEEE_phy_speed(xaxiemacp_p0, sgmii_phy_addr, ext_phy_addr, link_speed);
	xil_printf("link speed: %d\r\n", link_speed);
#elif	defined(CONFIG_LINKSPEED100)
	link_speed = 100;
	configure_IEEE_phy_speed(xaxiemacp_p0, sgmii_phy_addr, ext_phy_addr, link_speed);
	xil_printf("link speed: %d\r\n", link_speed);
#elif	defined(CONFIG_LINKSPEED10)
	link_speed = 10;
	configure_IEEE_phy_speed(xaxiemacp_p0, sgmii_phy_addr, ext_phy_addr, link_speed);
	xil_printf("link speed: %d\r\n", link_speed);
#endif
	return link_speed;
}

static void __attribute__ ((noinline)) AxiEthernetUtilPhyDelay(unsigned int Seconds)
{
#if defined (__MICROBLAZE__)
	static int WarningFlag = 0;

	/* If MB caches are disabled or do not exist, this delay loop could
	 * take minutes instead of seconds (e.g., 30x longer).  Print a warning
	 * message for the user (once).  If only MB had a built-in timer!
	 */
	if (((mfmsr() & 0x20) == 0) && (!WarningFlag)) {
		WarningFlag = 1;
	}

#define ITERS_PER_SEC   (XPAR_CPU_CORE_CLOCK_FREQ_HZ / 6)
    asm volatile ("\n"
			"1:               \n\t"
			"addik r7, r0, %0 \n\t"
			"2:               \n\t"
			"addik r7, r7, -1 \n\t"
			"bneid  r7, 2b    \n\t"
			"or  r0, r0, r0   \n\t"
			"bneid %1, 1b     \n\t"
			"addik %1, %1, -1 \n\t"
			:: "i"(ITERS_PER_SEC), "d" (Seconds));
#else
    sleep(Seconds);
#endif
}

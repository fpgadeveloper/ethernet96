/*
 * Copyright (C) 2010 - 2019 Xilinx, Inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
 * SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
 * OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 *
 * This file is part of the lwIP TCP/IP stack.
 *
 */

#include "netif/xaxiemacif.h"
#include "lwipopts.h"
#include "sleep.h"
#include "xemac_ieee_reg.h"

/* Definitions related to PCS PMA PL IP*/
#define XPAR_GIGE_PCS_PMA_SGMII_CORE_PRESENT 1U

/* Registers for PCS/PMA SGMII core */
#define PHY_CTRL_REG	  						0
#define PHY_STATUS_REG  						1
#define PHY_IDENTIFIER_1_REG					2
#define PHY_IDENTIFIER_2_REG					3

/* Control register masks for PCS/PMA SGMII core */
#define IEEE_CTRL_RESET_MASK                   	0x8000
#define IEEE_CTRL_LOOPBACK_MASK                	0x4000
#define IEEE_CTRL_SPEED_LSB_MASK               	0x2000
#define IEEE_CTRL_AUTONEG_MASK                  0x1000
#define IEEE_CTRL_PWRDOWN_MASK                  0x0800
#define IEEE_CTRL_ISOLATE_MASK                  0x0400
#define IEEE_CTRL_RESTART_AN_MASK               0x0200
#define IEEE_CTRL_DUPLEX_MASK               	0x0100
#define IEEE_CTRL_COLLISION_MASK               	0x0080
#define IEEE_CTRL_SPEED_MSB_MASK               	0x0040
#define IEEE_CTRL_UNIDIRECTIONAL_MASK           0x0020

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
#define TI_PHY_REGCFG4			0x0031
#define TI_PHY_RGMIICTL			0x0032
#define TI_PHY_REGCR_DATA		0x401F
#define TI_PHY_CFG4RESVDBIT7		0x80
#define TI_PHY_CFG4RESVDBIT8		0x100
#define TI_PHY_10M_SGMII_CFG		0x016F

/* TI DP83867 PHY Masks */
#define TI_PHY_CFG2_SPEEDOPT_10EN          0x0040
#define TI_PHY_CFG2_SGMII_AUTONEGEN        0x0080
#define TI_PHY_CFG2_SPEEDOPT_ENH           0x0100
#define TI_PHY_CFG2_SPEEDOPT_CNT           0x0800
#define TI_PHY_CFG2_SPEEDOPT_INTLOW        0x2000
#define TI_PHY_10M_SGMII_RATE_ADAPT		   0x0080
#define TI_PHY_CR_SGMII_EN				   0x0800
#define TI_PHY_CFG4_SGMII_AN_TIMER         0x0060

/* TI DP83867 Datasheet Section 8.6.15 page 57 */
#define TI_DP83867_PHYSTS                             0x11
#define TI_DP83867_PHYSTS_SPEED_SELECTION_MASK        0xC000
#define TI_DP83867_PHYSTS_SPEED_SELECTION_1000_MBPS   0x8000
#define TI_DP83867_PHYSTS_SPEED_SELECTION_100_MBPS    0x4000
#define TI_DP83867_PHYSTS_SPEED_SELECTION_10_MBPS     0x0000
#define TI_DP83867_PHYSTS_DUPLEX_FULL                 0x2000
#define TI_DP83867_PHYSTS_LINK_STATUS_UP              0x0400

// PS GPIO defines
// * SGMII core reset driven by pl_resetn0 (GPIO bank 5, bit 31)
// * PHY resets driven by GPIO bank 3, bits 0-3
#define GPIO_DIRM_BANK_0     0xFF0A0204
#define GPIO_DIRM_BANK_1     0xFF0A0244
#define GPIO_DIRM_BANK_2     0xFF0A0284
#define GPIO_DIRM_BANK_3     0xFF0A02C4
#define GPIO_DIRM_BANK_4     0xFF0A0304
#define GPIO_DIRM_BANK_5     0xFF0A0344
#define GPIO_OPEN_BANK_0     0xFF0A0208
#define GPIO_OPEN_BANK_1     0xFF0A0248
#define GPIO_OPEN_BANK_2     0xFF0A0288
#define GPIO_OPEN_BANK_3     0xFF0A02C8
#define GPIO_OPEN_BANK_4     0xFF0A0308
#define GPIO_OPEN_BANK_5     0xFF0A0348
#define GPIO_DATA_BANK_0     0XFF0A0040
#define GPIO_DATA_BANK_1     0XFF0A0044
#define GPIO_DATA_BANK_2     0XFF0A0048
#define GPIO_DATA_BANK_3     0XFF0A004C
#define GPIO_DATA_BANK_4     0XFF0A0050
#define GPIO_DATA_BANK_5     0XFF0A0054
#define GPIO_EMIO_0_MASK     0x00000001
#define GPIO_EMIO_1_MASK     0x00000002
#define GPIO_EMIO_2_MASK     0x00000004
#define GPIO_EMIO_3_MASK     0x00000008
#define GPIO_PL_RESETN0_MASK 0x80000000
#define GPIO_PL_RESETN1_MASK 0x40000000
#define GPIO_PL_RESETN2_MASK 0x20000000

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

// External PHY addresses on 96B Quad Ethernet Mezzanine
const u16 extphyaddr[4] = {0x1,0x3,0xC,0xF};
// SGMII PHY addresses determined in Vivado design
const u16 sgmiiphyaddr[5] = {0x2,0x4,0xD,0x10,0x11};

static void __attribute__ ((noinline)) AxiEthernetUtilPhyDelay(unsigned int Seconds);

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

unsigned ps_gpio_set(u32 bank,u32 mask,u32 value)
{
	const u32 dirm[6] = {GPIO_DIRM_BANK_0,GPIO_DIRM_BANK_1,GPIO_DIRM_BANK_2,
			GPIO_DIRM_BANK_3,GPIO_DIRM_BANK_4,GPIO_DIRM_BANK_5};
	const u32 open[6] = {GPIO_OPEN_BANK_0,GPIO_OPEN_BANK_1,GPIO_OPEN_BANK_2,
			GPIO_OPEN_BANK_3,GPIO_OPEN_BANK_4,GPIO_OPEN_BANK_5};
	const u32 data[6] = {GPIO_DATA_BANK_0,GPIO_DATA_BANK_1,GPIO_DATA_BANK_2,
			GPIO_DATA_BANK_3,GPIO_DATA_BANK_4,GPIO_DATA_BANK_5};

	u32_t reg = 0;
	// Set as outputs
	reg = *(volatile u32_t *)(dirm[bank]);
	reg |= mask;
	*(volatile u32_t *)(dirm[bank]) = reg;
	// Enable outputs
	reg = *(volatile u32_t *)(open[bank]);
	reg |= mask;
	*(volatile u32_t *)(open[bank]) = reg;
	// Set to value
	reg = *(volatile u32_t *)(data[bank]);
	reg |= (value & mask);
	reg &= ~(~value & mask);
	*(volatile u32_t *)(data[bank]) = reg;
	return 0;
}

unsigned int get_phy_negotiated_speed (XAxiEthernet *xaxiemacp, u32 phy_addr)
{
	u16 control;
	u16 status;
	u16 partner_capabilities;
	u16 partner_capabilities_1000;
	u16 phylinkspeed;
	u16 temp;

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
		xil_printf("get_IEEE_phy_speed(): Invalid speed bit value (0x%04X), Defaulting to Speed = 10 Mbps\r\n",temp);
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

unsigned get_IEEE_phy_speed(XAxiEthernet *xaxiemacp, u32 sgmii_phy_addr, u32 ext_phy_addr)
{
	u16 phy_identifier;
	u16 phy_model;
	u32 link_speed;
	u16 physts;
	u16 status;
	u16 control;

	/* Make sure that the PHY model is correct */
	XAxiEthernet_PhyRead(xaxiemacp, ext_phy_addr, PHY_IDENTIFIER_1_REG, &phy_identifier);
	XAxiEthernet_PhyRead(xaxiemacp, ext_phy_addr, PHY_IDENTIFIER_2_REG, &phy_model);

	if ((phy_identifier != TI_PHY_IDENTIFIER) ||
			(phy_model != TI_PHY_DP83867_MODEL)) {
		xil_printf("Incorrect PHY ID (0x%04X) or PHY model (0x%04X) for TI DP83867\r\n");
		return(0);
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
		xil_printf("1000 Mbps ");
		link_speed = 1000;
	}
	else if( (physts & TI_DP83867_PHYSTS_SPEED_SELECTION_MASK) == TI_DP83867_PHYSTS_SPEED_SELECTION_100_MBPS ) {
		xil_printf("100 Mbps ");
		link_speed = 100;
	}
	else {
		xil_printf("10 Mbps "); /* TODO: should check for corner case of 0xC000... */
		link_speed = 10;
	}
	if( physts & TI_DP83867_PHYSTS_DUPLEX_FULL )
		xil_printf("Full duplex\r\n");
	else
		xil_printf("Half duplex\r\n");

	// If port 3 enabled, then just return the external PHYs negotiated speed
	if(sgmii_phy_addr == 0)
		return(link_speed);
	// Otherwise go on to check the SGMII core's negotiated speed
	else
		return get_phy_negotiated_speed(xaxiemacp, sgmii_phy_addr);
}

unsigned configure_IEEE_phy_speed(XAxiEthernet *xaxiemacp, u32 sgmii_phy_addr, u32 ext_phy_addr, unsigned speed)
{
	u16 control;

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
		/* Don't advertise PHY speed of 1000 Mbps */
		XAxiEthernet_PhyWrite(xaxiemacp, ext_phy_addr,
					IEEE_1000_ADVERTISE_REG_OFFSET,
					0);
		/* Don't advertise PHY speed of 10 Mbps */
		XAxiEthernet_PhyWrite(xaxiemacp, ext_phy_addr,
				IEEE_AUTONEGO_ADVERTISE_REG,
				ADVERTISE_100);

	}
	else if (speed == 10) {
		control |= IEEE_CTRL_LINKSPEED_10M;
		/* Don't advertise PHY speed of 1000 Mbps */
		XAxiEthernet_PhyWrite(xaxiemacp, ext_phy_addr,
				IEEE_1000_ADVERTISE_REG_OFFSET,
					0);
		/* Don't advertise PHY speed of 100 Mbps */
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

static void init_dp83867_phy(XAxiEthernet *xaxiemacp, u32_t phy_addr)
{
	u16_t control;
	/*
	 * There are a few things that need to be configured in the
	 * DP83867 PHY for optimal operation:
	 * - Enable 10Mbps operation (clear bit 7 of register 0x016F)
	 * - Set SGMII Auto-negotiation timer to 11ms
	 * - Disable RGMII
	 */
	// Enable 10Mbps operation
	XAxiEthernet_PhyReadExtended(xaxiemacp, phy_addr, TI_PHY_10M_SGMII_CFG, &control);
	control &= ~(TI_PHY_10M_SGMII_RATE_ADAPT);
	XAxiEthernet_PhyWriteExtended(xaxiemacp, phy_addr, TI_PHY_10M_SGMII_CFG, control);

	// Set SGMII autonegotiation timer to 11ms
	XAxiEthernet_PhyReadExtended(xaxiemacp, phy_addr, TI_PHY_REGCFG4, &control);
	control |= TI_PHY_CFG4_SGMII_AN_TIMER;
	XAxiEthernet_PhyWriteExtended(xaxiemacp, phy_addr, TI_PHY_REGCFG4, control);

	// Disable RGMII
	XAxiEthernet_PhyWriteExtended(xaxiemacp, phy_addr, TI_PHY_RGMIICTL, 0x0);
}

static u32_t init_hardware(XAxiEthernet *xaxiemacp)
{
	u16_t control;
	u32 i;

	// Assert reset of the SGMII core (active low)
	ps_gpio_set(5,GPIO_PL_RESETN1_MASK,0x0);

	// Hardware Reset the external PHY for port 3 - connected to PL_RESETN2
  // AXI Ethernet phy_rst_n output resets the other PHYs 0,1 and 2
	ps_gpio_set(5,GPIO_PL_RESETN2_MASK,0x00000000);
	usleep(10000);
	ps_gpio_set(5,GPIO_PL_RESETN2_MASK,GPIO_PL_RESETN2_MASK);
	usleep(5000);

	// Make sure that we can read from all of the TI DP83867 PHYs
	for(i = 0; i<4; i++){
		XAxiEthernet_PhyRead(xaxiemacp, extphyaddr[i], PHY_IDENTIFIER_1_REG, &control);
		if(control != PHY_TI_IDENTIFIER) {
			xil_printf("init_hardware: ERROR: PHY @ %d returned bad ID 0x%04X.\r\n",extphyaddr[i],control);
			return(1);
		}
	}

	// Enable the 625MHz clock from port 3's PHY
	xil_printf("Enabling SGMII clock output of port 3 PHY\r\n");
	XAxiEthernet_PhyReadExtended(xaxiemacp,extphyaddr[3],TI_PHY_SGMIITYPE,&control);
	control |= TI_PHY_SGMIICLK_EN;
	XAxiEthernet_PhyWriteExtended(xaxiemacp,extphyaddr[3],TI_PHY_SGMIITYPE,control);
	xil_printf("SGMII clock enabled\n\r");
	usleep(500);

	// Release reset of the SGMII core (active low)
	ps_gpio_set(5,GPIO_PL_RESETN1_MASK,GPIO_PL_RESETN1_MASK);

	// Configure the SGMII cores
	// (disable ISOLATE, auto-neg enable, full duplex, 1Gbps)
	for(i = 0; i<3; i++){
		// Ports 0-2 use SGMII auto-negotiation
		XAxiEthernet_PhyWrite(xaxiemacp, sgmiiphyaddr[i], PHY_CTRL_REG,
				IEEE_CTRL_DUPLEX_MASK | IEEE_CTRL_SPEED_MSB_MASK |
				IEEE_CTRL_AUTONEG_MASK);
	}
	for(i = 3; i<5; i++){
		// Port 3 does not use SGMII auto-negotiation
		XAxiEthernet_PhyWrite(xaxiemacp, sgmiiphyaddr[i], PHY_CTRL_REG,
				IEEE_CTRL_DUPLEX_MASK | IEEE_CTRL_SPEED_MSB_MASK |
				IEEE_CTRL_UNIDIRECTIONAL_MASK);
	}

	// Initialize all 4x TI DP83867 PHYs
	for(i = 0; i<4; i++){
		init_dp83867_phy(xaxiemacp,extphyaddr[i]);
	}

	// Disable SGMII auto-negotiation in the external PHY of port 3
	XAxiEthernet_PhyRead(xaxiemacp, extphyaddr[3], TI_PHY_CFGR2, &control);
	control &= ~TI_PHY_CFG2_SGMII_AUTONEGEN;
	XAxiEthernet_PhyWrite(xaxiemacp, extphyaddr[3], TI_PHY_CFGR2, control);

	return(0);
}

/*
 * sgmii_phy_set_link_speed: Set the link speed of the PCS/PMA SGMII core
 *
 * This function can be used to set the link speed of the PCS/PMA or
 * SGMII core when SGMII auto-negotiation is disabled. To use the
 * function, first wait until the external PHY has negotiated a link,
 * then read the negotiated link speed over the MDIO bus, then call
 * this function with the PHY address of the SGMII IP core to configure,
 * and the link speed (1000, 100 or 10).
 *
 */
void sgmii_phy_set_link_speed(XAxiEthernet *xaxiemacp, u32 phy_addr, u32 link_speed)
{
	u16 control;

	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_CONTROL_REG_OFFSET, &control);

	if(link_speed == 1000){
		control |= IEEE_CTRL_SPEED_MSB_MASK;
		control &= ~IEEE_CTRL_SPEED_LSB_MASK;
	}
	else if(link_speed == 100){
		control &= ~IEEE_CTRL_SPEED_MSB_MASK;
		control |= IEEE_CTRL_SPEED_LSB_MASK;
	}
	else{
		control &= ~IEEE_CTRL_SPEED_MSB_MASK;
		control &= ~IEEE_CTRL_SPEED_LSB_MASK;
	}

	XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, IEEE_CONTROL_REG_OFFSET, control);
}

unsigned phy_setup_axiemac (XAxiEthernet *xaxiemacp)
{
	unsigned link_speed = 1000;
	u32 port_num;

#ifdef  CONFIG_LINKSPEED_AUTODETECT
	// Initialize the hardware
	init_hardware(xaxiemacp);

	// Determine the enabled port number
	if(xaxiemacp->Config.BaseAddress == XPAR_AXI_ETHERNET_0_BASEADDR){
		port_num = 0;
	}
	else if(xaxiemacp->Config.BaseAddress == XPAR_AXI_ETHERNET_1_BASEADDR){
		port_num = 1;
	}
	else if(xaxiemacp->Config.BaseAddress == XPAR_AXI_ETHERNET_2_BASEADDR){
		port_num = 2;
	}
	else{
		port_num = 3;
	}

	xil_printf("Enabled port: %d, Ext PHY addr: %d\r\n", port_num, extphyaddr[port_num]);

	// If port 3 is enabled, we read link speed from external PHY
	// then configure the PCS/PMA SGMII IP core with that link speed
	if(port_num == 3){
		link_speed = get_IEEE_phy_speed(xaxiemacp, 0, extphyaddr[port_num]);
		sgmii_phy_set_link_speed(xaxiemacp,sgmiiphyaddr[3],link_speed);
		sgmii_phy_set_link_speed(xaxiemacp,sgmiiphyaddr[4],link_speed);
	}
	// For ports 0-2 we can read link speed from either the external PHY
	// or the PCS/PMA or SGMII core
	else{
		link_speed = get_IEEE_phy_speed(xaxiemacp, sgmiiphyaddr[port_num], extphyaddr[port_num]);
	}
#elif	defined(CONFIG_LINKSPEED1000)
	link_speed = 1000;
	configure_IEEE_phy_speed(xaxiemacp, sgmii_phy_addr, extphyaddr[port_num], link_speed);
	xil_printf("link speed: %d\r\n", link_speed);
#elif	defined(CONFIG_LINKSPEED100)
	link_speed = 100;
	configure_IEEE_phy_speed(xaxiemacp, sgmii_phy_addr, extphyaddr[port_num], link_speed);
	xil_printf("link speed: %d\r\n", link_speed);
#elif	defined(CONFIG_LINKSPEED10)
	link_speed = 10;
	configure_IEEE_phy_speed(xaxiemacp, sgmii_phy_addr, extphyaddr[port_num], link_speed);
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

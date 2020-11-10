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

/*****************************************************************************
* This file xemacpsif_physpeed.c implements functionalities to:
* - Detect the available PHYs connected to a MAC
* - Negotiate speed
* - Configure speed
* - Configure the SLCR registers for the negotiated speed
*
* In a typical use case, users of the APIs implemented in this file need to
* do the following.
* - Call the API detect_phy. It probes for the available PHYs connected to a MAC.
*   The MACs can be Emac0 (XPAR_XEMACPS_0_BASEADDR, 0xE000B000) or Emac1
*   (XPAR_XEMACPS_0_BASEADDR, 0xE000C000). It populates an array to notify
*   about the detected PHYs. The array phymapemac0 is used for Emac0 and
*   phymapemac1 is for Emac1.
* - The users need to parse the corresponding arrays, phymapemac0 or phymapemac1
*   to know the available PHYs for a MAC. The users then need to call
*   phy_setup_emacps to setup the PHYs for proper speed setting. The API
*   phy_setup_emacps should be called with the PHY address for which the speed
*   needs to be negotiated or configured. In a specific use case, if 2 PHYs are
*   connected to Emac0 with addresses of 7 and 11, then users get these address
*   details from phymapemac0 (after calling detect_phy) and then call
*   phy_setup_emacps twice, with ab address of 7 and 11.
* - Points to note: The MAC can operate at only one speed. If a MAC is connected
*   to multiple PHYs, then all PHYs must negotiate and configured for the same
*   speed.
* - This file implements static functions to set proper SLCR clocks. As stated
*   above, all PHYs connected to a PHY must operate at same speed and the SLCR
*   clock will be setup accordingly.
*
* This file implements the following PHY types.
* - The standard RGMII.
* - It provides support for GMII to RGMII converter Xilinx IP. This Xilinx IP
*   sits on the MDIO bus with a predefined PHY address. This IP exposes register
*   that needs to be programmed with the negotiated speed.
*   For example, in a typical design, the Emac0 or Emac1 exposes GMII interface.
*   The user can then use the Xilinx IP that converts GMII to RGMII.
*   The external PHY (most typically Marvell 88E1116R) negotiates for speed
*   with the remote PHY. The implementation in this file then programs the
*   Xilinx IP with this negotiated speed. The Xilinx IP has a predefined IP
*   address exposed through xparameters.h
* - The SGMII and 1000 BaseX PHY interfaces.
*   If the PHY interface is SGMII or 1000 BaseX a separate "get_IEEE_phy_speed"
*   is used which is different from standard RGMII "get_IEEE_phy_speed".
*   The 1000 BaseX always operates at 1000 Mbps. The SGMII interface can
*   negotiate speed accordingly.
*   For SGMII or 1000 BaseX interfaces, the detect_phy should not be called.
*   The phy addresses for these interfaces are fixed at the design time.
*
* Point to note:
* A MAC can not be connected to PHYs where there is a mix between
* SGMII or 1000 Basex or GMII/MII/RGMII.
* In a typical multiple PHY designs, it is expected that the PHYs connected
* will be RGMII or GMII.
*
* The users can choose not to negotiate speed from lwip settings GUI.
* If they opt to choose a particular PHY speed, then the PHY will hard code
* the speed to operate only at the corresponding speed. It will not advertise
* any other speeds. It is users responsibility to ensure that the remote PHY
* supports the speed programmed through the lwip gui.
*
* The following combination of MDIO/PHY are supported:
* - Multiple PHYs connected to the MDIO bus of a MAC. If Emac0 MDIO is connected
*   to single/multiple PHYs, it is supported. Similarly Emac1 MDIO connected to
*   single/multiple PHYs is supported.
* - A design where both the interfaces are present and are connected to their own
*   MDIO bus is supported.
*
* The following MDIO/PHY setup is not supported:
* - A design has both the MACs present. MDIO bus is available only for one MAC
*   (Emac0 or Emac1). This MDIO bus has multiple PHYs available for both the
*   MACs. The negotiated speed for PHYs sitting on the MDIO bus of one MAC will
*   not be see for the other MAC and hence the speed/SLCR settings of the other
*   MAC cannot be programmed. Hence this kind of design will not work for
*   this implementation.
*
********************************************************************************/

/*
 * Port 3 configuration
 * --------------------
 *
 * The PCS/PMA SGMII core requires that the RX and TX lanes of a single
 * SGMII interface be connected to the same byte group of a bank, with the
 * TX lane placed in the upper or lower nibble, and the RX lane placed in
 * the other nibble.
 *
 * Due to the limitations imposed by the pin assignment of the high-speed
 * expansion port of the Ultra96, port 3 of the 96B Ethernet Mezzanine is
 * connected through two different byte groups of bank 65. For this reason,
 * we have to use two different PCS/PMA SGMII cores, one for the RX lane
 * and another for the TX lane. This separation means that it is not
 * possible for the core to perform auto-negotiation of the SGMII link.
 * The only way for the port 3 SGMII link to function is if we manually
 * configure both PCS/PMA SGMII cores with a predetermined link speed. To
 * do this we must make the following configurations:
 *
 * - Disable SGMII autonegotiation in the external PHY (address 15)
 *   (SGMII speed mode will be forced to the MDI resolved speed)
 * - Disable autonegotiation in the PCS/PMA SGMII cores (addresses 16,17)
 * - Set the link speed to 1Gbps in the PCS/PMA SGMII cores
 * - Enable the unidirectional mask in the PCS/PMA SGMII cores
 *   (this allows the core to transmit even though a valid link has not
 *   been achieved)
 *
 *
 * */

#include "netif/xemacpsif.h"
#include "lwipopts.h"
#include "xparameters_ps.h"
#include "xparameters.h"
#include "xemac_ieee_reg.h"
#include "sleep.h"

#if defined (__aarch64__)
#include "bspconfig.h"
#include "xil_smc.h"
#endif

/* Generic PHY Registers */
#define IEEE_PHY_CONTROL_REG                                    0x00
#define IEEE_PHY_STATUS_REG                                     0x01
#define IEEE_PHY_STATUS_AUTO_NEGOTIATION_COMPLETE            (0x0020)
#define IEEE_PHY_DETECT_1_REG                                   0x02
#define IEEE_PHY_DETECT_2_REG                                   0x03

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

#define PHY_XILINX_PCS_PMA_ID1			0x0174
#define PHY_XILINX_PCS_PMA_ID2			0x0C00

#define XEMACPS_GMII2RGMII_SPEED1000_FD		0x140
#define XEMACPS_GMII2RGMII_SPEED100_FD		0x2100
#define XEMACPS_GMII2RGMII_SPEED10_FD		0x100
#define XEMACPS_GMII2RGMII_REG_NUM			0x10

#define PHY_REGCR		0x0D
#define PHY_ADDAR		0x0E
#define PHY_RGMIIDCTL	0x86
#define PHY_RGMIICTL	0x32
#define PHY_STS			0x11
#define PHY_TI_CR		0x10
#define PHY_TI_CFG4		0x31

#define PHY_REGCR_ADDR	0x001F
#define PHY_REGCR_DATA	0x401F
#define PHY_TI_CRVAL	0x5048
#define PHY_TI_CFG4RESVDBIT7	0x80

/* Frequency setting */
#define SLCR_LOCK_ADDR			(XPS_SYS_CTRL_BASEADDR + 0x4)
#define SLCR_UNLOCK_ADDR		(XPS_SYS_CTRL_BASEADDR + 0x8)
#define SLCR_GEM0_CLK_CTRL_ADDR	(XPS_SYS_CTRL_BASEADDR + 0x140)
#define SLCR_GEM1_CLK_CTRL_ADDR	(XPS_SYS_CTRL_BASEADDR + 0x144)
#define SLCR_GEM_SRCSEL_EMIO	0x40
#define SLCR_LOCK_KEY_VALUE 	0x767B
#define SLCR_UNLOCK_KEY_VALUE	0xDF0D
#define SLCR_ADDR_GEM_RST_CTRL	(XPS_SYS_CTRL_BASEADDR + 0x214)
#define EMACPS_SLCR_DIV_MASK	0xFC0FC0FF

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

/* TI DP83867 PHY Registers */
#define DP83867_R32_RGMIICTL1					0x32
#define DP83867_R86_RGMIIDCTL					0x86

#define PHY_DETECT_REG  						1
#define PHY_IDENTIFIER_1_REG					2
#define PHY_IDENTIFIER_2_REG					3
#define TI_PHY_REGCR			0xD
#define TI_PHY_ADDDR			0xE
#define TI_PHY_PHYCTRL			0x10
#define TI_PHY_CFGR2			0x14
#define TI_PHY_SGMIITYPE		0xD3
#define TI_PHY_REGCR_DEVAD_EN		0x001F
#define TI_PHY_REGCR_DEVAD_DATAEN	0x4000
#define TI_PHY_CFGR2_MASK		0x003F
#define TI_PHY_REGCFG4			0x0031
#define TI_PHY_RGMIICTL			0x0032
#define TI_PHY_REGCR_DATA		0x401F
#define TI_PHY_CFG4RESVDBIT7		0x80
#define TI_PHY_CFG4RESVDBIT8		0x100
#define TI_PHY_10M_SGMII_CFG		0x016F

/* TI DP83867 PHY masks */
#define PHY_DETECT_MASK 					0x1808
#define TI_PHY_IDENTIFIER					0x2000
#define TI_PHY_DP83867_MODEL				0xA231
#define TI_PHY_SGMIICLK_EN					0x4000
#define TI_PHY_CFGR2_SGMII_AUTONEG_EN		0x0080
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

// External PHY addresses on 96B Quad Ethernet Mezzanine
const u16 extphyaddr[4] = {0x1,0x3,0xC,0xF};
// SGMII PHY addresses determined in Vivado design
const u16 sgmiiphyaddr[5] = {0x2,0x4,0xD,0x10,0x11};

u32_t phymapemac0[32];
u32_t phymapemac1[32];

#if defined (PCM_PMA_CORE_PRESENT) || defined (CONFIG_LINKSPEED_AUTODETECT)
static u32_t get_IEEE_phy_speed(XEmacPs *xemacpsp, u32_t ext_phy_addr, u32_t sgmii_phy_addr);
static u32_t configure_IEEE_phy_speed_port3(XEmacPs *xemacpsp, u32_t ext_phy_addr, u32_t rx_phy_addr, u32_t tx_phy_addr, u32_t speed);
#endif
static void SetUpSLCRDivisors(u32_t mac_baseaddr, s32_t speed);
#if defined (CONFIG_LINKSPEED1000) || defined (CONFIG_LINKSPEED100) \
	|| defined (CONFIG_LINKSPEED10)
static u32_t configure_IEEE_phy_speed(XEmacPs *xemacpsp, u32_t phy_addr, u32_t speed);
#endif

/* Extended Read function for PHY registers above 0x001F */
static void XEmacPs_PhyReadExtended(XEmacPs *xemacpsp, u16 phy_addr, u16 reg, u16 *pvalue)
{
	u16 PhyAddr = phy_addr & 0x001f;
	XEmacPs_PhyWrite(xemacpsp, PhyAddr, PHY_REGCR, 0x001f );
	XEmacPs_PhyWrite(xemacpsp, PhyAddr, PHY_ADDAR, reg );
	XEmacPs_PhyWrite(xemacpsp, PhyAddr, PHY_REGCR, 0x401f);
	XEmacPs_PhyRead(xemacpsp, PhyAddr, PHY_ADDAR, pvalue);
}

/* Extended Write function for PHY registers above 0x001F */
static void XEmacPs_PhyWriteExtended(XEmacPs *xemacpsp, u16 phy_addr, u16 reg, u16 value)
{
	u16 PhyAddr = phy_addr & 0x001f;
	u16 tmp;
	XEmacPs_PhyWrite(xemacpsp, PhyAddr, PHY_REGCR, 0x001f );
	XEmacPs_PhyWrite(xemacpsp, PhyAddr, PHY_ADDAR, reg );
	XEmacPs_PhyWrite(xemacpsp, PhyAddr, PHY_REGCR, 0x401f);
	XEmacPs_PhyWrite(xemacpsp, PhyAddr, PHY_ADDAR, value);
	/* Read-back and verify */
	XEmacPs_PhyRead(xemacpsp, PhyAddr, PHY_ADDAR, &tmp);
	if( tmp != value )
		xil_printf("ERROR: PHYWriteExtended read-back verification failed!\r\n");
}

unsigned ps_gpio_set(u32 bank,u32 mask,u32 value)
{
	const u32_t dirm[6] = {GPIO_DIRM_BANK_0,GPIO_DIRM_BANK_1,GPIO_DIRM_BANK_2,
			GPIO_DIRM_BANK_3,GPIO_DIRM_BANK_4,GPIO_DIRM_BANK_5};
	const u32_t open[6] = {GPIO_OPEN_BANK_0,GPIO_OPEN_BANK_1,GPIO_OPEN_BANK_2,
			GPIO_OPEN_BANK_3,GPIO_OPEN_BANK_4,GPIO_OPEN_BANK_5};
	const u32_t data[6] = {GPIO_DATA_BANK_0,GPIO_DATA_BANK_1,GPIO_DATA_BANK_2,
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

static void init_dp83867_phy(XEmacPs *xemacpsp, u32_t phy_addr)
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
	XEmacPs_PhyReadExtended(xemacpsp, phy_addr, TI_PHY_10M_SGMII_CFG, &control);
	control &= ~(TI_PHY_10M_SGMII_RATE_ADAPT);
	XEmacPs_PhyWriteExtended(xemacpsp, phy_addr, TI_PHY_10M_SGMII_CFG, control);

	// Set SGMII autonegotiation timer to 11ms
	XEmacPs_PhyReadExtended(xemacpsp, phy_addr, TI_PHY_REGCFG4, &control);
	control |= TI_PHY_CFG4_SGMII_AN_TIMER;
	XEmacPs_PhyWriteExtended(xemacpsp, phy_addr, TI_PHY_REGCFG4, control);

	// Disable RGMII
	XEmacPs_PhyWriteExtended(xemacpsp, phy_addr, TI_PHY_RGMIICTL, 0x0);
}

static u32_t init_hardware(XEmacPs *xemacpsp)
{
	u16_t control;
	u32 i;

	// Assert reset of the SGMII core (active low)
	ps_gpio_set(5,GPIO_PL_RESETN0_MASK,0x0);

	// Hardware Reset the external PHYs
	ps_gpio_set(3,GPIO_EMIO_0_MASK | GPIO_EMIO_1_MASK | GPIO_EMIO_2_MASK | GPIO_EMIO_3_MASK,0x00000000);
	usleep(10000);
	ps_gpio_set(3,GPIO_EMIO_0_MASK | GPIO_EMIO_1_MASK | GPIO_EMIO_2_MASK | GPIO_EMIO_3_MASK,0x0000000F);
	usleep(5000);

	// Make sure that we can read from all of the TI DP83867 PHYs
	for(i = 0; i<4; i++){
		XEmacPs_PhyRead(xemacpsp, extphyaddr[i], PHY_IDENTIFIER_1_REG, &control);
		if(control != TI_PHY_IDENTIFIER) {
			xil_printf("init_hardware: ERROR: PHY @ %d returned bad ID 0x%04X.\r\n",extphyaddr[i],control);
			return(1);
		}
	}

	// Enable the 625MHz clock from port 3's PHY
	xil_printf("Enabling SGMII clock output of port 3 PHY\r\n");
	XEmacPs_PhyReadExtended(xemacpsp,extphyaddr[3],TI_PHY_SGMIITYPE,&control);
	control |= TI_PHY_SGMIICLK_EN;
	XEmacPs_PhyWriteExtended(xemacpsp,extphyaddr[3],TI_PHY_SGMIITYPE,control);
	xil_printf("SGMII clock enabled\n\r");
	usleep(500);

	// Release reset of the SGMII core (active low)
	ps_gpio_set(5,GPIO_PL_RESETN0_MASK,GPIO_PL_RESETN0_MASK);

	// Configure the SGMII cores
	// (disable ISOLATE, auto-neg enable, full duplex, 1Gbps)
	for(i = 0; i<3; i++){
		// Ports 0-2 use SGMII auto-negotiation
		XEmacPs_PhyWrite(xemacpsp, sgmiiphyaddr[i], PHY_CTRL_REG,
				IEEE_CTRL_DUPLEX_MASK | IEEE_CTRL_SPEED_MSB_MASK |
				IEEE_CTRL_AUTONEG_MASK);
	}
	for(i = 3; i<5; i++){
		// Port 3 does not use SGMII auto-negotiation
		XEmacPs_PhyWrite(xemacpsp, sgmiiphyaddr[i], PHY_CTRL_REG,
				IEEE_CTRL_DUPLEX_MASK | IEEE_CTRL_SPEED_MSB_MASK |
				IEEE_CTRL_UNIDIRECTIONAL_MASK);
	}

	// Initialize all 4x TI DP83867 PHYs
	for(i = 0; i<4; i++){
		init_dp83867_phy(xemacpsp,extphyaddr[i]);
	}

	// Disable SGMII auto-negotiation in the external PHY of port 3
	XEmacPs_PhyRead(xemacpsp, extphyaddr[3], TI_PHY_CFGR2, &control);
	control &= ~TI_PHY_CFG2_SGMII_AUTONEGEN;
	XEmacPs_PhyWrite(xemacpsp, extphyaddr[3], TI_PHY_CFGR2, control);

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
void sgmii_phy_set_link_speed(XEmacPs *xemacpsp, u32 phy_addr, u32 link_speed)
{
	u16 control;

	XEmacPs_PhyRead(xemacpsp, phy_addr, IEEE_CONTROL_REG_OFFSET, &control);

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

	XEmacPs_PhyWrite(xemacpsp, phy_addr, IEEE_CONTROL_REG_OFFSET, control);
}

u32_t phy_setup_emacps (XEmacPs *xemacpsp, u32_t phy_addr)
{
	u32_t link_speed;
	u32 port_num = 0;

	// Initialize the hardware
	init_hardware(xemacpsp);

	// Determine the correct PHY addresses for the enabled port
	if(xemacpsp->Config.BaseAddress == XPAR_XEMACPS_0_BASEADDR){
		port_num = 0;
	}
	else if(xemacpsp->Config.BaseAddress == XPAR_XEMACPS_1_BASEADDR){
		port_num = 1;
	}
	else if(xemacpsp->Config.BaseAddress == XPAR_XEMACPS_2_BASEADDR){
		port_num = 2;
	}
	else if(xemacpsp->Config.BaseAddress == XPAR_XEMACPS_3_BASEADDR){
		port_num = 3;
	}

	xil_printf("Enabled port: %d, Ext PHY addr: %d\r\n", port_num, extphyaddr[port_num]);

	// If port 3 is enabled, we read link speed from external PHY
	// then configure the PCS/PMA SGMII IP core with that link speed
	if(port_num == 3){
		link_speed = get_IEEE_phy_speed(xemacpsp, extphyaddr[port_num], 0);
		sgmii_phy_set_link_speed(xemacpsp,sgmiiphyaddr[3],link_speed);
		sgmii_phy_set_link_speed(xemacpsp,sgmiiphyaddr[4],link_speed);
	}
	// For ports 0-2 we can read link speed from either the external PHY
	// or the PCS/PMA or SGMII core
	else{
		link_speed = get_IEEE_phy_speed(xemacpsp, extphyaddr[port_num], sgmiiphyaddr[port_num]);
	}

	// Set the SLCR divisors according to negotiated link speed
	if (link_speed == 1000)
		SetUpSLCRDivisors(xemacpsp->Config.BaseAddress,1000);
	else if (link_speed == 100)
		SetUpSLCRDivisors(xemacpsp->Config.BaseAddress,100);
	else
		SetUpSLCRDivisors(xemacpsp->Config.BaseAddress,10);

	xil_printf("SGMII Link speed: %d\r\n", link_speed);

	return link_speed;
}

static u32_t get_IEEE_phy_speed(XEmacPs *xemacpsp, u32_t ext_phy_addr, u32_t sgmii_phy_addr)
{
	u16 phy_identifier;
	u16 phy_model;
	u32 link_speed;
	u16_t temp;
	u16_t control;
	u16_t status;
	u16 physts;

	/* Make sure that the PHY model is correct */
	XEmacPs_PhyRead(xemacpsp, ext_phy_addr, PHY_IDENTIFIER_1_REG, &phy_identifier);
	XEmacPs_PhyRead(xemacpsp, ext_phy_addr, PHY_IDENTIFIER_2_REG, &phy_model);

	if ((phy_identifier != TI_PHY_IDENTIFIER) ||
			(phy_model != TI_PHY_DP83867_MODEL)) {
		xil_printf("Incorrect PHY ID (0x%04X) or PHY model (0x%04X) for TI DP83867\r\n");
		return(0);
	}

	xil_printf("Waiting for Link to be up \r\n");
	do
	{
		usleep(100);
		XEmacPs_PhyRead(xemacpsp, ext_phy_addr, IEEE_PHY_STATUS_REG, &status);
	} while( !(status & IEEE_PHY_STATUS_AUTO_NEGOTIATION_COMPLETE) );

	xil_printf("Auto negotiation completed for TI PHY\n\r");
	xil_printf("Link speed: ");

	/* Get link state */
	do
	{
		usleep(100);
		XEmacPs_PhyRead(xemacpsp, ext_phy_addr, TI_DP83867_PHYSTS, &physts);
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

	xil_printf("Start SGMII PHY autonegotiation \r\n");

	XEmacPs_PhyRead(xemacpsp, sgmii_phy_addr, IEEE_CONTROL_REG_OFFSET, &control);
	control |= IEEE_CTRL_AUTONEGOTIATE_ENABLE;
	control |= IEEE_STAT_AUTONEGOTIATE_RESTART;
	control &= IEEE_CTRL_ISOLATE_DISABLE;
	XEmacPs_PhyWrite(xemacpsp, sgmii_phy_addr, IEEE_CONTROL_REG_OFFSET, control);

	xil_printf("Waiting for SGMII PHY to complete autonegotiation.\r\n");

	XEmacPs_PhyRead(xemacpsp, sgmii_phy_addr, IEEE_STATUS_REG_OFFSET, &status);
	while ( !(status & IEEE_STAT_AUTONEGOTIATE_COMPLETE) ) {
		sleep(1);
		XEmacPs_PhyRead(xemacpsp, sgmii_phy_addr, IEEE_STATUS_REG_OFFSET,
																&status);
	}
	xil_printf("Autonegotiation complete \r\n");

	xil_printf("Waiting for Link to be up; Polling for SGMII core Reg \r\n");
	XEmacPs_PhyRead(xemacpsp, sgmii_phy_addr, IEEE_PARTNER_ABILITIES_1_REG_OFFSET, &temp);
	while(!(temp & 0x8000)) {
		XEmacPs_PhyRead(xemacpsp, sgmii_phy_addr, IEEE_PARTNER_ABILITIES_1_REG_OFFSET, &temp);
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
		xil_printf("get_IEEE_phy_speed(): Invalid speed bit value, Defaulting to Speed = 10 Mbps\r\n");
		XEmacPs_PhyRead(xemacpsp, sgmii_phy_addr, IEEE_CONTROL_REG_OFFSET, &temp);
		XEmacPs_PhyWrite(xemacpsp, sgmii_phy_addr, IEEE_CONTROL_REG_OFFSET, 0x0100);
		return 10;
	}
}


static void SetUpSLCRDivisors(u32_t mac_baseaddr, s32_t speed)
{
	volatile u32_t slcrBaseAddress;
	u32_t SlcrDiv0 = 0;
	u32_t SlcrDiv1 = 0;
	u32_t SlcrTxClkCntrl;
	u32_t gigeversion;
	volatile u32_t CrlApbBaseAddr;
	u32_t CrlApbDiv0 = 0;
	u32_t CrlApbDiv1 = 0;
	u32_t CrlApbGemCtrl;
#if EL1_NONSECURE
	u32_t ClkId;
#endif

	gigeversion = ((Xil_In32(mac_baseaddr + 0xFC)) >> 16) & 0xFFF;
	if (gigeversion == 2) {

		*(volatile u32_t *)(SLCR_UNLOCK_ADDR) = SLCR_UNLOCK_KEY_VALUE;

		if (mac_baseaddr == ZYNQ_EMACPS_0_BASEADDR) {
			slcrBaseAddress = SLCR_GEM0_CLK_CTRL_ADDR;
		} else {
			slcrBaseAddress = SLCR_GEM1_CLK_CTRL_ADDR;
		}

		if((*(volatile u32_t *)(UINTPTR)(slcrBaseAddress)) &
			SLCR_GEM_SRCSEL_EMIO) {
				return;
		}

		if (speed == 1000) {
			if (mac_baseaddr == XPAR_XEMACPS_0_BASEADDR) {
#ifdef XPAR_PS7_ETHERNET_0_ENET_SLCR_1000MBPS_DIV0
				SlcrDiv0 = XPAR_PS7_ETHERNET_0_ENET_SLCR_1000MBPS_DIV0;
				SlcrDiv1 = XPAR_PS7_ETHERNET_0_ENET_SLCR_1000MBPS_DIV1;
#endif
			} else {
#ifdef XPAR_PS7_ETHERNET_1_ENET_SLCR_1000MBPS_DIV0
				SlcrDiv0 = XPAR_PS7_ETHERNET_1_ENET_SLCR_1000MBPS_DIV0;
				SlcrDiv1 = XPAR_PS7_ETHERNET_1_ENET_SLCR_1000MBPS_DIV1;
#endif
			}
		} else if (speed == 100) {
			if (mac_baseaddr == XPAR_XEMACPS_0_BASEADDR) {
#ifdef XPAR_PS7_ETHERNET_0_ENET_SLCR_100MBPS_DIV0
				SlcrDiv0 = XPAR_PS7_ETHERNET_0_ENET_SLCR_100MBPS_DIV0;
				SlcrDiv1 = XPAR_PS7_ETHERNET_0_ENET_SLCR_100MBPS_DIV1;
#endif
			} else {
#ifdef XPAR_PS7_ETHERNET_1_ENET_SLCR_100MBPS_DIV0
				SlcrDiv0 = XPAR_PS7_ETHERNET_1_ENET_SLCR_100MBPS_DIV0;
				SlcrDiv1 = XPAR_PS7_ETHERNET_1_ENET_SLCR_100MBPS_DIV1;
#endif
			}
		} else {
			if (mac_baseaddr == XPAR_XEMACPS_0_BASEADDR) {
#ifdef XPAR_PS7_ETHERNET_0_ENET_SLCR_10MBPS_DIV0
				SlcrDiv0 = XPAR_PS7_ETHERNET_0_ENET_SLCR_10MBPS_DIV0;
				SlcrDiv1 = XPAR_PS7_ETHERNET_0_ENET_SLCR_10MBPS_DIV1;
#endif
			} else {
#ifdef XPAR_PS7_ETHERNET_1_ENET_SLCR_10MBPS_DIV0
				SlcrDiv0 = XPAR_PS7_ETHERNET_1_ENET_SLCR_10MBPS_DIV0;
				SlcrDiv1 = XPAR_PS7_ETHERNET_1_ENET_SLCR_10MBPS_DIV1;
#endif
			}
		}

		if (SlcrDiv0 != 0 && SlcrDiv1 != 0) {
			SlcrTxClkCntrl = *(volatile u32_t *)(UINTPTR)(slcrBaseAddress);
			SlcrTxClkCntrl &= EMACPS_SLCR_DIV_MASK;
			SlcrTxClkCntrl |= (SlcrDiv1 << 20);
			SlcrTxClkCntrl |= (SlcrDiv0 << 8);
			*(volatile u32_t *)(UINTPTR)(slcrBaseAddress) = SlcrTxClkCntrl;
			*(volatile u32_t *)(SLCR_LOCK_ADDR) = SLCR_LOCK_KEY_VALUE;
		} else {
			xil_printf("Clock Divisors incorrect - Please check\r\n");
		}
	} else if (gigeversion == GEM_VERSION_ZYNQMP) {
		/* Setup divisors in CRL_APB for Zynq Ultrascale+ MPSoC */
		if (mac_baseaddr == ZYNQMP_EMACPS_0_BASEADDR) {
			CrlApbBaseAddr = CRL_APB_GEM0_REF_CTRL;
		} else if (mac_baseaddr == ZYNQMP_EMACPS_1_BASEADDR) {
			CrlApbBaseAddr = CRL_APB_GEM1_REF_CTRL;
		} else if (mac_baseaddr == ZYNQMP_EMACPS_2_BASEADDR) {
			CrlApbBaseAddr = CRL_APB_GEM2_REF_CTRL;
		} else if (mac_baseaddr == ZYNQMP_EMACPS_3_BASEADDR) {
			CrlApbBaseAddr = CRL_APB_GEM3_REF_CTRL;
		}

		if (speed == 1000) {
			if (mac_baseaddr == ZYNQMP_EMACPS_0_BASEADDR) {
#ifdef XPAR_PSU_ETHERNET_0_ENET_SLCR_1000MBPS_DIV0
				CrlApbDiv0 = XPAR_PSU_ETHERNET_0_ENET_SLCR_1000MBPS_DIV0;
				CrlApbDiv1 = XPAR_PSU_ETHERNET_0_ENET_SLCR_1000MBPS_DIV1;
#endif
			} else if (mac_baseaddr == ZYNQMP_EMACPS_1_BASEADDR) {
#ifdef XPAR_PSU_ETHERNET_1_ENET_SLCR_1000MBPS_DIV0
				CrlApbDiv0 = XPAR_PSU_ETHERNET_1_ENET_SLCR_1000MBPS_DIV0;
				CrlApbDiv1 = XPAR_PSU_ETHERNET_1_ENET_SLCR_1000MBPS_DIV1;
#endif
			} else if (mac_baseaddr == ZYNQMP_EMACPS_2_BASEADDR) {
#ifdef XPAR_PSU_ETHERNET_2_ENET_SLCR_1000MBPS_DIV0
				CrlApbDiv0 = XPAR_PSU_ETHERNET_2_ENET_SLCR_1000MBPS_DIV0;
				CrlApbDiv1 = XPAR_PSU_ETHERNET_2_ENET_SLCR_1000MBPS_DIV1;
#endif
			} else if (mac_baseaddr == ZYNQMP_EMACPS_3_BASEADDR) {
#ifdef XPAR_PSU_ETHERNET_3_ENET_SLCR_1000MBPS_DIV0
				CrlApbDiv0 = XPAR_PSU_ETHERNET_3_ENET_SLCR_1000MBPS_DIV0;
				CrlApbDiv1 = XPAR_PSU_ETHERNET_3_ENET_SLCR_1000MBPS_DIV1;
#endif
			}
		} else if (speed == 100) {
			if (mac_baseaddr == ZYNQMP_EMACPS_0_BASEADDR) {
#ifdef XPAR_PSU_ETHERNET_0_ENET_SLCR_100MBPS_DIV0
				CrlApbDiv0 = XPAR_PSU_ETHERNET_0_ENET_SLCR_100MBPS_DIV0;
				CrlApbDiv1 = XPAR_PSU_ETHERNET_0_ENET_SLCR_100MBPS_DIV1;
#endif
			} else if (mac_baseaddr == ZYNQMP_EMACPS_1_BASEADDR) {
#ifdef XPAR_PSU_ETHERNET_1_ENET_SLCR_100MBPS_DIV0
				CrlApbDiv0 = XPAR_PSU_ETHERNET_1_ENET_SLCR_100MBPS_DIV0;
				CrlApbDiv1 = XPAR_PSU_ETHERNET_1_ENET_SLCR_100MBPS_DIV1;
#endif
			} else if (mac_baseaddr == ZYNQMP_EMACPS_2_BASEADDR) {
#ifdef XPAR_PSU_ETHERNET_2_ENET_SLCR_100MBPS_DIV0
				CrlApbDiv0 = XPAR_PSU_ETHERNET_2_ENET_SLCR_100MBPS_DIV0;
				CrlApbDiv1 = XPAR_PSU_ETHERNET_2_ENET_SLCR_100MBPS_DIV1;
#endif
			} else if (mac_baseaddr == ZYNQMP_EMACPS_3_BASEADDR) {
#ifdef XPAR_PSU_ETHERNET_3_ENET_SLCR_100MBPS_DIV0
				CrlApbDiv0 = XPAR_PSU_ETHERNET_3_ENET_SLCR_100MBPS_DIV0;
				CrlApbDiv1 = XPAR_PSU_ETHERNET_3_ENET_SLCR_100MBPS_DIV1;
#endif
			}
		} else {
			if (mac_baseaddr == ZYNQMP_EMACPS_0_BASEADDR) {
#ifdef XPAR_PSU_ETHERNET_0_ENET_SLCR_10MBPS_DIV0
				CrlApbDiv0 = XPAR_PSU_ETHERNET_0_ENET_SLCR_10MBPS_DIV0;
				CrlApbDiv1 = XPAR_PSU_ETHERNET_0_ENET_SLCR_10MBPS_DIV1;
#endif
			} else if (mac_baseaddr == ZYNQMP_EMACPS_1_BASEADDR) {
#ifdef XPAR_PSU_ETHERNET_1_ENET_SLCR_10MBPS_DIV0
				CrlApbDiv0 = XPAR_PSU_ETHERNET_1_ENET_SLCR_10MBPS_DIV0;
				CrlApbDiv1 = XPAR_PSU_ETHERNET_1_ENET_SLCR_10MBPS_DIV1;
#endif
			} else if (mac_baseaddr == ZYNQMP_EMACPS_2_BASEADDR) {
#ifdef XPAR_PSU_ETHERNET_2_ENET_SLCR_10MBPS_DIV0
				CrlApbDiv0 = XPAR_PSU_ETHERNET_2_ENET_SLCR_10MBPS_DIV0;
				CrlApbDiv1 = XPAR_PSU_ETHERNET_2_ENET_SLCR_10MBPS_DIV1;
#endif
			} else if (mac_baseaddr == ZYNQMP_EMACPS_3_BASEADDR) {
#ifdef XPAR_PSU_ETHERNET_3_ENET_SLCR_10MBPS_DIV0
				CrlApbDiv0 = XPAR_PSU_ETHERNET_3_ENET_SLCR_10MBPS_DIV0;
				CrlApbDiv1 = XPAR_PSU_ETHERNET_3_ENET_SLCR_10MBPS_DIV1;
#endif
			}
		}

		if (CrlApbDiv0 != 0 && CrlApbDiv1 != 0) {
		#if EL1_NONSECURE
			XSmc_OutVar RegRead;
			RegRead = Xil_Smc(MMIO_READ_SMC_FID, (u64)(CrlApbBaseAddr),
								0, 0, 0, 0, 0, 0);
			CrlApbGemCtrl = RegRead.Arg0 >> 32;
		#else
			CrlApbGemCtrl = *(volatile u32_t *)(UINTPTR)(CrlApbBaseAddr);
        #endif
			CrlApbGemCtrl &= ~CRL_APB_GEM_DIV0_MASK;
			CrlApbGemCtrl |= CrlApbDiv0 << CRL_APB_GEM_DIV0_SHIFT;
			CrlApbGemCtrl &= ~CRL_APB_GEM_DIV1_MASK;
			CrlApbGemCtrl |= CrlApbDiv1 << CRL_APB_GEM_DIV1_SHIFT;
		#if EL1_NONSECURE
			Xil_Smc(MMIO_WRITE_SMC_FID, (u64)(CrlApbBaseAddr) | ((u64)(0xFFFFFFFF) << 32),
				(u64)CrlApbGemCtrl, 0, 0, 0, 0, 0);
			do {
			RegRead = Xil_Smc(MMIO_READ_SMC_FID, (u64)(CrlApbBaseAddr),
				0, 0, 0, 0, 0, 0);
			} while((RegRead.Arg0 >> 32) != CrlApbGemCtrl);
		#else
			*(volatile u32_t *)(UINTPTR)(CrlApbBaseAddr) = CrlApbGemCtrl;
        #endif
		} else {
			xil_printf("Clock Divisors incorrect - Please check\r\n");
		}
	} else if (gigeversion == GEM_VERSION_VERSAL) {
		/* Setup divisors in CRL for Versal */
		if (mac_baseaddr == VERSAL_EMACPS_0_BASEADDR) {
			CrlApbBaseAddr = VERSAL_CRL_GEM0_REF_CTRL;
#if EL1_NONSECURE
			ClkId = CLK_GEM0_REF;
#endif
		} else if (mac_baseaddr == VERSAL_EMACPS_1_BASEADDR) {
			CrlApbBaseAddr = VERSAL_CRL_GEM1_REF_CTRL;
#if EL1_NONSECURE
			ClkId = CLK_GEM1_REF;
#endif
		}

		if (speed == 1000) {
			if (mac_baseaddr == VERSAL_EMACPS_0_BASEADDR) {
#ifdef XPAR_PSV_ETHERNET_0_ENET_SLCR_1000MBPS_DIV0
				CrlApbDiv0 = XPAR_PSV_ETHERNET_0_ENET_SLCR_1000MBPS_DIV0;
#endif
			} else if (mac_baseaddr == VERSAL_EMACPS_1_BASEADDR) {
#ifdef XPAR_PSV_ETHERNET_1_ENET_SLCR_1000MBPS_DIV0
				CrlApbDiv0 = XPAR_PSV_ETHERNET_1_ENET_SLCR_1000MBPS_DIV0;
#endif
			}
		} else if (speed == 100) {
			if (mac_baseaddr == VERSAL_EMACPS_0_BASEADDR) {
#ifdef XPAR_PSV_ETHERNET_0_ENET_SLCR_100MBPS_DIV0
				CrlApbDiv0 = XPAR_PSV_ETHERNET_0_ENET_SLCR_100MBPS_DIV0;
#endif
			} else if (mac_baseaddr == VERSAL_EMACPS_1_BASEADDR) {
#ifdef XPAR_PSV_ETHERNET_1_ENET_SLCR_100MBPS_DIV0
				CrlApbDiv0 = XPAR_PSV_ETHERNET_1_ENET_SLCR_100MBPS_DIV0;
#endif
			}
		} else {
			if (mac_baseaddr == VERSAL_EMACPS_0_BASEADDR) {
#ifdef XPAR_PSV_ETHERNET_0_ENET_SLCR_10MBPS_DIV0
				CrlApbDiv0 = XPAR_PSV_ETHERNET_0_ENET_SLCR_10MBPS_DIV0;
#endif
			} else if (mac_baseaddr == VERSAL_EMACPS_1_BASEADDR) {
#ifdef XPAR_PSV_ETHERNET_1_ENET_SLCR_10MBPS_DIV0
				CrlApbDiv0 = XPAR_PSV_ETHERNET_1_ENET_SLCR_10MBPS_DIV0;
#endif
			}
		}

		if (CrlApbDiv0 != 0) {
#if EL1_NONSECURE
			Xil_Smc(PM_SET_DIVIDER_SMC_FID, (((u64)CrlApbDiv0 << 32) | ClkId), 0, 0, 0, 0, 0, 0);
#else
			CrlApbGemCtrl = Xil_In32((UINTPTR)CrlApbBaseAddr);
			CrlApbGemCtrl &= ~VERSAL_CRL_GEM_DIV_MASK;
			CrlApbGemCtrl |= CrlApbDiv0 << VERSAL_CRL_APB_GEM_DIV_SHIFT;

			Xil_Out32((UINTPTR)CrlApbBaseAddr, CrlApbGemCtrl);
#endif
		} else {
			xil_printf("Clock Divisors incorrect - Please check\r\n");
		}
	}

	return;
}

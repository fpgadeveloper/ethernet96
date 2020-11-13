FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://user.cfg \
            file://dp83867_sgmii_clk_en.patch \
            file://0001-Revert-tty-xilinx_uartps-Add-the-id-to-the-console.patch \
            file://fix_u96v2_pwrseq_simple.patch \
	    "


FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://bsp.cfg \
            file://dp83867_sgmii_clk_en.patch \
            file://fix_u96v2_pwrseq_simple.patch \
	    "


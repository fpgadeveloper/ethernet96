SRC_URI += "file://user.cfg \
            file://dp83867_sgmii_clk_en.patch \
            file://macb_multi_phy.patch \
            "

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"


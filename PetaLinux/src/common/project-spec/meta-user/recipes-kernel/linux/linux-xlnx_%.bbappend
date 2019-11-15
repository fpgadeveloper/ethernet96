SRC_URI += "file://user.cfg \
            file://dp83867_sgmii_clk_en.patch \
            file://axienet_common_mdio.patch \
            "

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"


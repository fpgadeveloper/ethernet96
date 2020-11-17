FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://user.cfg \
            file://dp83867_sgmii_clk_en.patch \
            file://xilinx_uartps_really_fix_id_assignment.patch \
            "


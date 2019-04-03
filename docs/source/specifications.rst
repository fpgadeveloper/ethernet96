==============
Specifications
==============

Absolute Maximum Ratings
========================

+-------------------+------------------------+------------------------------+--------------------------+--------------------+
|                                            | MIN                          | MAX                      | UNIT               |
+===================+========================+==============================+==========================+====================+
| Supply voltage    |    SYS_DCIN            |    +8                        |    +17                   |    V               |
+-------------------+------------------------+------------------------------+--------------------------+--------------------+

Reset Timing
============

When hardware resetting the PHYs, we recommend using this timing:

#. Hold the RESET_N signal LOW for 10ms
#. Release the RESET_N signal (HIGH) and wait for 5ms


MDIO Timing
===========

* The maximum MDC frequency supported by the DP83867 PHY is 25MHz.

DP83867 Electrical and Timing
=============================

For electrical specs and timing related to the DP83867 signals listed below, please
refer to the `DP83867 datasheet <http://www.ti.com/product/DP83867CS>`_:

* Reset
* SGMII
* GPIO0 and GPIO1
* MDIO
* Start-of-Frame detect

Certifications
==============

* Coming soon

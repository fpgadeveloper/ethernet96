==============
Specifications
==============

Recommended Operating Conditions
================================

+-------------------+------------------------+------------+------------+-----------+--------+
|                                            | MIN        | TYP        | MAX       | UNIT   |
+===================+========================+============+============+===========+========+
| Supply voltage    |    SYS_DCIN            |    +8      |    +12     |    +17    |    V   |
+-------------------+------------------------+------------+------------+-----------+--------+
| Output current    | | +1V8 (pin 35)        |    0       |            |    200    |    mA  |
|                   | | Low-speed            |            |            |           |        |
|                   | | expansion socket     |            |            |           |        |
+-------------------+------------------------+------------+------------+-----------+--------+

Power Consumption
=================

The specifications below refer to the total power consumption of the mezzanine card
and the carrier board combined. It is important to note that the use of the mezzanine 
will affect the power consumption of the SoC on the carrier board. This is due to the 
peripherals and IP that must be enabled on the SoC to interface with the 
Ethernet PHYs. Also note that the total power consumption is dependent on the ambient 
temperature and channel utilization.

Ultra96-v1
----------

+-------------------+------------+-------------+------------+------------+-----------+--------+
|                   | SYS_DCIN   | UTILIZATION | MIN        | TYP        | MAX       | UNIT   |
+===================+============+=============+============+============+===========+========+
| Current draw      | 16 VDC     |   100%      |            |    510     |           |   mA   |
|                   +------------+-------------+------------+------------+-----------+--------+
|                   | 12 VDC     |   100%      |            |    645     |           |   mA   |
|                   +------------+-------------+------------+------------+-----------+--------+
|                   | 8 VDC      |   100%      |            |    935     |           |   mA   |
+-------------------+------------+-------------+------------+------------+-----------+--------+

* Tests performed at ambient temperature of 25 degrees C
* Tests performed using IP in the FPGA to generate the Ethernet packets

Ultra96-v2
----------

+-------------------+------------+-------------+------------+------------+-----------+--------+
|                   | SYS_DCIN   | UTILIZATION | MIN        | TYP        | MAX       | UNIT   |
+===================+============+=============+============+============+===========+========+
| Current draw      | 16 VDC     |   100%      |            |    550     |           |   mA   |
|                   +------------+-------------+------------+------------+-----------+--------+
|                   | 12 VDC     |   100%      |            |    710     |           |   mA   |
|                   +------------+-------------+------------+------------+-----------+--------+
|                   | 8 VDC      |   100%      |            |    1050    |           |   mA   |
+-------------------+------------+-------------+------------+------------+-----------+--------+

* Tests performed at ambient temperature of 25 degrees C
* Tests performed using IP in the FPGA to generate the Ethernet packets

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

* RoHS
* CE

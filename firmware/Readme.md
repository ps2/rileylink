# Loading Firmware

There are two microprocessors on the RileyLink board; a ble113 module, and a cc1110.  For the cc1110, you should install the latest [subg_rfspy](https://github.com/ps2/subg_rfspy) firmware. On the ble113, you should install the firmware in the ble113_rfspy subdirectory.

## Prerequisites

* [cc-debugger](http://www.ti.com/tool/cc-debugger)
* linux machine with sdcc and cc-tool (to program cc1110 with [subg_rfspy](https://github.com/ps2/subg_rfspy)), or
  a windows machine with [sdcc](http://sdcc.sourceforge.net/index.php#Download) and [gnu make](http://gnuwin32.sourceforge.net/downlinks/make.php).  SDCC needs to be in the PATH
* windows machine (or VM) with the "Bluetooth Smart Software and SDK" from the [ble113 product page](https://www.bluegiga.com/en-US/products/ble113-bluetooth-smart-module/)

![cc-debugger connection illustration](ccdbg.png)

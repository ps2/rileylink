# Loading Firmware


## Prerequisites

* [cc-debugger](http://www.ti.com/tool/cc-debugger)
* linux machine (or VM) with sdcc and cc-tool (to program cc1110)
* windows machine (or VM) with [BLE Bluegiga SW Update Tool](https://www.bluegiga.com/en-US/products/software-bluegiga-bluetooth-smart/)

## Connecting cc-debugger

*Note:* Be careful to write the appropriate firmware to the correct chip.  If you run 'make' in the cc1110 directory while the cc-debugger is connected to the ble113, you will wipe out the ble113 license key and will need to request a new one from Bluegiga

![cc-debugger connection illustration](ccdbg.png)

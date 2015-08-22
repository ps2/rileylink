# Loading Firmware


## Prerequisites

* [cc-debugger](http://www.ti.com/tool/cc-debugger)
* linux machine with sdcc and cc-tool (to program cc1110), or
  a windows machine with [sdcc](http://sdcc.sourceforge.net/index.php#Download) and [gnu make](http://gnuwin32.sourceforge.net/downlinks/make.php).  SDCC needs to be in the PATH
* windows machine (or VM) for running [BLE Bluegiga SW Update Tool](https://www.bluegiga.com/en-US/products/software-bluegiga-bluetooth-smart/) with [BGBuild](https://www.bluegiga.com/en-US/download/?file=TK48JyZjQHujdh-E_060nA&title=Bluetooth%2520Smart%2520Software%2520and%2520SDK%2520v.1.3.2&filename=ble-1.3.2-122.zip)

## Connecting cc-debugger

*Note:* Be careful to write the appropriate firmware to the correct chip.  If you run 'make' in the cc1110 directory while the cc-debugger is connected to the ble113, you will wipe out the ble113 license key and will need to request a new one from Bluegiga


![cc-debugger connection illustration](ccdbg.png)

# Loading Firmware

There are two microprocessors on the RileyLink board; a ble113 module, and a cc1110. Each needs it's own firmware.

## CC1110 Firmware

For the cc1110, you should install the latest [subg_rfspy](https://github.com/skupas/subg_rfspy) firmware.

## BLE113 Bluetooth Module

For the ble113, you should install the firmware in the ble113_rfspy subdirectory.
Using the BLE Update tool (details below).

1. Install the Bluetooth Firmware Update and the Bluetooth SDK tools as per the "Prerequisites" section below.
2. Install SmartRF Studio as below, so that you have USB drivers for the CC-Debugger.
3. Go to https://github.com/skupas/rileylink and click the "Clone or download" option.
4. Select "Download ZIP"
5. Extract the Zip in your download directory.
6. Double click on the Project file in the ble113_rfspy folder.
7. If you receive the message "Unable to automatically select BGBuild":
  - Click BGBuild menu item, and choose "Manually Select"
  - Choose My Computer -> C: -> Bluegiga -> blue-1.4.2-130 (or similar) -> bin -> bgbuild

## Prerequisites

## CC1110 Firmware

If you can, use a pre-built firmware from subg_rfspy release list on GitHub. You can then
use the following tools to write the firmware:

* For Windows: [cc-debugger](http://www.ti.com/tool/cc-debugger)
* For Linux: cc-tool. See [cc-tool](https://github.com/oskarpearson/mmeowlink/wiki/Firmware-install-with-CC-Tool-%28Linux%29) for instructions on installation and usage.

### Bluetooth Firmware

Windows machine (or VM) with:

* SmartRF Studio - tested with 2.3.1 from http://www.ti.com/tool/smartrftm-studio (Make sure to 'Extract All' if prompted at install/unzip time)
* "BLE Update Tool v1.3.6 (Windows XP,7,8 and 10)" (or above) **AND** "Bluetooth Smart Software and SDK v.1.4.2" applications
from the [ble113 product page](https://www.bluegiga.com/en-US/products/software-bluegiga-bluetooth-smart/)

Note that you will need to sign up for an accounts to download both installers.

## Connecting the CC Debugger to the RileyLink

<Picture to be added>

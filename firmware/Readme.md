# Loading Firmware

There are two microprocessors on the RileyLink board; a ble113 module, and a cc1110. Each needs it's own firmware.

## CC1110 Firmware

For the cc1110, you should install the latest [subg_rfspy](https://github.com/ps2/subg_rfspy) firmware.

- Use spi1_alt2_RILEYLINK_US_STDLOC.hex if you are in the USA/Australasia
- Use spi1_alt2_RILEYLINK_WW_STDLOC.hex if you are elsewhere (the pump serial printed
    on the back of the device will end with 'WW' if you need to use this)


## BLE113 Bluetooth Module

For the ble113, you should install the firmware in the ble113_rfspy subdirectory.
Using the BLE Update tool (details below).

1. Install the Bluetooth Firmware Update tool and drivers as per the "Prerequisites" section below.
2. Install SmartRF Studio as below, so that you have USB drivers for the CC-Debugger.
3. Go to https://github.com/ps2/rileylink and click the "Clone or download" option.
4. Select "Download ZIP"
5. Extract the Zip in your download directory.
6. Double click on the Project file in the ble113_rfspy folder.
7. If you receive the message "Unable to automatically select BGBuild":
  - Click BGBuild menu item, and choose "Manually Select"
  - Choose My Computer -> C: -> Bluegiga -> blue-1.4.2-130 (or similar) -> bin -> bgbuild

## Disabling Bluetooth

If you want to completely disable the bluetooth part of the RileyLink, you can use the
'ble113_disabled' firmware. This is normally only done when you are using the RileyLink
over serial, using it as a mmeowlink radio.

## Prerequisites

## CC1110 Firmware

If you can, use a pre-built firmware from subg_rfspy release list on GitHub. You can then
use the following tools to write the firmware:

* For Windows: [cc-debugger](http://www.ti.com/tool/cc-debugger)
* For Linux: cc-tool. See [cc-tool](https://github.com/oskarpearson/mmeowlink/wiki/Firmware-install-with-CC-Tool-%28Linux%29) for instructions on installation and usage.

### Bluetooth Firmware

Windows machine (or VM) with:

* SmartRF Studio - tested with 2.3.1 from http://www.ti.com/tool/smartrftm-studio (Make sure to 'Extract All' if prompted at install/unzip time)
* "BLE Update Tool v1.3.6 (Windows XP,7,8 and 10)" (or above) application
from the [ble113 product page](https://www.bluegiga.com/en-US/products/software-bluegiga-bluetooth-smart/)

Note that you will need to sign up for an accounts to download both installers.

## Troubleshooting

- If you receive the message "CebalChip Object has no attribute Reset" when writing
  bluetooth firmware, then check that you've not accidentally plugged into the
  CC1110 port. Also check that you've connected the CC-Debugger correctly.

## Connecting the CC Debugger to the RileyLink

![cc-debugger connection illustration](ccdbg.png)

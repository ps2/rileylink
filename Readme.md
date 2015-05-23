# RileyLink

A custom designed Bluetooth Smart (BLE) to 916MHz module. It can be used to bridge any BLE capable smartphone to the world of 916Mhz based devices. This project is focused on reading blood glucose and related data from Medtronic insulin pumps and sensors.  Please understand that this project:

 * *Has no affiliation with Medtronic*
 * *Is highly experimental*
 * *Is not intended for therapy*

### Hardware

See the [hardware](https://github.com/ps2/rileylink/tree/master/hardware) directory for design files to build a RileyLink.

![RileyLink Hardware](https://raw.githubusercontent.com/ps2/rileylink/master/rileylink.jpg)

### Firmware

The code in the [firmware](https://github.com/ps2/rileylink/tree/master/firmware) directory runs on the RileyLink hardware.  There are two main chips on the RileyLink, and thus two firmware images.

### App

To send data to the cloud, the GlucoseLink app runs on your iOS devices and talks to the RileyLink over bluetooth.


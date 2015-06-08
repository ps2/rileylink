# RileyLink

[![Join the chat at https://gitter.im/ps2/rileylink](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/ps2/rileylink?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

A custom designed Bluetooth Smart (BLE) to 916MHz module. It can be used to bridge any BLE capable smartphone to the world of 916Mhz based devices. This project is focused on talking to Medtronic insulin pumps and sensors.  I am currently using it to display display pump and sensor data in [Nightscout](http://nightscout.github.io/), though the iOS app I use do so isn't publicly released yet.

Please understand that this project:

 * *Has no affiliation with Medtronic*
 * *Is highly experimental*
 * *Is not intended for therapy*

### Hardware

See the [hardware](https://github.com/ps2/rileylink/tree/master/hardware) directory for design files to build a RileyLink. The hardware design is released under [Creative Commons Share-alike 3.0](http://creativecommons.org/licenses/by-sa/3.0/).

![RileyLink Hardware](https://raw.githubusercontent.com/ps2/rileylink/master/rileylink.jpg)

### Firmware

The code in the [firmware](https://github.com/ps2/rileylink/tree/master/firmware) directory runs on the RileyLink hardware.  There are two main chips on the RileyLink, and thus two firmware images.

*Note:* Be careful to write the appropriate firmware to the correct chip.  If you write the cc1110 firmware to the ble113, you will wipe out the ble113 license key and will need to request a new one from Bluegiga

### App

To send data to the cloud, the GlucoseLink app (not released yet; working on NightScout integration) runs on your iOS devices and talks to the RileyLink over bluetooth.

If you are interested in taking a look at using the RileyLink with your own app, check out [gatt.xml](firmware/ble113/gatt.xml)

### License

The MIT License (MIT)

Copyright (c) 2015 Pete Schwamb

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

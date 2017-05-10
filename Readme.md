# RileyLink

[![Join the chat at https://gitter.im/ps2/rileylink](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/ps2/rileylink?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

A custom designed Bluetooth Smart (BLE) to Sub-1 GHz module. It can be used to bridge any BLE capable smartphone to the world of Sub-1 GHz devices. 

### Setup

 * There is a [FAQ](https://docs.google.com/document/d/1-KlewmRObpUWCTQSq9EPraN8R-6rCksJS_sRSQSexX0/edit#) covering some questions about installing the firmware.
 * [@loudnate](https://github.com/loudnate) recorded a [setup log](https://docs.google.com/document/d/1-bGBXbxVKOs_tDXi68qiOD7bIT6tQlkQydXn5Q-afLc/edit) of his experience.

### Hardware

See the [hardware](https://github.com/ps2/rileylink/tree/master/hardware) directory for design files to build a RileyLink. The hardware design is released under [Creative Commons Share-alike 3.0](http://creativecommons.org/licenses/by-sa/3.0/).  This board has small parts and will need to be reflow soldered; using a solder-paste stencil is recommended. 

![RileyLink Hardware](https://raw.githubusercontent.com/ps2/rileylink/master/rileylink.jpg)

### Order a Pre-Assembed RileyLink
From time-to-time community members do a production run of pre-assembled RileyLink Boards. When they are available you can place an order here [GetRileyLink](https://getrileylink.org/)

### Firmware

The code in the [firmware](https://github.com/ps2/rileylink/tree/master/firmware) directory runs on the RileyLink hardware.  There are two main chips on the RileyLink, and thus two firmware images.

### LED Lights

There are blue and green leds near both chips. The ble113 is on the upper right of the board, and the cc1110 is in the lower middle.  

Blue for the ble113 indicates there are packets received and ready for a phone to pick up. Green means the phone is connected to the ble113.

On the cc1110, I blue is a timer based on/off, letting you know the firmware code is running. Green is toggled when a packet comes in.

The other red LED indicates charging.

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

# RileyLink Hardware

 * board.sch - circuit schematic
 * board.brd - pcb design file
 * bom.csv - materials list
 * case_bottom.stl - 3d printer model for case bottom
 * case_top.stl - 3d printer model for case top

### Order the PCB from OSH Park:

[RileyLink v1.0](https://oshpark.com/shared_projects/jWrg6WmU)

### Components

The bom.csv file contains a list of parts and quantities along with their Digikey part number.

### PCB Assembly

A stencil for the PCB can be obtained at a reasonable price from [OSH Stencils](https://www.oshstencils.com).  Just upload the .brd file and accept the default mappings.

You will have to look at the schematic and the board design in [Eagle](http://www.cadsoftusa.com/) to know where the parts go, and how they are oriented.

I use a hot-air rework station to flow the solder paste, but you could use a toaster oven setup as well.

![Assembled Board](https://raw.githubusercontent.com/ps2/rileylink/master/hardware/board.jpg)

### Case

I created a case using [Tinkercad](https://www.tinkercad.com), a great tool.

![3D Printed Case](https://raw.githubusercontent.com/ps2/rileylink/master/hardware/case.png)

The case is designed to hold an [850mAh Lipo](https://getrileylink.org/product/850lionbattery/). That battery lasts a day or so when the RileyLink is constant listen mode. It should last longer if the firmware uses a duty cycle that's less than 100%.

### Fitting components inside case

![Case Fitting](https://raw.githubusercontent.com/ps2/rileylink/master/hardware/case_fitting.jpg)

Note: there’s an issue I have with the case that I haven’t fixed yet; the board in the case can rotate a bit so that the usb port doesn’t line up with the hole. If stick a small something (like those sticky pads that keep cabinet doors from slamming) to the top of the usb port, that fixes the issue.

### 868MHz (EU) version

Since the firmware allows changing of the frequency, and most people are using the 915Mhz antenna successfully with 868Mhz pumps, a custom RileyLink is not needed.

### License

The hardware design is released under [Creative Commons Share-alike 3.0](http://creativecommons.org/licenses/by-sa/3.0/).


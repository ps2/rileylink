# RileyLink Hardware

 * board.sch - circuit schematic
 * board.brd - pcb design file
 * bom.csv - materials list
 * case_bottom.stl - 3d printer model for case bottom
 * case_top.stl - 3d printer model for case top

### Order the PCB from OSH Park:

[RileyLink v0.2](https://oshpark.com/shared_projects/5HqFOnZu)

### Components

Most of the parts are available at [Mouser](http://mouser.com).  A few parts (battery and connector) I ordered from [SparkFun](http://sparkfun.com). In the bottom left corner of the board, there are two alternative antennas: a post antenna, and a chip antenna. The post antenna has much better reception, so that is what is listed in the parts list (bom.csv).  The parts for the chip antenna are not included, so some of the pads in the lower left will be empty, as shown in the photo.

### Assembly

A stencil for the PCB can be obtained at a reasonable price from [OSH Stencils](https://www.oshstencils.com).  Just upload the .brd file and accept the default mappings.

You will have to look at the schematic and the board design in [Eagle](http://www.cadsoftusa.com/) to know where the parts go, and how they are oriented.

I use a hot-air rework station to flow the solder paste, but you could use a toaster oven setup as well.

![Assembled Board](https://raw.githubusercontent.com/ps2/rileylink/master/hardware/board.jpg)

### Case

I created a case using [Tinkercad](https://www.tinkercad.com), a great tool.

![3D Printed Case](https://raw.githubusercontent.com/ps2/rileylink/master/hardware/case.png)

### License

The hardware design is released under [Creative Commons Share-alike 3.0](http://creativecommons.org/licenses/by-sa/3.0/).


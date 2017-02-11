---
title: Operation
keywords: operation
sidebar: manual_sidebar
permalink: operation.html
summary: Basic theory of operation of this module.
---

Both of the rotary encoders of the {{site.product_name}} use the following circuit:

<img src="images/circuit.png" alt="Basic circuit for the {{site.product_name}}." style="width:50%;" class="center-it"/>

When the encoder shaft is turned, the `A` and `B` switches toggle open and closed
to generate quadrature outputs as described [here](https://en.wikipedia.org/wiki/Rotary_encoder#Incremental_rotary_encoder).
The quadrature outputs can be decoded to determine the direction of shaft rotation
as shown in this [VHDL code](https://github.com/xesscorp/VHDL_Lib/blob/master/RotaryEncoder.vhd).

When the encoder shaft is pushed downward, the `D` switch is closed and the
output is pulled to ground through a resistance of 330&nbsp;&Omega;.
When the shaft is not pushed, the output is pulled to `VCC` (usually 3.3&nbsp;V)
through a combined resistance of 5&nbsp;K&Omega;.


{% include links.html %}


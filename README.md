Advent of Code 2023 -- in gate level VHDL
=========================================

Day1 - Puzzle 2
---------------

This is a tricky problem. The input is provided as a text file. How are we going to feed that into hardware?

So first we make a few assumptions.

Let's say that the text file will be serialised into the chip as a series of ascii values. That makes sense. And the chip will give its output in the same format.

So the chip needs to have a clock input and an 8-bit input bus, as well as an 8 bit output bus.

The input needs to feed the file in one-byte per clock cycle to the chip. The chip will handle the processing, and then when the input has finished (indicated by sending null characters) the chip will output its result, also one byte at a time in ascii, finishing with a null byte as is the tradition of our people.


So how is this implemented?

Well the testbench file 'rtl/day1_tbh.vhd' implements reading the input data from the file and feeding it into the chip. The file 'rtl/day1.vhd' is the actual chip. The rest of the files are all the many devices needed to make it work, and their testbenches.


### How to run

You will need [ghdl](http://ghdl.free.fr/) to run this in simulation. The VHD can also be synthesized to flsh to an FPGA or to give to a foundry to make your own ASIC. The tools for doing that will vary depending on the FPGA vendor or ASIC foundry.

```bash
$ make day1
```

will create the file `day1_tb.ghw`. This is a [gtkwave](https://gtkwave.sourceforge.net/) file. You can view it in that tool and see the wonderful output!

### Architecture (How it works)

* The unit `digit` outputs a '1' when the input bits are an ascii digit (0-9), and '0' the rest of the time.
* The unit `newline` outputs a '1' when the input bits are an ascii line-feed and '0' the rest of the time.
* The unit `dec` will provide a digit output and an enable signal one cycle after the last character of a written digit.
* The value of the least significant 4 bits of the input on the previous clock cycle if the enable signal from `dec` is not high, and otherwise the digit output from `dec` are stored into the `last_digit` register on any clock-tick when the input was a digit last cycle or the enable signal from `dec` is high, and `"000"` is stored on any clock cycle where the input wass a line-feed in the previous cycle.
* The register `has_first` is initially set to '0', and set to '1' on any clock cycle when it is '0' and the input was a digit the previous cycle or the enable signal from `dec` is high. It is reset to '0' on any clock cycle where the input was a line-feed on the previous cycle.
* The value of the least significant 4 bits of the input on the previous cycle if the enable signal from `dec` is not high, and otherwise the digit output from `dec` are stored into the `first_digit` register on any clock cycle when the input was a digit in the previous cycle or the enable signal from `dec` is high *and* the value in `has_first` is '0'. It is rest to `"0000"` on any clock cycle where the input wass a line-feed on the previous cycle.
* The 20-bit register `accum` is initially set to all 0s, and set to the current value of `sum` on any clock-cycle where the input wass a line-feed on the previous cycle.
* The value of `sum` is the result of the BCD-sum of the current value of `accum` and the BCD value represented by `first_digit & last_digit`.
* The signal `is_zero` is '1' whenever the input is a null byte, and '0' otherwise.
* The register `is_zero_z1` is set to the value of `is_zero` on ever clock cycle.
* The signal `start_output` is '1' on any cycle when `is_zero` is '1', but `is_zero_z1` is '0' (ie. it detects rising edges on `is_zero`).
* The register `outreg` is initially set to '0'. It is set to the current value of the `accum` register whever `start_output` is '1'. On any clock cycle where `start_output` is zero the values in the register are shifted up by 4 bits.
* The register `outactive` is 5 bits long. It's set to '0' initially. It is set to all '1's whenever `start_output` is '1'. It is shifted down by one bit every clock cycle when `start_output` is '0'.
* The output of the chip is a null byte when the value of the least significant bit of `outactive` is '0' and "0011" concatenated with the top 4 bits of `outreg` whenever the least significant bit of `outactive` is '1'.

The delays of one cycle are necessary to make the results line up correctly with the output of the `dec` unit.

### How does dec work?

The decoder works by the use of a simple array of `strdet` units. Each of these units contains a sequence of `chardet` units. A `chardet` unit has a signal that is raised high whenever the input is equal to a specified character value. The `strdet` unit has a vector of bits, one for each character in the string, each bit in the register is set to '1' on every clock cycle where the signal from the corresponding `chardet` is '1' *and* the previous bit in the register is '1' (or it's the first bit in the register), otherwise it is set to '0'. The output of the `strdet` is the value of the last bit of the bit vector.

In this way the bit rises to '1' on the clock cycle *following* the cycle in which `input` contained the last character of the written digit string.

The `dec` unit thus has a set of enable signals, one for each digit one-nine. To convert this to a simple enable signal is a matter of a simple cascade of or gates. But creating the digit value output is slightly more complex.

The trick here is that each bit of the output is driven by a set of or gates combining those individual digit enable signals for which that bit of the digit value would be high.

### How does the BCD-sum work?

For the first two digits the BCD sum is handled by the `BCD_add` unit. This takes two 4-bit binary inputs plus a 1-bit Carry-In and outputs a 4-bit binary output plus a 1-bit carry-out.

The two input values and the carry-in bit are added together using a binary adder (the `addn` unit, which is an array of multiple `add1` units, each defined by simple logic gates). This results in a 5-bit binary value representing a numeric value between 0 and 19 inclusive.

The intermediate binary value is converted into 4-bit BCD plus a carry-out by use of five 5-input look-up-tables (the LUT1 unit). Each lookup table provides the value of one-bit of output based on the five-bit intermediate value. The function represented by the tables is simply returning the input unchanged with '0' carry-out if it is less than 10, and returning the input - 10 with '1' carry-out otherwise. Since the maximum input value is 19 the output of this unit needs only 4 bits for the BCD digit and 1 bit for carry-out.


For the higher order digits of the BCD sum there is no need to use the full `BCD_add` unit because the value being added will never have more than two digits. As such the higher order digits in the accumulator are calculated using a less complex unit: a simple array of 5 5-input LUTs (LUT1 again) which computes a simple function:

* The four-bit BCD output is equal to the four bit BCD input if the carry-in is '0'. If the carry-in is '1' then it is equal to the input value + 1 mod 10.
* The carry out bit is '0' unless the carry in is '1' *and* the input digit is exactly 9.




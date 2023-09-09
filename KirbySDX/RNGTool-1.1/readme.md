# Kirby Super Star - RNG Tool for BizHawk
This Lua script was created for Kirby Super Star (hereafter KSS).
This script can do the following:
- Monitor the in-game RNG table
- Highlight RNGs that meet the criteria
- Manipulate RNGs

## Video
https://www.youtube.com/watch?v=AeL43qIkaG8

There are differences from the current version because it is an older version.
## Note: If the message "error: The memory domain named SA1 IRAM is not supported by this core."
KSS uses a special memory domain, which can only be watched by a specific core within BizHawk.
Perform the following operations to change the core.
1. Click on [ Config ] > [ Preferred cores ] > [ SNES ] and select the appropriate core.
1. Click on [ Emulation ] > [ Reboot Core ]

The corresponding cores are **BSNESv115+**, **SubBSNESv115+** and **Faust**.
Recommended is BSNESv115+.

*If you are using BSNESv115+ with BizHawk 2.8, the error still occurs. To resolve this, open the Lua file in Notepad or similar. Then change the `MEMORY_DONAIN_NAME` variable in the CONFIG field to `"SA1_IRAM"`.

## Function Description
### RNG ID
The order of the pseudorandom number sequence.

This value does not exist in the game RAM. The pseudo-random number in the game is calculated each time the next RNG is calculated from the current RNG value.
However, since this pseudo-random sequence returns to its initial value 65534 times, it is possible to put all of them together on the table.
The ID will be the address in that table.

### RNG Table
Table of pseudo-random number sequences.
The number of random numbers before and after can be adjusted by changing the values of prev-steps and next-steps.

### RNG GUI
A pseudo-random sequence of numbers expressed as a sequence of bars.
The position of the current RNG can be adjusted in Preference.

### Marker
The values in the table and on the GUI are highlighted according to the values entered.

### RNG manipulation
Change the RNG to a specific value.
Usually, the decision to act from the RNG is calculated once and then based on that RNG. If not, just change the value of Steps ahead.
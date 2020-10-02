# MaskMoji

A way to let people see your facial expressions through a mask

# Instructions

I based my build on the [LilyGo TTGO](https://www.tindie.com/products/ttgo/lilygor-ttgo-t-display/) since it had everything I needed on the board already.

Git clone or download and unpack this repository to a convenient location.

## Prepare the board

You'll need to purchase a small square or rectangular rechargable lithium ion battery, [for example](https://www.sparkfun.com/products/13851). While you're there, maybe buy four [magnets](https://www.sparkfun.com/products/8914) to help hold the assembly to your mask.

The battery comes with a 1mm or 2mm connector, but the TTGO comes with a 1.25mm connector. You'll need to clip off the leads and solder on the 1.25mm connector. Be careful not to short the battery while doing this.

I 3D printed an [enclosure](https://www.thingiverse.com/thing:4183337) which holds the board and battery and protects the screen from cracking.

Download and install the [Arduino IDE](https://arduino.cc), the [ESP32 board support](https://github.com/espressif/arduino-esp32/blob/master/docs/arduino-ide/boards_manager.md), and the [SPIFFS Filesystem loader](https://github.com/me-no-dev/arduino-esp32fs-plugin).

Open the Arduino IDE, and install the plugins above if you haven't already. Go to Tools->Library Manager and search for and install the Adafruit ST7789 library and its dependencies. Install the TJpg decoder.

Go to Tools->board and select ESP32->ESP32 Dev Board. Go to Tools->Partition Scheme and select "No OTA (1MB App/3MB SPIFFS)". Don't select the 3MB FAT option, that won't work.

Open the Maskmoji firmware at (unpack directory)/Firmware/MaskMoji/MaskMoji.ino . Click the check mark icon at the top left to build and make sure it succeeds.

Plug in your board. Go to Tools->Port and select the COM or /dev/tty that corresponds to your board.

Click the arrow icon to the right of the checkmark icon, this should upload the firmware to your board. Assuming you installed the ESPFS loader, go to Tools->ESP32 Sketch Data Upload. This uploads the Emoji images to the flash memory.

## iPhone App (No Android App yet)

If you have a mac, you can build and install the app via XCode. If not, I'll eventually have something on the App Store.

## Usage

Open the MaskMoji app on your iPhone.
Plug the battery into your board.

Select "Scan" in the upper right. You should see your maskmoji. If there are multiple, press the button on the same side as the reset button to see your maskmoji's ID. Select your maskmoji. You'll return to the emoji grid.

Click an emoji to display it on the screen!

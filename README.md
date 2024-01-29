# Card Reader Image
Student project for IOT - Door locking device

https://github.com/rosowskimik/br-rpi/assets/49301780/bcf78c8d-c8d9-40ab-a891-854381e61345

## Description
This is the central repository containing external tree for Buildroot
to create a fully custom Linux image that can be deployed to supported
devices.

## Client HAL application
The main application is responsible for 3 main things:
1. Watching for movement:
  The app detects movement with the configured PIR sensor through GPIO pin.
  When the sensor detects movement, it pulls the GPIO high and keeps it that way
  until movement stops (more specifically it holds that state for 2 more seconds
  after movement stops). When the app detects it, it generates a `movement_event`
  and emits it to security API. It also logs those events locally. After movement
  stops, the app won't generate another movement event until a preconfigured amount
  of time passes to prevent it from constantly reporting the same event. By default
  that amount is 20 seconds.

2. Un/Locking the door based on card readings:
  The app will read back the data that's stored on the card that's moved near the
  sansor and and that data to the API. Based on the response, which will tell
  whether the card is authorized to lock status changes, it will update the
  internal lock state from `locked` to `unlocked` / `unlocked` to `locked`.
  If the attempt is considered `unauthorized`, the app will log the attempt
  locally and signal it to the user, after which it will return to normal operation.
  In both cases, the app will ignore all other card reader events for a preconfigured
  amount of time, after which it will return to normal operation. By default it is 5 seconds.

3. Displaying current lock status using configured LEDs:
  To show it's current state, the app will update the configured LEDs through
  their `/sys/class/leds` entires in sysfs. Possible LEDs configurations:
  * `Red: Off`, `Green: On`
    Lock disengaged
  * `Red: On`, `Green: Off`
    Lock engaged
  * `Red: Off`, `Green: Off`
    In the middle of checking card authorization with API
  * `Red: Blinking`, `Green: Off`
    Attempted to change lock state with unauthorized card

The app should be started automatically during device boot.
The relevant init script is located at `/etc/init.d/S99card_reader`.

The app by default will output its logs to `stderr`, however when launched,
it will also attempt to connect to the standard logging facility to also save
its output in syslog.

The client application can be configured in its section in Buildroot.
It can also be configured on per-device basis using configuration file
that's stored in `/etc/xdg/card_reader/config.yml`.

The default configuration:
```yaml
# initial lock state
init_locked: false

# netowork config
network:
  # system id
  id:
  # interface used for connection
  interface: eth0
  # api hostname to connect to
  hostname: localhost

# hardware config
periph:
  leds:
    red_name: red:user
    green_name: green:user
  reader:
    strength: 5
    timeout: 5s
  movement:
    timeout: 20s
```

## Configuration

### Software
A custom Linux [kernel configuration](board/raspberrypi/kernel.config) is used to minimize resource usage.

Most of the hardware configuration is done through custom [config.txt](board/raspberrypi/config.txt). Most notably:
* we [enable the SPI](board/raspberrypi/config.txt#L28) interface
* we enable [gpio-leds](board/raspberrypi/config.txt#L40) overlay for enabling LED control in Linux through sysfs

The default configuration has both NTP & SSH enabled, so you should be able
to SSH into the device. The default credentials are:
* username: `rpi`
* password: `test1234`

*NOTE:* The CI images use password that's configured as repository secret.

By default, this user is part of the `sudo` group.

### Hardware

RaspberryPi [pinout reference](https://pinout.xyz)

* [RFID RF522 module](https://botland.com.pl/moduly-i-tagi-rfid/6765-modul-rfid-mf-rc522-1356mhz-spi-karta-i-brelok-5904422335014.html)
  - `SDA` connected to header pin 24 (`SPI0 CE0`)
  - `SCK` connected to header pin 23 (`SPI0 SCLK`)
  - `MOSI` connected to header pin 19 (`SPI0 MOSI`)
  - `MISO` connected to header pin 21 (`SPI MISO`)
  - `IRQ` connected to header pin 22 (`GPIO 25`)
  - `RST` connected to header pin 18 (`GPIO 24`)

* [Movement sensor PIR HW-740](https://pl.aliexpress.com/item/1005004748108000.html)
  - data pin connected to header pin 37 (`GPIO 26`)

* Red LED
  - connected to header pin 29 (`GPIO 5`)

* Green LED
  - connected to header pin 31 (`GPIO 6`)

*NOTE*: While this specific configuration describes RaspberryPi4,
since we're using RPIs native `config.txt` file for DeviceTree overlays,
switching to a different RaspberryPi should be no problem.

## Building

To build the image by yourself:

1. Clone the repo with submodules
```bash
git clone --recurse-submodules https://github.com/rosowskimik/br-rpi
cd br-rpi
```

2. Setup the default configuration
```bash
cd buildroot
make BR2_EXTERNAL=../ raspberrypi4_64_custom_defconfig
```

3. (Optional) Customize the image
```bash
make nconfig
```

4. Build the image
```bash
make -j`nproc`
```

The resulting image should be available in `output/images/sdcard.img`.
To flash it to an SD card you can run
```bash
dd if=path/to/sdcard.img of=/dev/my-sdcard bs=4M conv=fsync oflag=direct status=progress
```

For more details on using Buildroot refer to [Buildroot manual](https://buildroot.org/downloads/manual/manual.html).
You can also check the [CI script](.github/workflows/build_image.yml) that's used to auto-build the image.

## Other repos
* [Kernel](https://github.com/rosowskimik/linux-rpi)
* [Application](https://github.com/rosowskimik/card_reader)
* [API](https://github.com/Quar15/SimpleSecuritySystem)

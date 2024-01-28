# Card Reader Image
Student project for IOT - Door locking device

![Preview](data/preview.mp4)

## Description
This is the central repository containing external tree for Buildroot
to create a fully custom Linux image that can be deployed to supported
devices.

## Configuration

### Software
A custom Linux kernel configuration is used to minimize resource usage.

Most of the hardware configuration is done through custom [config.txt](board/raspberrypi/config.txt). Most notably:
* we [enable the SPI](board/raspberrypi/config.txt#L28) interface
* we enable [gpio-leds](board/raspberrypi/config.txt#L40) overlay for enabling LED control in Linux through sysfs

The default configuration has both NTP & SSH enabled, so you should be able
to SSH into the device. The default credentials are:
* username: `rpi`
* password: `test1234`

*NOTE:* The CI images use password that's configured as repository secret.

The client application can be configured in its section in Buildroot.
The `card_reader` application can also be configured on per-device basis
using the configuration file `/etc/xdg/card_reader/config.yml`.

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

### Hardware

RaspberryPi [pinout reference](https://pinout.xyz)

* [RFID RF522 module](https://botland.com.pl/moduly-i-tagi-rfid/6765-modul-rfid-mf-rc522-1356mhz-spi-karta-i-brelok-5904422335014.html)
  - `SDA` connected to header 24 (`SPI0 CE0`)
  - `SCK` connected to header 23 (`SPI0 SCLK`)
  - `MOSI` connected to header 19 (`SPI0 MOSI`)
  - `MISO` connected to header 21 (`SPI MISO`)
  - `IRQ` connected to header 22 (`GPIO 25`)
  - `RST` connected to header 18 (`GPIO 24`)

* [Movement sensor PIR HW-740](https://pl.aliexpress.com/item/1005004748108000.html)
  - data pin connected to header 37 (`GPIO 26`)

* Red LED
  - connected to header 29 (`GPIO 5`)

* Green LED
  - connected to header 31 (`GPIO 6`)


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

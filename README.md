# sdrplay_container
a linux I/Q stream server for SDRPlay RSP1, RSP1A, RSP2, RSPDuo (single tuner mode)

## Main features
- [RSP_TCP server](https://github.com/f4fhh/rsp_tcp) is a rtl_tcp compatible IQ server that will work with any rtl_tcp capable frontend (like SDRSharp) but with 8 bits resolution only.
- [SoapySDRPlay](https://github.com/pothosware/SoapySDRPlay) module with the [SoapyRemote](https://github.com/pothosware/SoapyRemote) server allows SoapySDR compliant clients like CubicSDR to access the radio remotely.

## Other features
The container also support RTL-SDR dongles and dump1090/flightradar tools, it contains:
- [RTL-SDR](https://github.com/osmocom/rtl-sdr) tools and [SoapySDRRTL](https://github.com/pothosware/SoapyRTLSDR) module. You have the choice to run rtl_tcp or soapyremote protocol for RTL-SDR remote access.
- [dump1090-mutability](https://github.com/mutability/dump1090), a mode S decoder both for SDRPlay or RTL-SDR.
- A [Flightradar24 feeder](https://www.flightradar24.com/share-your-data) that can use dump1090 for SDRPlay

## Starting the container
- Interactive access
```shell
docker run --rm -p 1234:1234 -p 8080:8080 -p 8754:8754 -p 55132:55132 --privileged -v /dev/bus/usb:/dev/bus/usb -v  /mnt/user/appdata/fr24feed-piaware/config.js:/usr/lib/fr24/public_html/config.js -v /mnt/user/appdata/fr24feed-piaware/fr24feed.ini:/etc/fr24feed.ini -it sdrplay_container
```
- SDRPlay rsp_tcp server (rtl_tcp compatible server)
```shell
docker run -d -p 1234:1234 --privileged -v /dev/bus/usb:/dev/bus/usb sdrplay_container rsp_tcp -a 0.0.0.0
```
- SoapyRemote server for both SDRPlay and RTL-SDR
```shell
docker run -d --network="host" --privileged -v /dev/bus/usb:/dev/bus/usb sdrplay_container SoapySDRServer --bind
```
The "host" networking mode is mandatory in this case as SoapySDRServer listens on dynamic UDP ports.
- RTL-SDR rtl_tcp server
```shell
docker run -d -p 1234:1234 --privileged -v /dev/bus/usb:/dev/bus/usb sdrplay_container rtl_tcp -a 0.0.0.0
```
- Dump1090 for SDRPlay
```shell
docker run -d -p 8080:8080 --privileged -v /dev/bus/usb:/dev/bus/usb -v <path_to_your>/config.js:/usr/lib/fr24/public_html/config.js sdrplay_container /usr/lib/fr24/dump1090 --net --dev-sdrplay --normal --oversample
```
dump1090 available command line options for the SDRPlay:
```
--dev-sdrplay – Must be set. 
--modeac – enable decoding of SSR modes 3/A & 3/C 
--oversample – use the 8MHz demodulator (default: 2MHz demodulator) 
--normal – this configures the RSP for standard options 
--enable-BiasT – use this to turn on the BiasT for RSP1A or RSP2 
--rsp2-antenna-portA – select antenna port A on the RSP2 (default: port B) 
--rsp-device-serNo <serNo> – Useful to select a device if multiple RSPs are connected. 
--rsp1aNotchEn <enable> – specify 0 disable (default) or 1 for enable for the RSP1A Broadcast Notch 
--ifMode 0 – specify <ifMode> for ZeroIF (default) or 1 for Low IF 
--bwMode 0 – specify <bwMode> for 1.536MHz or 1 for 5MHz (default) 
--interactive – display aircraft data in a table in the command prompt 
--quiet – Disable output to the command prompt 
```
- Dump1090 for RTL-SDR
```shell
docker run -d -p 8080:8080 --privileged -v /dev/bus/usb:/dev/bus/usb -v <path_to_your>/config.js:/usr/lib/fr24/public_html/config.js sdrplay_container /usr/lib/fr24/dump1090 --net
```
- Flightradar24 for SDRPlay or RTL-SDR
```shell
docker run -d -p 8080:8080 --privileged -v /dev/bus/usb:/dev/bus/usb -v <path_to_your>/config.js:/usr/lib/fr24/public_html/config.js -v <path_to_your>/fr24feed.ini:/etc/fr24feed.ini sdrplay_container /usr/lib/fr24/fr24feed
```
fr24feed.ini example:
```
receiver="dvbt"
fr24key="XXXXXXXXXXXXX"
bs="yes"
raw="yes"
logmode="1"
procargs="--write-json /usr/lib/fr24/public_html/data --net"
windowmode="0"
mpx="no"
mlat="no"
mlat-without-gps="no"
```
For SDRPlay, add dump1090 command line options to the "procargs" key.


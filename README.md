# DropAP

DropAp simply creates an isolated disposible WiFi
LAN from an TL-MR3020 flashed with OpenWrt. This 
device is a small portable AP router, manufactured 
by TP-Link.

 To Run: 

 copy the folder to the MR3020 /root/ once it is 
 flashed with OpenWrt, then:
```
  ./create-DropAP.sh
```

## COMPATIBILITY
The script was developed on the OpenWRT bin for the 
TL-MR3020. So if the OpenWRT .bin file system is not 
any different for your platform then this should 
work just fine for you, procceed at your own risk.
  
This provides more flexibility to serve as a public 
file-cache available to anyone within range of 
it's wifi transmission.

also one can use this along with the OpenWrt package
wknock for more private desemination. 

It's location is "anywhere" as it's a small travel 
router making it portable and not to difficult to 
power with a battery.

A simple battery power supply can be made using 
alkaline batteries as they are trash safe and a
DC-DC Boost Module 2-5V to 5V 1200mA 1.2A

```
       ---------  ---------  ---------
      -| D-Cell|+-| D-Cell|+-| D-Cell|+|
     | ---------  ---------  --------- /
      \____________   ________________/
                  |   |
             ----------------
              boost voltage 
                regulator
              (hxn=ap c0303)
             ----------------
                  |   |
                  |   |
                 --------
                  -USB+               
                  MR3020 
                ----------
```

The voltage regulator personally tested is 
based off the c0303 HXN=AP IC. 

circuit specs (what I used):
input voltage: 2.0V ~ 5.0V
No load output voltage: 5.1V +/-0.1V

Maximum output current
```
Input VDC | Output current
--------------------------
     2.0v | 600ma
     2.5v | 800ma
     3.0v | 1000ma
     3.5v | 1200ma
--------------------------
```

With these results the boost converter with 3 D cells 
in series would be able to power the MR3020 for about
two days. You should be able to find these on ebay 
for a few bucks each. 

If not then find a suitable substitute that has
similar performance. 

This is inspired by a Pirate Box but with the 
intention of making the device disposable.



nightowlconsulting.com

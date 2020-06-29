#!/bin/bash

PATH=$PATH:/opt/axiom-firmware/software/scripts/

. cmv.func
. hdmi.func

fclk_init.sh
power_init.sh
power_on.sh

echo "loading gateware ..."
echo preeti_38.bin > /sys/class/fpga_manager/fpga0/firmware

echo "fil_reg 11: `fil_reg 11`"
echo "fil_regi 4: `fil_regi 4`"
echo "fil_regi 8: `fil_regi 8`"

scn_reg 22 0
scn_reg 23 0

echo "initializations ..."
gen_init.sh 1080p60
data_init.sh
rmem_conf.sh

# wmem_conf.sh

#    load buffer addresses

fil_reg 0 0x18000000
fil_reg 1 0x19FF0000

fil_reg 2 0x1A000000
fil_reg 3 0x1BFF0000

fil_reg 4 0x1C000000
fil_reg 5 0x1DFF0000

fil_reg 6 0x1E000000
fil_reg 7 0x1FFF0000

#    setup cinc/rinc/ccnt

fil_reg 8 0x80
fil_reg 9 0x80
fil_reg 10 0x7E

#    training pattern

fil_reg 12 0xA95
#    mask

fil_reg 13 0x070707

axiom-linear-identity.sh
axiom-rcn-clear.py

# linear_conf.sh
gamma_conf.sh

scn_reg 31 3
scn_reg 31 1

./memtool -2 -F 0x55555555 0x18000000 0x01000000
./memtool -4 -d 0x18000000 0x100

echo "fil_regi 4: `fil_regi 4`"
echo "fil_regi 8: `fil_regi 8`"

# enable fake data generation

fil_reg 11 0xFC31F200

fil_reg 11 0xFC01F010
fil_reg 15 0x1000100

echo "fil_regi 4: `fil_regi 4`"
echo "fil_regi 8: `fil_regi 8`"
echo "fil_regi 9: `fil_regi 9`"
echo "fil_regi 10: `fil_regi 10`"
echo "fil_regi 11: `fil_regi 11`"

./memtool -8 -d 0x18000000 0x200


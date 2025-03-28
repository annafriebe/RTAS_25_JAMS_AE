# !/bin/bash

sudo echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
sudo echo performance > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
sudo echo performance > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
sudo echo performance > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

sudo echo '1-1' | tee /sys/bus/usb/drivers/usb/unbind

sudo ./libmpc-0.6.2/examples/bin/ugv_ex_short > ugv_ex_outputs/output_short_1.txt

sudo echo '1-1' | tee /sys/bus/usb/drivers/usb/bind

sudo echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
sudo echo ondemand > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
sudo echo ondemand > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
sudo echo ondemand > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

sleep 10s

echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

echo '1-1' | tee /sys/bus/usb/drivers/usb/unbind

./libmpc-0.6.2/examples/bin/ugv_ex_short > ugv_ex_outputs/output_short_2.txt

echo '1-1' | tee /sys/bus/usb/drivers/usb/bind

echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

sleep 10s

echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

echo '1-1' | tee /sys/bus/usb/drivers/usb/unbind

./libmpc-0.6.2/examples/bin/ugv_ex_short > ugv_ex_outputs/output_short_3.txt

echo '1-1' | tee /sys/bus/usb/drivers/usb/bind

echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

sleep 10s

echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

echo '1-1' | tee /sys/bus/usb/drivers/usb/unbind

./libmpc-0.6.2/examples/bin/ugv_ex_short > ugv_ex_outputs/output_short_4.txt

echo '1-1' | tee /sys/bus/usb/drivers/usb/bind

echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

sleep 10s
echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

echo '1-1' | tee /sys/bus/usb/drivers/usb/unbind

./libmpc-0.6.2/examples/bin/ugv_ex_short > ugv_ex_outputs/output_short_5.txt

echo '1-1' | tee /sys/bus/usb/drivers/usb/bind

echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

sleep 10s
echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

echo '1-1' | tee /sys/bus/usb/drivers/usb/unbind

./libmpc-0.6.2/examples/bin/ugv_ex_short > ugv_ex_outputs/output_short_6.txt

echo '1-1' | tee /sys/bus/usb/drivers/usb/bind

echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
sleep 10s
echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

echo '1-1' | tee /sys/bus/usb/drivers/usb/unbind

./libmpc-0.6.2/examples/bin/ugv_ex_short > ugv_ex_outputs/output_short_7.txt

echo '1-1' | tee /sys/bus/usb/drivers/usb/bind

echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
sleep 10s
echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

echo '1-1' | tee /sys/bus/usb/drivers/usb/unbind

./libmpc-0.6.2/examples/bin/ugv_ex_short > ugv_ex_outputs/output_short_8.txt

echo '1-1' | tee /sys/bus/usb/drivers/usb/bind

echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
sleep 10s
echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

echo '1-1' | tee /sys/bus/usb/drivers/usb/unbind

./libmpc-0.6.2/examples/bin/ugv_ex_short > ugv_ex_outputs/output_short_9.txt

echo '1-1' | tee /sys/bus/usb/drivers/usb/bind

echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
sleep 10s
echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

echo '1-1' | tee /sys/bus/usb/drivers/usb/unbind

./libmpc-0.6.2/examples/bin/ugv_ex_short > ugv_ex_outputs/output_short_0.txt

echo '1-1' | tee /sys/bus/usb/drivers/usb/bind

echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

sudo insmod tasklet_int.ko

echo ">>>>> showing /proc/interrupts"

cat /proc/interrupts

echo ">>>>> time to move mouse..."

sleep 2.0

echo ">>>>> result:"

cat /proc/tasklet_info

sleep 0.5

sudo rmmod tasklet_int.ko




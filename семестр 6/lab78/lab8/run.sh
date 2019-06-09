sudo insmod wqueue.ko

echo ">>>>> showing /proc/interrupts"

cat /proc/interrupts

echo ">>>>> time to move mouse..."

sleep 2.0

echo ">>>>> result:"

cat /proc/wq_info

sleep 0.5

sudo rmmod wqueue.ko




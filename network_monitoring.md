https://stackoverflow.com/questions/596590/how-can-i-get-the-current-network-interface-throughput-statistics-on-linux-unix

1. Perl script: curses-like,reads from /sys/class/net/eth0/statistics:
```
rx_bytes                       :       411483694     100     155     109      96
rx_compressed                  :               0       0       0       0       0
rx_crc_errors                  :               0       0       0       0       0
rx_dropped                     :               0       0       0       0       0
rx_errors                      :               0       0       0       0       0
rx_fifo_errors                 :               0       0       0       0       0
rx_frame_errors                :               0       0       0       0       0
rx_length_errors               :               0       0       0       0       0
rx_missed_errors               :               0       0       0       0       0
rx_nohandler                   :               0       0       0       0       0
rx_over_errors                 :               0       0       0       0       0
rx_packets                     :         1094364       2       3       2       1
tx_aborted_errors              :               0       0       0       0       0
tx_bytes                       :        75245787    2252    2308    2262    2299
tx_carrier_errors              :               0       0       0       0       0
tx_compressed                  :               0       0       0       0       0
tx_dropped                     :               0       0       0       0       0
tx_errors                      :               0       0       0       0       0
tx_fifo_errors                 :               0       0       0       0       0
tx_heartbeat_errors            :               0       0       0       0       0
tx_packets                     :          913652       2       2       2       1
tx_window_errors               :               0       0       0       0       0
eth0                           : 22:48:50.000755      1s      5s     15s     60s

```
1. [ec2-user@ip-172-31-38-111 network_monitoring]$ sar -n DEV 1 |egrep -vw 'lo|docker0'
```
10:49:56 PM     IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s
10:49:57 PM      eth0      0.99      0.99      0.04      0.32      0.00      0.00      0.00
```
1. [ec2-user@ip-172-31-38-111 network_monitoring]$ cat /proc/net/dev
```
Inter-|   Receive                                                |  Transmit
 face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed
  eth0: 411661445 1097018    0    0    0     0          0         0 77996878  916249    0    0    0     0       0          0
    lo:       0       0    0    0    0     0          0         0        0       0    0    0    0     0       0          0
docker0:       0       0    0    0    0     0          0         0        0       0    0    0    0     0       0          0
```
1. cat /sys/class/net/eth0/statistics/rx_bytes /sys/class/net/eth0/statistics/tx_bytes
```
411508060
75439950
```
1. bin/bwm-ng: in C, simply displays /proc/net/dev. in curses window
```
 bwm-ng v0.6.1 (probing every 1.000s), press 'h' for help
  input: /proc/net/dev type: avg (30s)
  |         iface                   Rx                   Tx                Total
  ==============================================================================
             eth0:         275.44  B/s          441.41  B/s          716.85  B/s
  ------------------------------------------------------------------------------
            total:         275.44  B/s          441.41  B/s          716.85  B/s

```
```bash
#!/bin/bash
# https://stackoverflow.com/questions/596590/how-can-i-get-the-current-network-interface-throughput-statistics-on-linux-unix/674400#6744000
IF=$1
if [ -z "$IF" ]; then
        IF=`ls -1 /sys/class/net/ | head -1`
fi
RXPREV=-1
TXPREV=-1
echo "Listening $IF..."
while [ 1 == 1 ] ; do
        RX=`cat /sys/class/net/${IF}/statistics/rx_bytes`
        TX=`cat /sys/class/net/${IF}/statistics/tx_bytes`
        if [ $RXPREV -ne -1 ] ; then
                let BWRX=$RX-$RXPREV
                let BWTX=$TX-$TXPREV
                echo "Received: $BWRX B/s    Sent: $BWTX B/s"
        fi
        RXPREV=$RX
        TXPREV=$TX
        sleep 1
done
[ec2-user@ip-172-31-38-111 network_monitoring]$ ./1.sh eth0
Listening eth0...
Received: 160 B/s    Sent: 108 B/s
Received: 100 B/s    Sent: 236 B/s
```
```bash
#!/bin/sh
# https://stackoverflow.com/questions/596590/how-can-i-get-the-current-network-interface-throughput-statistics-on-linux-unix/674400#674400
S=1; F=/sys/class/net/eth0/statistics/tx_bytes
TXS=999999
while [ $TXS -gt 1 ]
do
  X=`cat $F`; sleep $S; Y=`cat $F`; TXS="$(((Y-X)/S))";
  echo TXS is currently $TXS
done
echo 'ALARM TXS is low'
[ec2-user@ip-172-31-38-111 network_monitoring]$ ./2.sh
TXS is currently 310

```
1. https://github.com/ntop/ntopng
1. [ec2-user@ip-172-31-38-111 dev]$ ./1.sh eth0   
```
Received: 104 B/s    Sent: 0 B/s
```
1. ip -s -d  -c link; ip -s -d  -c -h link
```
RX: bytes  packets  errors  dropped overrun mcast 
      409M       1.07M    0       0       0       0    
TX: bytes  packets  errors  dropped carrier collsns                                                    
       68.7M      889k     0       0       0       0
```
1. netstat -i is obsolete, replacement is ip -c link
netstat --statistics gives very detailed view
1. ifconfig
```
eth0      Link encap:Ethernet  HWaddr 0A:17:90:50:97:D8
          inet addr:172.31.38.111  Bcast:172.31.47.255  Mask:255.255.240.0
          inet6 addr: fe80::817:90ff:fe50:97d8/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:9001  Metric:1
          RX packets:1098423 errors:0 dropped:0 overruns:0 frame:0
          TX packets:917541 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:411760050 (392.6 MiB)  TX bytes:78348021 (74.7 MiB)
```
1. iftop: good, but interactive(curses-based), and requires root

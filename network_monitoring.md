https://stackoverflow.com/questions/596590/how-can-i-get-the-current-network-interface-throughput-statistics-on-linux-unix

1. Perl script is good!
1. sar -n DEV 1 3
1. /sys/class/net/eth0/statistics/rx_bytes; /sys/class/net/eth0/statistics/tx_bytes
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

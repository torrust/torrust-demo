# UDP Connection Tracking Optimization for Ubuntu/Debian

## Overview

By default, Linux systems track all network connections, including UDP connections, through the netfilter connection tracking system. For BitTorrent trackers that handle thousands of UDP connections, this connection tracking can become a significant performance bottleneck and consume excessive memory.

This guide explains how to disable UDP connection tracking specifically for your Torrust Tracker to improve performance.

## Why Disable UDP Connection Tracking?

- **Performance**: UDP trackers don't need connection state tracking
- **Memory Usage**: Connection tracking tables can consume significant RAM
- **Scalability**: Allows handling more concurrent UDP connections
- **Reduced Latency**: Eliminates connection tracking overhead

## Prerequisites

- Ubuntu/Debian-based system
- Root access or sudo privileges
- Basic understanding of iptables/netfilter

## Disclaimer

**IMPORTANT**: Apparently this does not work with the current docker configuration. But you can try if you run the tracker without docker. See <https://github.com/torrust/torrust-demo/issues/72->

## Method 1: Using iptables NOTRACK (Recommended)

### Step 1: Identify Your Tracker Port

First, identify the UDP port your Torrust Tracker is using. Check your tracker configuration:

```bash
# Example: if your tracker runs on port 6969
TRACKER_PORT=6969
```

### Step 2: Add NOTRACK Rules

Add iptables rules to disable connection tracking for UDP traffic on your tracker port:

```bash
# Disable connection tracking for incoming UDP traffic on tracker port
sudo iptables -t raw -A PREROUTING -p udp --dport $TRACKER_PORT -j NOTRACK

# Disable connection tracking for outgoing UDP traffic from tracker port
sudo iptables -t raw -A OUTPUT -p udp --sport $TRACKER_PORT -j NOTRACK
```

### Step 3: Make Rules Persistent

#### For Ubuntu 18.04+ / Debian 10+

Install iptables-persistent:

```bash
sudo apt update
sudo apt install iptables-persistent
```

Save current rules:

```bash
sudo iptables-save > /etc/iptables/rules.v4
```

#### For older systems using iptables-save

```bash
# Save rules
sudo sh -c 'iptables-save > /etc/iptables.rules'

# Create restore script
sudo tee /etc/network/if-pre-up.d/iptables << 'EOF'
#!/bin/bash
iptables-restore < /etc/iptables.rules
EOF

sudo chmod +x /etc/network/if-pre-up.d/iptables
```

## Method 2: Using nftables (Modern Alternative)

If your system uses nftables instead of iptables.

You can install and check with:

```bash
sudo apt install nftables
# Edit the file
sudo vim /etc/nftables.conf
# Apply and reload rules
sudo systemctl restart nftables
# Verify rules are active
sudo nft list ruleset
# Verify is not being tracker
sudo conntrack -F
sudo conntrack -L | grep 6969
# Reboot the server
sudo reboot
# Confirm nftables rules are active
sudo nft list ruleset | grep notrack
```

You can see the configuration used in the demo in the file [share/server/linux/etc/nftables.conf](../../../share/server/linux/etc/nftables.conf) in the Torrust demo server.

### Step 1: Create nftables Configuration

Create or edit `/etc/nftables.conf`:

```bash
sudo nano /etc/nftables.conf
```

Add the following rules:

```nftables
#!/usr/sbin/nft -f

flush ruleset

table inet raw {
    chain prerouting {
        type filter hook prerouting priority raw; policy accept;
        
        # Disable connection tracking for tracker UDP traffic
        udp dport 6969 notrack
    }
    
    chain output {
        type filter hook output priority raw; policy accept;
        
        # Disable connection tracking for outgoing tracker UDP traffic
        udp sport 6969 notrack
    }
}
```

### Step 2: Enable and Start nftables

```bash
sudo systemctl enable nftables
sudo systemctl start nftables
```

## Method 3: Kernel Parameter Tuning

For extreme performance scenarios, you can also tune connection tracking parameters:

### Edit sysctl configuration

```bash
sudo nano /etc/sysctl.conf
```

Add the following lines:

```conf
# Increase connection tracking table size
net.netfilter.nf_conntrack_max = 1048576

# Reduce connection tracking timeout for UDP
net.netfilter.nf_conntrack_udp_timeout = 30
net.netfilter.nf_conntrack_udp_timeout_stream = 60

# Disable connection tracking helper modules if not needed
net.netfilter.nf_conntrack_helper = 0
```

Apply the changes:

```bash
sudo sysctl -p
```

## Verification

### Check if rules are applied

For iptables:

```bash
sudo iptables -t raw -L -n -v
```

For nftables:

```bash
sudo nft list ruleset
```

### Monitor connection tracking table

```bash
# Check current connection count
cat /proc/sys/net/netfilter/nf_conntrack_count

# Check maximum connections
cat /proc/sys/net/netfilter/nf_conntrack_max

# Monitor connection tracking table
sudo conntrack -L | grep udp
```

### Test tracker performance

Monitor your tracker's performance before and after applying these changes. You should see:

- Reduced memory usage
- Lower CPU utilization for network processing
- Improved response times for UDP tracker requests

## Troubleshooting

### Rules not persisting after reboot

- Ensure iptables-persistent is properly installed and configured
- Verify the rules file exists and has correct permissions
- Check system logs for any error messages

### High memory usage persists

- Verify rules are correctly applied using the verification commands above
- Check if other services are creating tracked connections
- Consider reducing `nf_conntrack_max` if memory is still high

### Tracker not responding

- Ensure firewall rules allow UDP traffic on tracker port
- Verify the tracker is binding to the correct interface
- Check tracker logs for any connection issues

## Security Considerations

- Disabling connection tracking removes some netfilter security features
- Ensure your firewall rules properly restrict access to tracker ports
- Monitor for any unusual network activity
- Consider implementing rate limiting at the application level

## Performance Impact

Expected improvements after implementing UDP connection tracking optimization:

- **Memory Usage**: 50-80% reduction in connection tracking memory usage
- **CPU Usage**: 10-30% reduction in network processing overhead
- **Latency**: Reduced UDP packet processing latency
- **Throughput**: Higher concurrent connection capacity

## Related Optimizations

Consider implementing these additional optimizations alongside UDP connection tracking:

- Increase UDP receive buffer sizes
- Optimize file descriptor limits
- Configure CPU affinity for tracker processes
- Implement proper load balancing for multi-instance deployments

## References

- [Netfilter Connection Tracking Documentation](https://www.netfilter.org/documentation/HOWTO/netfilter-hacking-HOWTO-3.html)
- [Linux Network Performance Tuning](https://www.kernel.org/doc/Documentation/networking/scaling.txt)
- [iptables NOTRACK target](https://ipset.netfilter.org/iptables-extensions.man.html#lbBU)

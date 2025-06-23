# Server Optimization

This section contains guides for optimizing server performance when running Torrust Tracker and Index applications. These optimizations can significantly improve performance, especially for high-traffic deployments.

## Operating System Specific Guides

### Linux

- [UDP Connection Tracking Optimization](./server-optimization/linux/udp-connection-tracking.md) - Disable connection tracking for UDP to improve tracker performance

## General Recommendations

- Ensure adequate system resources (RAM, CPU, storage)
- Configure appropriate file descriptor limits
- Optimize network buffer sizes
- Consider using SSD storage for database operations
- Monitor system performance metrics

## Performance Monitoring

For monitoring your Torrust deployment performance, refer to the [Grafana dashboards](../share/grafana/dashboards/) included in this repository.

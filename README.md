# Kemp LB AppDynamics Custom Extension

**Requirement:** Be able to monitor a Kemp Load Balancer where we cannot have an agent installed.

Kemp support, offers an API that can communicate to the load balancer to obtain metrics: https://support.kemptechnologies.com/hc/en-us/articles/203863435-RESTful-API#MadCap_TOC_4_1

A script was developed to make calls to the Statistics (stats) Kemp API. Refer the link for an overview of the metrics pulled by the [API](https://support.kemptechnologies.com/hc/en-us/articles/203863435-RESTful-API#MadCap_TOC_48_2)

The implemented solution was a [Custom AppDynamics Extension](https://docs.appdynamics.com/display/PRO45/Build+a+Monitoring+Extension+Using+Scripts) placed in the Machine Agent  

The Extension Files provided and installed at <MachineAgentHome>/monitors are:
* Function-LogWrite.ps1
* monitor.properties - Refer below the configuration needed.
*	monitor.xml
*	runMonitor.bat
* runMonitor.ps1
* stats.xml

The extension calls the API every minute and reports the metrics to the AppDynamics controller.

## Define configuration file: monitor.properties
* Properties file to define the Kemp API key, host (IP), the monitored IP’s and Ports and the metric path in the controller. **If the IP and Port properties are going to be used** then refer the below:
  * kemp_lb_ip= MANDATORY
  * kemp_api_key=MANDATORY
  * monitored_vs_ips= MANDATORY, comma separated values
  * monitored_vs_ports= OPTIONAL,comma separated values or ALL if empty
  * monitored_rs_ips= MANDATORY,comma separated values
  * monitored_rs_ports= OPTIONAL, comma separated values or ALL if empty.
  * metric_path=Custom Metrics|Kemp LB|

*  **If IP and Port are left empty for either Vs or Rs**, then ALL IPs and ALL PORTS will be retrieved.:

## Metrics

The metrics generated are the metrics that are part of the Stats API from Kemp, the ones in the extension are:

* CPU
  * Metric Path: Custom Metrics|Kemp LB|CPU|Total
  * Metrics:
    * User
    * System
    * Idle
    * IOWaiting

  * Metric Path: Custom Metrics|Kemp LB|CPU|cpu<id>
    * Metrics:
    * User
    * System
    * HWInterrupts
    * HWInterrupts
    * Idle
    * IOWaiting

* Memory
  * Metric Path: Custom Metrics|Kemp LB| Memory
  * Metrics:
    * MBtotal
    * memused
    * MBused
    * percentmemused
    * memfree
    * MBfree
    * percentmemfree

* Network
  * Metric Path: Custom Metrics|Kemp LB| Network|eth<id>
  * Metrics:
    * ifaceID
    * speed
    * in
    * inbytes
    * inbytesTotal
    * out
    * outbytes
    * outbytesTotal

* Disk Usage
  * Metric Path: Custom Metrics|Kemp LB|DiskUsage|partition|<partition name>
  * Metrics:
    * GBtotal
    * GBused
    * percentused
    * GBfree
    * percentfree

* VS Totals (Virtual Servers)
  * Metric Path: Custom Metrics|Kemp LB| VStotals
  * Metrics:
    * ConnsPerSec
    * TotalConns
    * BitsPerSec
    * TotalBits
    * BytesPerSec
    * TotalBytes
    * PktsPerSec
    * TotalPackets

* Vs (Virtual Servers)
  * The configuration of the monitor.properties determines what IP and ports are being reported (monitored_vs_ips and monitored_vs_ports).
  * The Index metric in the response was not included.
  * Metric Path:  Custom Metrics|Kemp LB|Vs| <IP>|<protocol>|Port|<Port>|
  * Metrics:
    * Status (If up, 1, else, 0)
    * ErrorCode
    * Enable
    * TotalConns
    * TotalPkts
    * TotalBytes
    * TotalBits
    * ActiveConns
    * BytesRead
    * BytesWritten
    * ConnsPerSec
    * WafEnable

* Rs
  * The configuration of the monitor.properties determines what IP and ports are being reported (monitored_rs_ips and monitored_rs_ports).
  * The VSIndex, RSIndex metrics in the response were not included.
  * Metric Path:  Custom Metrics|Kemp LB|Rs|<IP>|Port|<Port>
  * Metrics:
    * Enable
    * Weight
    * ActivConns
    * Persist
    * Conns
    * Pkts
    * Bytes
    * Bits
    * BytesRead
    * BytesWritten
    * ConnsPerSec

# Pinger

## What

Simple *expect* script that accepts a list of hosts from a csv file, access a network device (Cisco), ping each host from the device and generated a parsed log file.

## Why

I needed to ping various locations from once from one site wher we didn't have any servers that could do the job.

## How

The script takes to arguments. The firt one is the IP address of the device it should access, and the second is the csv file with the list of hosts it shoud ping.

`./pinger.sh 10.1.1.1 hosts.csv`

`hosts.csv` is an example of csv file the script expects
`csv-20141027133023.log.csv` is an example of the log file the script generates
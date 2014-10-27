#!/usr/bin/expect
package require csv
package require struct::matrix

# creates matrix to handle CSV
struct::matrix hostsmatrix
hostsmatrix add columns 2

#
# Count the number of lines in the hosts list file
#
set device [lindex $argv 0]
set hosts [open [lindex $argv 1] r]
set linecount 0
set nxt_id 0
csv::read2matrix $hosts hostsmatrix ,
seek $hosts 0 start
while { [gets $hosts line] >= 0 } {
    incr linecount
}
close $hosts
send_user "\n"
send_user "There are $linecount hosts in the list\n"
send_user "\n"
set timeout 300
#
# Get username and password
#
send_user "Username: "
expect_user -re "(.*)\n"
set username $expect_out(1,string)
send_user "Password: "
expect_user -re "(.*)\n"
set password $expect_out(1,string)
#
# Telnet and authenticate
#
send_user "Telneting to $device"
spawn telnet $device
expect "username:"
send "$username\r"
expect "password:"
send "$password\r"
expect "#"
send "\r"
#
send_user "Running commands, please be patient\n"
#
# Set log file
#
set mytime [timestamp -format %Y%m%d%H%M%S]
log_file -a "logs/$mytime.log"
send_log "StartTimeStamp\n"
  send_log "initTime [timestamp -format %c]\n"
send_log "EndTimeStamp\n"
send_log "\n"
send_log "\n"
#
# Start pinging
#
set i 0
while {$i < $linecount}  {
  incr nxt_id
  send_log "\n"
  send_log "**********************************************************\n"
  send_log "StartLocation\n"
  send_log "StartLocationIdentity\n"
  send_log "id $nxt_id name [hostsmatrix get cell 0 $i]\n"
  send_log "EndLocationIdentity\n"
  send_log "**********************************************************\n"
  send_log "StartPingInfo\n"
  send "\r"
  expect "#"
  # starting extended ping
  send "ping\r"
  # defining protocol to default
  expect ":"
  send "\r"
  # setting target ip address
  expect ":"
  send "[hostsmatrix get cell 1 $i]\r"
  # setting Repeat count to 500
  expect ":"
  send "500\r"
  # datagram size
  expect ":"
  send "\r"
  # timeout
  expect ":"
  send "\r"
  # extended commands
  expect ":"
  send "\r"
  # sweep
  expect ":"
  send "\r"
  # waiting for ping to be done, giving enough time for the 500 pings to timeout (~18 min)
  expect -timeout 1080 "#"
  incr i
  send_user "\n$i of $linecount\n"
  send_log "EndPingInfo\n"
  send_log "EndLocation\n"
}
send "exit\r"
send_user "Done!\n"
send_log "***************** [timestamp -format %c] *****************\n"

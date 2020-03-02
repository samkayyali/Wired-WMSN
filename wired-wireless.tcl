set ns [new Simulator]

#Define different colors for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Red

#Open the Trace file
set file1 [open out.tr w]
$ns trace-all $file1

#Open the NAM trace file
set file2 [open out.nam w]
$ns namtrace-all $file2

#Define a 'finish' procedure
proc finish {} {
        global ns file1 file2
        $ns flush-trace
        close $file1
        close $file2
        exec nam out.nam &
        exit 0
}

# dynamic R
$ns rtproto DV

#Create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]

#Create links between the nodes
$ns duplex-link $n0 $n1 0.3Mb 10ms DropTail
$ns duplex-link $n1 $n2 0.3Mb 10ms DropTail
$ns duplex-link $n2 $n3 0.3Mb 10ms DropTail
$ns duplex-link $n1 $n4 0.3Mb 10ms DropTail
$ns duplex-link $n3 $n5 0.5Mb 10ms DropTail
$ns duplex-link $n4 $n5 0.5Mb 10ms DropTail
$ns duplex-link $n2 $n6 0.5Mb 10ms DropTail
$ns duplex-link $n6 $n7 0.5Mb 10ms DropTail
$ns duplex-link $n7 $n8 0.5Mb 10ms DropTail
$ns duplex-link $n8 $n5 0.5Mb 10ms DropTail

#Set Queue Size of link (n8-n5) to 10
$ns queue-limit $n8 $n5 10

#Give node position (for NAM)
$ns duplex-link-op  $n0 $n1 orient right
$ns duplex-link-op  $n1 $n2 orient right
$ns duplex-link-op $n2 $n3 orient up
$ns duplex-link-op $n1 $n4 orient up-left
$ns duplex-link-op  $n3 $n5 orient left-up
$ns duplex-link-op  $n4 $n5 orient right-up
$ns duplex-link-op $n2 $n6 orient right
$ns duplex-link-op $n6 $n7 orient right-up
$ns duplex-link-op $n7 $n8 orient left-up
$ns duplex-link-op $n8 $n5 orient left


#Monitor the queue for link (n8-n5). (for NAM)
$ns duplex-link-op $n8 $n5 queuePos 0.5

#Setup a TCP connection
set tcp [new Agent/TCP/Newreno]
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink/DelAck]
$ns attach-agent $n5 $sink
$ns connect $tcp $sink
$tcp set fid_ 1

#Setup a FTP over TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP

$ns rtmodel-at 1.0 down $n1 $n4
$ns rtmodel-at 2.0 down $n2 $n3
$ns rtmodel-at 3.5 up $n2 $n3
$ns rtmodel-at 4.5 up $n1 $n4

$ns at 0.1 "$ftp start"

$ns at 6.0 "finish"

set qfile [$ns monitor-queue $n8 $n5  [open queue.tr w] 0.05]
[$ns link $n8 $n5] queue-sample-timeout;

$ns run

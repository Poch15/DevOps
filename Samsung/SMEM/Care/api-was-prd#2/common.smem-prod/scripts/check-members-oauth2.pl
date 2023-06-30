#!/usr/bin/perl

# This code will wait until timeout it will return a statusCode of 0.


my $timeOK = 0;
my $timeout = 0;
my $iSeconds = 0;
while ($iSeconds < 500) {
    `curl http://localhost:9080/info`;
    my $Status = `echo $?`;
    #print $Status;
    # $seconds OK means that the service is up for 10 seconds.
    if ($Status == 0 && $timeOK >= 10) {
        exit 0;
    }else {
        $timeOK++;
    }
    sleep 1;
    $iSeconds++;
}

die('There is an error starting application');
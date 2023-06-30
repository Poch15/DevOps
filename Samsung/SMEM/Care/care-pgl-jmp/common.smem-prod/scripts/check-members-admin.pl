#!/usr/bin/perl

# This code will wait until timeout it will return a statusCode of 0.


my $timeOK = 0;
my $timeout = 0;
my $iTries = 0;
while ($iTries < 15) {
    `curl  --max-time 30 http://admin.samsungmembers.com`;
    #`curl  --max-time 30 http://20.0.0.1`;
    my $Status = `echo $?`;

    print $Status;
    print $timeOK;
    # $seconds OK means that the service is up for 10 seconds.
    if ($Status == 0 && $timeOK >= 10) {
        exit 0;
    }else {
        $timeOK++;
    }
    sleep 1;
    $iTries++;
}

die('There is an error connecting to url');
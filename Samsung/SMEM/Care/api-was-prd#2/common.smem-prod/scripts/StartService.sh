#!/usr/bin/perl

my $d = gmtime();
my ( $CONTAINER_ID ) = @ARGV;
my $process = `docker ps | grep $CONTAINER_ID`;

if ($process eq undef) {
   print "[$d] starting process $CONTAINER_ID\n";
   `docker start $CONTAINER_ID`;
}else {
   # print "[$d] yay!\n"
}
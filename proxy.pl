#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Pod::Usage;
#use ENV qw( http_proxy HTTP_PROXY https_proxy HTTPS_PROXY ftp_proxy FTP_PROXY );

my ($set, $unset, $proxy);
GetOptions(
    'h|help|?' => sub { pod2usage( -verbose => 0 ) },
    'man'      => sub { pod2usage( -verbose => 3 ) },
    'set'      => \$set,
    'unset'    => \$unset,
    'proxy=s'  => \$proxy,
);

if($set)
{
    die "Missing proxy variable" unless $proxy;
    print "Todo: set proxy to $proxy";
}
elsif($unset)
{
    system('unset no_proxy NO_PROXY');
    system('unset all_proxy ALL_PROXY');
    system('unset', 'ftp_proxy', 'FTP_PROXY');
    system('unset', 'http_proxy', 'HTTP_PROXY');
    system('unset', 'https_proxy', 'HTTPS_PROXY');
}



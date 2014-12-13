#!/usr/env perl
use WebService::Vultr;

use strict; use warnings;

# https://www.vultr.com/api/
# All values are examples only - replace with your own!

# Key is found in settings in your Vultr account
my $key = "l/h6Y7pUh.dGreRMk";

my $vultr = WebService::Vultr->new($key);

=pod
print "Account info: " . $vultr->account_info . "\n\n";

print "OS list: " . $vultr->os_list . "\n\n";

print "ISO list: " . $vultr->iso_list . "\n\n";

print "Plans list: " . $vultr->plans_list . "\n\n";

print "Regions availability: " . $vultr->regions_availability('1');

print "Regions list: " . $vultr->regions_list;

print "Server bandwidth" . $vultr->server_bandwidth($subid);

my $param_ref = {
	DCID => '7',
 	VPSPLANID => '29', 
 	OSID => '139'
};
print $vultr->server_create($param_ref);

my $param_ref = {
	SUBID => '1569220',
	reboot => 'yes' 
};
print $vultr->server_create_ipv4($param_ref);

my $param_ref = {
	SUBID => '1569220'
};
print $vultr->server_destroy($param_ref);

my $param_ref = {
	SUBID => '1569220',
	ip => '192.168.0.254' 
};
print $vultr->server_destroy_ipv4($param_ref);

my $param_ref = {
	SUBID => '1569220'
};
print $vultr->server_halt($param_ref);

my $param_ref = {
	SUBID => '1569220',
	label => 'webserver'
};
print $vultr->server_label_set($param_ref);

print $vultr->server_list($subid);

print $vultr->server_list_ipv4();

=cut

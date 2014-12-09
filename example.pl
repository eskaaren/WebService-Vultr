#!/usr/env perl
use Vultr;

use strict; use warnings;

my $key = "abcdefghi123456789";

my $vultr = Vultr->new($key);

print "Account info: " . $vultr->account_info . "\n";

print "OS list: " . $vultr->os_list . "\n";
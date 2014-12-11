use strict; use warnings;
package WebService::Vultr;
use Carp;
use LWP::UserAgent;
use LWP::Protocol::https;

# ABSTRACT: Perl bindings for the Vultr API

=head1 B<HTTP Response Codes>

 200	Function successfully executed
 400	Invalid API location. Check the URL that you are using
 403	Invalid or missing API key. Check that your API key is present and matches your assigned key
 405	Invalid HTTP method. Check that the method (POST|GET) matches what the documentation indicates
 500	Internal server error. Try again at a later time
 412	Request failed. Check the response body for a more detailed description

=cut

my $api = 'https://api.vultr.com';

sub new {
	my ($package, $key) = @_;
	my $ua = LWP::UserAgent->new;

	my $self = { 
		key => "$key",
		api => "$api",
		ua => $ua
	};

	bless $self, $package;
	return $self;
} 

sub get {
	my ($self, $url) = @_;
	my $res = $self->{ua}->get($url);
		#print $res->content;
	if ($res->is_success) {
		if ($res->content =~ /\w+/) {
			return $res->content;
		}
		else {
			return $res->status_line;
		}
	}
	else {
		confess $res->status_line
	}
}

sub post {
	my ($self, $url, $param_ref) = @_;
	my $res = $self->{ua}->post($url, $param_ref);
	if ($res->is_success) {
		if ($res->content =~ /\w+/) {
			return $res->content;
		}
		else {
			return $res->status_line;
		}
	}
	else {
		confess $res->status_line
	}
}

=head1 B<Vultr API methods>

=head2 account_info

Example Response:
{
    "balance": "-5519.11",
    "pending_charges": "57.03",
    "last_payment_date": "2014-07-18 15:31:01",
    "last_payment_amount": "-1.00"
}

=cut

sub account_info {
	my $self = shift;
	my $url = $self->{api} . '/v1/account/info?api_key=' . $self->{key};
	return get($self, $url);
}


=head2 os_list 

Example Response:
{
    "127": {
        "OSID": "127",
        "name": "CentOS 6 x64",
        "arch": "x64",
        "family": "centos",
        "windows": false
    },
    "148": {
        "OSID": "148",
        "name": "Ubuntu 12.04 i386",
        "arch": "i386",
        "family": "ubuntu",
        "windows": false
    }
}

=cut

sub os_list {
	my $self = shift;
	my $url = $self->{api} . '/v1/os/list';
	return get($self, $url);
}


=head2 iso_list

Example Response:
{
    "24": {
        "ISOID": 24,
        "date_created": "2014-04-01 14:10:09",
        "filename": "CentOS-6.5-x86_64-minimal.iso",
        "size": 9342976,
        "md5sum": "ec0669895a250f803e1709d0402fc411"
    }
}

=cut

sub iso_list {
	my $self = shift;
	my $url = $self->{api} . '/v1/iso/list?api_key=' . $self->{key};
	return get($self, $url);
	
}


=head2 plans_list

Example Response:
{
    "1": {
        "VPSPLANID": "1",
        "name": "Starter",
        "vcpu_count": "1",
        "ram": "512",
        "disk": "20",
        "bandwidth": "1",
        "price_per_month": "5.00",
        "windows": false
    },
    "2": {
        "VPSPLANID": "2",
        "name": "Basic",
        "vcpu_count": "1",
        "ram": "1024",
        "disk": "30",
        "bandwidth": "2",
        "price_per_month": "8.00",
        "windows": false
    }
}

=cut

sub plans_list {
	my $self = shift;
	my $url = $self->{api} . '/v1/plans/list';
	return get($self, $url);
}


=head2 regions_availability

(Type of VPS available)

Parameters:
 DCID integer Location to check availability of

Example Response:
[
    40,
    11,
    45,
    29,
    41,
    61
]

=cut

sub regions_availability {
	my ($self, $region) = @_;
	my $url = $self->{api} . '/v1/regions/availability?DCID=' . $region;
	return get($self, $url);
}


=head2 regions_list

Example Response:
{
    "1": {
        "DCID": "1",
        "name": "New Jersey",
        "country": "US",
        "continent": "North America",
        "state": "NJ"
    },
    "2": {
        "DCID": "2",
        "name": "Chicago",
        "country": "US",
        "continent": "North America",
        "state": "IL"
    }
}

=cut

sub regions_list {
	my ($self, $region) = @_;
	my $url = $self->{api} . '/v1/regions/list';
	return get($self, $url);
}


=head2 server_bandwidth

Parameters:
 SUBID integer Unique identifier for this subscription.  These can be found using the v1/server/list call.

Example Response:
{
    "incoming_bytes": [
        [
            "2014-06-10",
            "81072581"
        ],
        [
            "2014-06-11",
            "222387466"
        ],
        [
            "2014-06-12",
            "216885232"
        ],
        [
            "2014-06-13",
            "117262318"
        ]
    ],
    "outgoing_bytes": [
        [
            "2014-06-10",
            "4059610"
        ],
        [
            "2014-06-11",
            "13432380"
        ],
        [
            "2014-06-12",
            "2455005"
        ],
        [
            "2014-06-13",
            "1106963"
        ]
    ]
}

=cut

sub server_bandwidth {
	my ($self, $subid) = @_;
	my $url = $self->{api} . '/v1/server/bandwidth?api_key=' . $self->{key} . '&SUBID=' . $subid;
	return get($self, $url);
}


=head2 server_create

(Send in parameters as hash reference, use parameter names as keys)

Parameters:
 DCID integer Location to create this virtual machine in.  See v1/regions/list
 VPSPLANID integer Plan to use when creating this virtual machine.  See v1/plans/list
 OSID integer Operating system to use.  See v1/os/list
 ipxe_chain_url string (optional) If you've selected the 'custom' operating system, this can be set to chainload the specified URL on bootup, via iPXE
 ISOID string (optional)  If you've selected the 'custom' operating system, this is the ID of a specific ISO to mount during the deployment
 SCRIPTID integer (optional) If you've not selected a 'custom' operating system, this can be the SCRIPTID of a startup script to execute on boot.  See v1/startupscript/list
 SNAPSHOTID string (optional) If you've selected the 'snapshot' operating system, this should be the SNAPSHOTID (see v1/snapshot/list) to restore for the initial installation
 enable_ipv6 string (optional) 'yes' or 'no'.  If yes, an IPv6 subnet will be assigned to the machine (where available)
 enable_private_network string (optional) 'yes' or 'no'. If yes, private networking support will be added to the new server.
 label string (optional) This is a text label that will be shown in the control panel
 SSHKEYID string (optional) List of SSH keys to apply to this server on install (only valid for Linux/FreeBSD).  See v1/sshkey/list.  Seperate keys with commas
 auto_backups string (optional) 'yes' or 'no'.  If yes, automatic backups will be enabled for this server (these have an extra charge associated with them)

Example Response:
{
    "SUBID": "1312965"
}

=cut

sub server_create {
	my ($self, $param_ref) = @_;
	my $url = $self->{api} . '/v1/server/create?api_key=' . $self->{key};
	return post($self, $url, $param_ref);
}


=head2 server_destroy

Parameters:
 SUBID integer Unique identifier for this subscription.  These can be found using the v1/server/list call.


Example Response:
No response, check HTTP result code

=cut

sub server_destroy {
    my ($self, $param_ref) = @_;
    my $url = $self->{api} . '/v1/server/destroy?api_key=' . $self->{key};
    return post($self, $url, $param_ref);
}


=head2 server_create_ipv4

Parameters:
 SUBID integer Unique identifier for this subscription. These can be found using the v1/server/list call.
 reboot string (optional, default 'yes') 'yes' or 'no'. If yes, the server is rebooted immediately.

Example Response:
No response, check HTTP result code

=cut

sub server_create_ipv4 {
	my ($self, $param_ref) = @_;
	unless (defined $param_ref->{reboot}) {
		$param_ref->{reboot} = "yes";
	}
	my $url = $self->{api} . '/v1/server/create_ipv4?api_key=' . $self->{key};
	return post($self, $url, $param_ref);
}

1;
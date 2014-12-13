use strict; use warnings;
package WebService::Vultr;
use Carp;
use LWP::UserAgent;
use LWP::Protocol::https;

# ABSTRACT: Perl bindings for the Vultr API
# https://www.vultr.com/api/

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


=head2 server_destroy_ipv4

(Server will be hard restarted!)

Parameters:
 SUBID integer Unique identifier for this subscription. These can be found using the v1/server/list call.
 ip string IPv4 address to remove.

Example Response:
No response, check HTTP result code

=cut

sub server_destroy_ipv4 {
    my ($self, $param_ref) = @_;
    my $url = $self->{api} . '/v1/server/destroy_ipv4?api_key=' . $self->{key};
    return post($self, $url, $param_ref);
}


=head2 server_halt

Parameters:
 SUBID integer Unique identifier for this subscription.  These can be found using the v1/server/list call

Example Response:
No response, check HTTP result code

=cut

sub server_halt {
    my ($self, $param_ref) = @_;
    my $url = $self->{api} . '/v1/server/halt?api_key=' . $self->{key};
    return post($self, $url, $param_ref);
}


=head2 server_label_set

Parameters:
 SUBID integer Unique identifier for this subscription. These can be found using the v1/server/list call.
 label string This is a text label that will be shown in the control panel.

Example Response:
No response, check HTTP result code

=cut

sub server_label_set {
    my ($self, $param_ref) = @_;
    my $url = $self->{api} . '/v1/server/label_set?api_key=' . $self->{key};
    return post($self, $url, $param_ref);
}


=head2 server_list

GET - account
 List all active or pending virtual machines on the current account. The 'status' field represents the status of the subscription and will be one of pending|active|suspended|closed. If the status is 'active', you can check 'power_status' to determine if the VPS is powered on or not. The API does not provide any way to determine if the initial installation has completed or not. 

Example Request:
 GET https://api.vultr.com/v1/server/list?api_key=EXAMPLE

Example Response:
{
    "576965": {
        "SUBID": "576965",
        "os": "CentOS 6 x64",
        "ram": "4096 MB",
        "disk": "Virtual 60 GB",
        "main_ip": "123.123.123.123",
        "vcpu_count": "2",
        "location": "New Jersey",
        "DCID": "1",
        "default_password": "nreqnusibni",
        "date_created": "2013-12-19 14:45:41",
        "pending_charges": "46.67",
        "status": "active",
        "cost_per_month": "10.05",
        "current_bandwidth_gb": 131.512,
        "allowed_bandwidth_gb": "1000",
        "netmask_v4": "255.255.255.248",
        "gateway_v4": "123.123.123.1",
        "power_status": "running",
        "VPSPLANID": "28",
        "v6_network": "2001:DB8:1000::",
        "v6_main_ip": "2001:DB8:1000::100",
        "v6_network_size": "64",
        "label": "my new server",
        "internal_ip": "10.99.0.10",
        "kvm_url": "https://my.vultr.com/subs/novnc/api.php?data=eawxFVZw2mXnhGUV",
        "auto_backups": "yes"
    }
}

Parameters:
 SUBID integer (optional) Unique identifier of a subscription. Only the subscription object will be returned.

=cut

sub server_list {
    my ($self, $subid) = @_;
    my $url = $self->{api} . '/v1/server/list?api_key=' . $self->{key};
    if (defined $subid) {
        $url .= "&SUBID=$subid";
    }
    return get($self, $url);
}


=head2 server_list_ipv4

GET - account
List the IPv4 information of a virtual machine. IP information is only available for virtual machines in the "active" state. 

Example Request:
GET https://api.vultr.com/v1/server/list_ipv4?api_key=EXAMPLE&SUBID=576965

Example Response:
{
    "576965": [
        {
            "ip": "123.123.123.123",
            "netmask": "255.255.255.248",
            "gateway": "123.123.123.1",
            "type": "main_ip",
            "reverse": "123.123.123.123.example.com"
        },
        {
            "ip": "123.123.123.124",
            "netmask": "255.255.255.248",
            "gateway": "123.123.123.1",
            "type": "secondary_ip",
            "reverse": "123.123.123.124.example.com"
        },
        {
            "ip": "10.99.0.10",
            "netmask": "255.255.0.0",
            "gateway": "",
            "type": "private",
            "reverse": ""
        }
    ]
}

Parameters:
SUBID integer

=cut

sub server_list_ipv4 {
    my ($self, $subid) = @_;
    my $url = $self->{api} . '/v1/server/list_ipv4?api_key=' . $self->{key} . "&SUBID=$subid";
    return get($self, $url);
}


=head2 server_list_ipv6

GET - account
List the IPv6 information of a virtual machine. IP information is only available for virtual machines in the "active" state. If the virtual machine does not have IPv6 enabled, then an empty array is returned. 

Example Request:
GET https://api.vultr.com/v1/server/list_ipv6?api_key=EXAMPLE&SUBID=576965

Example Response:
{
    "576965": [
        {
            "ip": "2001:DB8:1000::100",
            "network": "2001:DB8:1000::",
            "network_size": "64",
            "type": "main_ip"
        }
    ]
}

Parameters:
SUBID integer

=cut

sub server_list_ipv6 {
    my ($self, $subid) = @_;
    my $url = $self->{api} . '/v1/server/list_ipv6?api_key=' . $self->{key} . "&SUBID=$subid";
    return get($self, $url);
}


=head2 os_change

POST - account
Changes the operating system of a virtual machine. All data will be permanently lost. 

Example Request:
POST https://api.vultr.com/v1/server/os_change?api_key=EXAMPLE

Example Response:
No response, check HTTP result code

Parameters:
SUBID integer Unique identifier for this subscription. These can be found using the v1/server/list call.
OSID integer Operating system to use. See /v1/server/os_change_list.

=cut

sub server_os_change {
    my ($self, $param_ref) = @_;
    my $url = $self->{api} . '/v1/server/os_change?api_key=' . $self->{key};
    return post($self, $url, $param_ref);
}


=head2 server_os_change_list {
GET - account
Retrieves a list of operating systems to which this server can be changed. 

Example Request:
GET https://api.vultr.com/v1/server/os_change_list?api_key=EXAMPLE&SUBID=576965

Example Response:
{
    "127": {
        "OSID": "127",
        "name": "CentOS 6 x64",
        "arch": "x64",
        "family": "centos",
        "windows": false,
        "surcharge": "0.00"
    },
    "148": {
        "OSID": "148",
        "name": "Ubuntu 12.04 i386",
        "arch": "i386",
        "family": "ubuntu",
        "windows": false,
        "surcharge": "0.00"
    }
}

Parameters:
SUBID integer Unique identifier for this subscription. These can be found using the v1/server/list call.

=cut

sub server_os_change_list {
    my ($self, $subid) = @_;
    my $url = $self->{api} . '/v1/server/os_change_list?api_key=' . $self->{key} . "&SUBID=$subid";
    return get($self, $url);
}

1;
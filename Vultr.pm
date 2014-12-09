package Vultr;
use Carp;
use LWP::UserAgent;
use LWP::Protocol::https;

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

sub execute {
	my ($self, $url) = @_;
		my $res = $self->{ua}->get($url);
		#print $res->content;
	if ($res->is_success) {
		return $res->content;
	}
	else {
		confess $res->status_line
	}
}

=head1 B<Vultr API methods>

=head2 account_info

Parameters:
	API key

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
	return execute($self, $url);
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
	return execute($self, $url);
}


=head2 iso_list

Parameters:
	API key

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
	return execute($self, $url);
	
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
	return execute($self, $url);
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
	return execute($self, $url);
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
	return execute($self, $url);
}


=head2 server_bandwidth

Parameters:
 API Key
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
	return execute($self, $url);
}

1;
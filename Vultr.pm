package Vultr;
use LWP::UserAgent;
use LWP::Protocol::https;

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
	if ($res->is_success) {
		return $res->content;
	}
	else {
		die $res->status_line
	}
}


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

1;
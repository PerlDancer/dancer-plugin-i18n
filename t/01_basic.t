use strict;
use warnings;

use Test::More tests => 2;

use HTTP::Request;
use LWP::UserAgent;
use Plack::Loader;
use Dancer::Config 'setting';

use Test::TCP;

my $app = sub {
    my $env     = shift;
    my $request = Dancer::Request->new($env);
    Dancer->dance($request);
};

Test::TCP::test_tcp(
    client => sub {
        my $port = shift;
        my $req = HTTP::Request->new( GET => "http://127.0.0.1:$port/" );
        $req->header( 'Accept-Language' => 'fr' );
        my $ua  = LWP::UserAgent->new;
        my $res = $ua->request($req);
        like $res->content, qr/first we got bonjour/, 'french content';
        like $res->content, qr/then we have hallo/,   'german content';
    },
    server => sub {
        use t::lib::TestApp;
        my $port = shift;
        setting apphandler => 'PSGI';
        setting appname    => 'TestApp';
        setting template   => 'template_toolkit';
        Dancer::Config->load;
        Plack::Loader->auto( port => $port )->run($app);
    }
);


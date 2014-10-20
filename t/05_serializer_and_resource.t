use strict;
use warnings;
use Dancer::ModuleLoader;
use Test::More import => ['!pass'];

# Dancer::Test had a bug in version previous 1.3059_01 that prevent this test
# from running correctly.
my $dancer_version = eval "\$Dancer::VERSION";
$dancer_version =~ s/_//g;
plan skip_all => "Dancer 1.3059_01 is needed for this test (you have $dancer_version)"
  if $dancer_version < 1.305901;

plan skip_all => 'tests require JSON'
    unless Dancer::ModuleLoader->load('JSON');

{
    package Webservice;
    use Dancer;
    use Dancer::Plugin::REST;

    setting environment => 'testing';
    prepare_serializer_for_format;

    resource user =>
        get    => sub { [ id   => params->{id},   format => params->{format} ] },
        delete => sub { [ id   => params->{id},   format => params->{format} ] },
        create => sub { [ user => params->{user}, format => params->{format} ] },
        update => sub { [ user => params->{user}, format => params->{format} ] };
}

use Dancer::Test;
plan tests => 4;

my $r = dancer_response GET => '/user/42.json';

is $r->{content}, '["id","42","format","json"]'
    => "'id' and 'format' params are properly set for resource during GET";

$r = dancer_response POST => '/user.json', { params => { user => 'test' } };

is $r->{content}, '["user","test","format","json"]'
    => "'user' and 'format' params properly set for resource during POST";

$r = dancer_response PUT => '/user/1.json', { params => { user => 'anothertest' } };

is  $r->{content}, '["user","anothertest","format","json"]'
    => "'user' and 'format' params properly set for resource during PUT";

$r = dancer_response DELETE => '/user/6.json';

is $r->{content}, '["id","6","format","json"]'
    => "'id' and 'format' params properly set for resource during DELETE";


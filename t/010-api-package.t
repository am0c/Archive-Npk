#!/usr/bin/env perl
use warnings;
use strict;

use Test::More tests => 2;

use Archive::Npk;
use Archive::Npk::API;

{
    my $pkg = Archive::Npk::API::Package->open('t/res/sample.npk', '180d9:3fc2:1bfb:3e0');
    ok($pkg, "open");

    $pkg->close;
    pass("close");
};



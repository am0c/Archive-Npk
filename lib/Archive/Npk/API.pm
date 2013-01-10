package Archive::Npk::API;

#use 5.008001;

use strict;
use warnings;

use Carp;
use Config;

use Alien::Archive::Npk;

use DynaLoader;
require Exporter;

BEGIN {
    our @ISA = qw(DynaLoader Exporter);

    require DynaLoader;

    for (Alien::Archive::Npk->config('libs_path')) {
        DynaLoader::dl_load_file($_) or croak DynaLoader::dl_error();
    }

    our $VERSION = '0.000001_001';
}

sub dl_load_flags { 0x01 }

bootstrap Archive::Npk::API;



1;
__END__

=head1 NAME

Archive::Npk::API - Neat Package System - npk

=head1 SYNOPSIS

  use Archive::Npk::API;

=head1 DESCRIPTION

blah blah

=cut

package Archive::Npk;

#use 5.008001;

use strict;
use warnings;

use Carp;
use Config;

use Alien::Archive::Npk;

BEGIN {
    # my $LD_LIBRARY_PATH = $Config{ldlibpthname};
    # substr($ENV{$LD_LIBRARY_PATH}, 0, 0, Alien::Archive::Npk->config('lib_dir') . ":");
}

use DynaLoader;
require Exporter;

BEGIN {
    our @ISA = qw(DynaLoader Exporter);

    # my $lib_dir = Alien::Archive::Npk->config('lib_dir');
    # unshift @DynaLoader::dl_library_path, $lib_dir;

    require DynaLoader;

    for (Alien::Archive::Npk->config('libs_path')) {
        DynaLoader::dl_load_file($_) or croak DynaLoader::dl_error();
    }

    our $VERSION = '0.000001_001';
}

sub dl_load_flags { 0x01 }

bootstrap Archive::Npk;



1;
__END__

=head1 NAME

Archive::Npk - Neat Package System - npk

=head1 SYNOPSIS

  use Archive::Npk;

=head1 DESCRIPTION

blah blah

=cut

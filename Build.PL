#!/usr/bin/env perl
use strict;
use warnings;

use Module::Build;

use File::Spec;
use Alien::Archive::Npk;

my $cflags = "-I" . Alien::Archive::Npk->config('include_dir');
my @libs = ("-L" . Alien::Archive::Npk->config('lib_dir'), "-lnpk");

my $build_class = Module::Build->subclass(
    class => 'My::Builder',
    code => << 'CLASS_END',

    use warnings;
    use strict;

    use Alien::Archive::Npk;
    my @libs = ("-L" . Alien::Archive::Npk->config('lib_dir'), "-lnpk");

    sub ACTION_build {
        my $self = shift;

        require DynaLoader;
        unshift @DynaLoader::dl_resolve_using, DynaLoader::dl_findfile(@libs);

        $self->SUPER::ACTION_build;
    }

    sub process_xs {
        my ($self, $file) = @_;

        my $spec = $self->_infer_xs_spec($file);

        # File name, minus the suffix
        (my $file_base = $file) =~ s/\.[^.]+$//;

        # .xs -> .c
        $self->add_to_cleanup($spec->{c_file});

        unless ($self->up_to_date($file, $spec->{c_file})) {
            $self->compile_xs($file, outfile => $spec->{c_file});
        }

        # .c -> .o
        my $v = $self->dist_version;
        $self->compile_c($spec->{c_file},
                         defines => {VERSION => qq{"$v"}, XS_VERSION => qq{"$v"}});

        # archdir
        File::Path::mkpath($spec->{archdir}, 0, oct(777)) unless -d $spec->{archdir};

        # .xs -> .bs
        $self->add_to_cleanup($spec->{bs_file});
        unless ($self->up_to_date($file, $spec->{bs_file})) {
            require ExtUtils::Mkbootstrap;
            $self->log_info("ExtUtils::Mkbootstrap::Mkbootstrap('$spec->{bs_file}')\n");

            (my $bs = $spec->{bs_file}) =~ s/\.bs$//;
            ExtUtils::Mkbootstrap::Mkbootstrap($bs); # Original had $BSLOADLIBS - what's that?
            {
                my $fh = IO::File->new(">> $spec->{bs_file}");
            }                          # create
            utime((time)x2, $spec->{bs_file}); # touch
        }

        # .o -> .(a|bundle)
        $self->link_c($spec);
    }

CLASS_END
);

my $build = $build_class->new(
    module_name => 'Archive::Npk',
    dist_author => 'Hojung Youn <amorette@cpan.org>',
    license     => 'perl',
    requires => {
        'perl' => '5.8.1',
        'Alien::Archive::Npk' => 0,
        'DynaLoader' => 0,
    },
    configure_requires => {
        'File::Spec' => 0,
        'Alien::Archive::Npk' => 0,
        'DynaLoader' => 0,
    },
    xs_files => {
        'Npk.xs' => 'lib/Archive/Npk/API.xs',
    },
    needs_compiler => 1,
    dynamic_config => 1,
    extra_compiler_flags => $cflags,
    extra_linker_flags => join " ", @libs,
);

$build->create_build_script;

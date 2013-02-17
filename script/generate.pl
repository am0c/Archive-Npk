#!/usr/bin/env perl

use 5.014;

use strict;
use warnings;

use Carp;
use File::Spec;
use List::Util qw(first);

use Data::Dump qw(dd);
use File::Slurp;
use Getopt::Long::Descriptive;


my ($option, $usage) = describe_options(
    'generate.pl %o',
    [ 'action' => hidden => { one_of => [
      [ 'dump-parse|dp', "dump parse tree of functions" ],
      [ 'dump-list|dl',  "dump scanned function prototypes" ],
      [ 'generate',      "generate xs files" ],
    ]}],
    [],
    [ 'verbose|v', "print more stuffs" ],
    [ 'help',      "print this usage and exit" ],
    {
      'getopt_conf' => [qw{
         auto_version
         auto_help
      }]
    },
);

if ($option->help || !$option->action) {
    print $usage;
    exit 0;
} elsif (my $action = $option->action) {
    $action =~ y/-/_/;
    eval "action_$action()";
    croak $@ if $@;
}


sub action_dump_parse {
    my $func = process_fdecls();
    for (@$func) {
        say $_;
        dd fdecl_parse( fdecl_tokenize( $_ ) );
    }
}

sub action_dump_list {
    say for @{ process_fdecls() };
}

sub action_generate {
    my @func = @{ process_fdecls() };
    my @parse;

    for (@func) {
        my $parse = fdecl_parse( fdecl_tokenize( $_ ) );
        my @parm = @{$parse->{parameter}[1]};
        my @args;

        for my $arg (@parm) {
            my $arg_str = join " ", map { $_->{value} } @$arg;
            push @args, $arg_str;
        }

        s/(\w+)\[\d+\]$/*$1/ for @args;
        $parse->{parameter_list_as_string} = join ", ", @args;
        $parse->{argument_list_as_string} = join ", ", map { $_->[1]{value} } @parm;

        push @parse, $parse;
    }

    process_xs(\@parse);
}


sub process_scanner {
    require Alien::Archive::Npk;
    require C::Scan;
    my $incl = Alien::Archive::Npk->config('include_dir');
    my $scan = C::Scan->new(
        filename    => File::Spec->catfile($incl, "npk_dev.h"),
        includeDirs => [ $incl ],
    );
}

sub process_fdecls {
    my $scanner = process_scanner();
    my $fdecls = $scanner->get('fdecls');
    $fdecls;
}

sub process_xs {
    my ($parse) = @_;
    my $tmpl_map = eval read_file(File::Spec->catfile('template', 'mapping.pl'));

    require Text::Xslate;
    my $xslate = Text::Xslate->new;

    for my $map (@$tmpl_map) {
        my ($rule, $candidate) = @$map;
        my @ruled_parse = @$parse;
        @ruled_parse = grep {
            if ($_->{function_name}[1]{value} =~ /$rule/) {
                $_->{function_mapped_name} = $1;
            }
        } @ruled_parse;

        open my $fh, ">", File::Spec->catfile('xs', $candidate) or die;
        print STDERR "Generating xs/$candidate from template/$candidate\n";
        print $fh $xslate->render(
            File::Spec->catfile('template', $candidate),
            { scaned => \@ruled_parse },
        );
    }
}


sub fdecl_parse {
    my @token = @{+shift};
    my @ret;

    my $cur_parse = "somewhere it should havn't be";

    local *error = sub {
        print "Current parse stream = ";
        dd @ret;
        print "Current token stream = ";
        dd @token;
        die @_;
    };
    local *look = sub {
        my ($idx, $value) = @_;

        if (@_ == 1) {
            ($idx, $value) = ('value', $idx);
        }

        my $value_orig = $token[0]{$idx eq 'value' ? 'value' : 'token_type'};

        if (ref $value eq 'Regexp') {
            return $token[0] if $value_orig =~ /$value/;
        }
        else {
            return $token[0] if $value_orig eq $value;
        }
    };
    local *match = sub {
        error("end of string at trying $cur_parse") unless @token;

        return shift @token if @_ == 0;

        my $look = look(@_);
        return shift @token if $look;

        error("$_[0] of '$_[1]' expected while parsing $cur_parse but get '$token[0]{value}' near ",
          map { $_->{value} } @token);
    };
    local *commit = sub {
        push @ret, { parse_state => $cur_parse, node => shift };
    };

    my @parse_rule = (
        return_type => [ 'ident', 'ident_ptr' ],
        function_name => [ 'ident' ],
        open_paren => '(',
        parameter => sub {
            my @args;
            my @arg;

          PARM:
            while (!look(value => ')')) {
                @arg = ();
                while (look(type => qr/^ident/)) {
                    push @arg, match();
                }
                if (!@arg) {
                    push @arg, match(value => '...');
                }
            }
            continue {
                push @args, [ @arg ];
                if (look(value => ',')) {
                    match();
                }
                elsif (!look(value => ')')) {
                    print "current paramenter = ";
                    dd @args;
                    error("End of argument list expected but got '$token[0]{value}'");
                }
            }
            \@args;
        },
        close_paren => ')',
        end_statement => ';',
    );

    while (@parse_rule) {
        $cur_parse = shift @parse_rule;
        my $rule   = shift @parse_rule;

        if (ref $rule eq 'ARRAY') {
            my $found;

          TYPE:
            for (@$rule) {
                $found = match() if look(type => $_);
                last TYPE if $found;
            }
            error("type of ", join(" or ", @$rule), " expected but got $token[0]{token_type}") unless $found;

            commit( $found );
        }
        elsif (ref $rule eq 'CODE') {
            commit( $rule->() );
        }
        else {
            commit( match($rule) );
        }
    }

    my %ret;
    for my $node (@ret) {
        my $name = $node->{parse_state};
        $ret{$name} = $node->{node};
        $ret{as_array} = \@ret;
    }

    \%ret;
}

sub fdecl_tokenize {
    my $text = shift;

    my $alnum = qr/[a-zA-Z0-9_]/;
    my $num = qr/[0-9]/;
    my $al = qr/[a-zA-Z_]/;

    my @token;
    s{ \G

       (?: ${al} ${alnum}* (?:  \s*\*       (?<ident_ptr>) # ident with pointer
                             |  \[${num}*\] (?<ident_idx>) # ident with array size
                             |              (?<ident>) )   # ident
         | [();,]                           (?<punc>)      # punctuations
         | \.\.\.                           (?<varlist>)   # variable argument list
         | \s+                                             # whitespace
         | (?<error> .+)                                   # etc. it's error
         )
    }{
        my ($idx) = keys %+;
        die "Parse error near $+{error}" if exists $+{error};
        push @token, +{ token_type => $idx, value => $& } if $idx;

        \('-'); # hi
    }xsge;

    return \@token;
}

#!/usr/bin/env perl

use 5.014;

use strict;
use warnings;

use Carp;
use File::Spec;
use List::Util qw(first);

use Data::Dump qw(dd);
use Getopt::Long::Descriptive;


my ($option, $usage) = describe_options(
    'generate.pl %o',
    [ 'action' => hidden => { one_of => [
      [ 'dump',    "dump the parsed function declarations" ],
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
    eval "action_$action()";
}


sub action_dump {
    my $scanner = process_scanner();
    my $fdecls = $scanner->get('fdecls');
    for (@$fdecls) {
        say $_;
        dd fdecl_parse( fdecl_tokenize( $_ ) );
    }
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

        my $value_orig = $token[0][$idx eq 'value' ? 1 : 0];

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

        error("$_[0] of '$_[1]' expected while parsing $cur_parse but get '$token[0][1]' near ",
          map { $_->[1] } @token);
    };
    local *commit = sub {
        push @ret, [ $cur_parse => shift ];
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
                    error("End of argument list expected but got '$token[0][1]'");
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
            error("type of ", join(" or ", @$rule), " expected but got $token[0][0]") unless $found;

            commit( $found );
        }
        elsif (ref $rule eq 'CODE') {
            commit( $rule->() );
        }
        else {
            commit( match($rule) );
        }
    }

    \@ret;
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
        push @token, [ $idx => $& ] if $idx;

        \('-'); # hi
    }xsge;

    return \@token;
}

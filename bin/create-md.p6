#!/usr/bin/env perl6

my $p = $*PROGRAM;
if !@*ARGS {
   print qq:to/END/;
   Usage: $p <module file> [output dir] [debug]

   Reads the modulefile and extracts properly formatted comments
   into markdown files describing the subs and other objects
   contained therein.  Output files are created in the
   [output dir] if entered, or the current directory
   otherwise.

   For an example, the markdown files in the docs directory
   in this repository were created with this program.

   END

   exit;
}

my $modfil = shift @*ARGS;
my $tgtdir = shift @*ARGS;
my $debug  = shift @*ARGS;
$debug = 0 if !$debug;

my @kw = <
Subroutine
Purpose
Params
Returns
file:
title:
>;
say @kw.perl if $debug;
my %kw = map { $_ => 1 }, @kw;
say %kw.perl if $debug;
# need a simple entry class
class entry {
}

create-md($modfil, $tgtdir);

#### subroutines ####
sub create-md($f, $d) {
    my %mdfils;
    for $f.IO.lines -> $line {
        say $line if $debug;
        my @words = $line.words;
        next if !@words;
        my $nw = @words;

        if $line ~~ /^ \s* '#' / {
            next if $nw < 2; 
            my $kw = @words[1];
            say "possible keyword '$kw'" if $debug;
            next if not %kw{$kw}:exists;
            say "found keyword '$kw'"; # if $debug;
        }
        elsif $line ~~ /^ sub \s* / {
            # start sub signature
            say "found sub sig '$line'";
        }

    }
}

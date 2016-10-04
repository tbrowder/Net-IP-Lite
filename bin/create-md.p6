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

my %kw = [
    'Subroutine' => '###',
    'Purpose'    => '-',
    'Params'     => '-',
    'Returns'    => '-',
    'file:'      => '',
    'title:'     => '#',
];

say %kw.perl if $debug;

# need a simple entry class
class entry {
}

create-md($modfil, $tgtdir);

#### subroutines ####
sub create-md($f, $d) {
    my %mdfils;
    my $fp = open $f;
    for $fp.lines <-> $line {
        say $line if $debug;
        my @words = $line.words;
        next if !@words;
        my $nw = @words;

        if $line ~~ /^ \s* '#' / {
            next if $nw < 2;
            my $kw = @words[1];
            say "possible keyword '$kw'" if $debug;
            next if !%kw{$kw};
            say "found keyword '$kw'"; # if $debug;
        }
        elsif $line ~~ /^ sub \s* / {
            # start sub signature
            say "found sub sig '$line'";
            my $sig = $line;
            if $line !~~ / '{' / {
                # not the end of signature
                my $nextline = $fp.get;
                say "next line: $nextline";
                # just in case sig spans multiple lines:
                while $nextline !~~ / '{' / {
                    $sig ~= ' ' ~ $nextline;
                }
                say "complete sub sig '$line'";
            }
            # tidy the line into two lines
            my @lines;
            my $idx = index $sig, ')';
                if $idx.defined {
                    my $line-0 = substr $sig, 0, $idx + 1;
                    $sig = substr $sig, $idx + 1;
                    $idx = substr $sig, '{';
                    if !$idx.defined {
                        die "FATAL: unable to find an opening '{' in sub sig '$sig'";
                    }
       
                }
                else {
                    die "FATAL: unable to find a closing ')' in sub sig '$sig'";
                }
            }
            say "DEBUG:";
        }

    }
}

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
$tgtdir = '' if !$tgtdir;
$debug  = 0 if !$debug;

my $max-line-length = 78;

my %kw = [
    'Subroutine' => '###',
    'Purpose'    => '-',
    'Params'     => '-',
    'Returns'    => '-',

    'title:'     => '#',

    'file:'      => '',
];

say %kw.perl if $debug;

my %mdfils; 
create-md($modfil);
say %mdfils.perl if $debug;


my @ofils;
for %mdfils.keys -> $f is copy {
    # distinguish bewteen file base name and path
    my $of = $f;  
    $of = $tgtdir ~ '/' ~ $of if $tgtdir;  
    push @ofils, $of;
    my $fh = open $of, :w;


    $fh.say: %mdfils{$f}<title>;

    my %hs = %(%mdfils{$f}<subs>);
    my @subs = %hs.keys.sort;
    for @subs -> $s {
        say "sub: $s" if $debug;
        my @lines = @(%hs{$s});
        for @lines -> $line {
            $fh.say: $line;
        }
    }
    $fh.close;
    say "see output file '$f'";
}

#### subroutines ####
sub create-md($f) {
    # %h{$fname}<title> = $title 
    #           <subs>{$subname} = @lines

    my $fname;   # current output file name
    my $title;   # current title for the file contents
    my $subname; # current sub name
    
    # open the desired module file
    my $fp = open $f;
    for $fp.lines -> $line is copy {
        say $line if $debug;
        next if $line !~~ / \S /; # skip empty lines 
        # ensure there is a space following any leading '#'
        $line ~~ s/^ \s* '#' \S /^\# /;
        my @words = $line.words;
        my $nw = @words;

        if $line ~~ /^ \s* '#' / {
            next if $nw < 3;
 	    my $kw  = @words[1];
 	    my $val = @words[2];
            say "possible keyword '$kw'" if $debug;
            #say "possible keyword '$kw'";
            next if not %kw{$kw}:exists;
            say "found keyword '$kw'" if $debug;
            # get the actual line to be output
            my $txt = get-kw-line-data(:val(%kw{$kw}), :$kw, :words(@words[1..*]));
            say "text value: '$txt'" if $debug;
            # next action depends on keyword
            if $kw eq 'file:' {
                # start a new file
                $fname = $val;
            }
            elsif $kw eq 'title:' {
                # update the title name
                $title = $txt;
                %mdfils{$fname}<title> = $title;
            }
            elsif $kw eq 'Subroutine' {
                # update the subroutine name
                $subname = $val; 
                # start a new array
                %mdfils{$fname}<subs>{$subname} = [];
                %mdfils{$fname}<subs>{$subname}.push($txt);
            }
            else {
                # all other lines go onto the array
                %mdfils{$fname}<subs>{$subname}.push($txt);
            }
        }
        elsif $line ~~ /^ sub \s* / {
            # start sub signature
            say "found sub sig '$line'" if $debug;
            my $sig = $line.trim;
            if $line !~~ / '{' / {
                # not the end of signature
                my $nextline = $fp.get.trim;
                say "next line: $nextline" if $debug;
                # just in case sig spans multiple lines:
                while $nextline !~~ / '{' / {
                    $sig ~= ' ' ~ $nextline;
                }
                # don't forget the last chunk with the opening curly brace
                $sig ~= ' ' ~ $nextline;
                say "complete sub sig '$sig'" if $debug;

            }

            # tidy the line into two lines
            my @lines;
            my $idx = index $sig, ')';
            if $idx.defined {
                my $line1 = substr $sig, 0, $idx + 1;
                my $line2 = substr $sig, $idx + 1; 
                $idx = index $line2, '{';
                if !$idx.defined {
                    die "FATAL: unable to find an opening '\{' in sub sig '$sig'";
                }
                $line2 = substr $line2, 0, $idx + 1;
                # add closure after the opening curly to indcate the sub block
                $line2 ~= '#...}';
                $line2 .= trim;
                $line2 = '  ' ~ $line2; 
                # is either line too long?
                my $nc1 = $line1.chars; 
                my $nc2 = $line2.chars; 
                if $debug {
                    my $m = $max-line-length; 
                    say "line1 > $m chars (=$nc1)" if $nc1 > $m;
                    say "line2 > $m chars (=$nc2)" if $nc2 > $m;
                }
                if 0 && max($nc1, $nc2) > $max-line-length {
                    @lines = shorten-sub-sig-lines(@lines);
                }
                else {
                    push @lines, $line1;
                    push @lines, $line2;
                }
            }
            else {
                die "FATAL: unable to find a closing ')' in sub sig '$sig'";
            }
            # push the lines on the current elementg
            say "DEBUG: sub sig lines" if $debug;
            %mdfils{$fname}<subs>{$subname}.push("'''perl6");
            for @lines -> $line {
                %mdfils{$fname}<subs>{$subname}.push($line);
                say "  line: '$line'" if $debug;
            }
            %mdfils{$fname}<subs>{$subname}.push("'''");
        }
    }
}

sub shorten-sub-sig-lines(@lines is rw) {
    # collect stats
    my $nl = +@lines;
    my %nc;
    my $max   = 0;
    my $maxid = 0;
    my $i = 0;
    for @lines -> $line {
        my $m = $ine.chars;
        %nc{$i} = $m;
        if $m > $max {;
            $max = $m;
            $maxid = $i;
        }
    }

    return if $max <= $max-sig-line-length;

    # assume the user deliberately edited the signature if > two lines
    return if +@lines > 2;

    # treat the longest line which normally should be the first one


#    my $sig = join ' ', @lines;
    
}

sub normalize-string($str) {
    $str ~~ s:g/\s ** 2..*/ /;
}


#### subroutines ####
sub get-kw-line-data(:$val, :$kw, :@words is copy) returns Str {
    say "TOM FIX THIS TO HANDLE EACH KEYWORD PROPERLY" if $debug;
    say "DEBUG: reduced \@words array" if $debug;
    say @words.perl if $debug;

    my $txt = '';
    given $kw {
        when 'Subroutine' {
            # pass back just the sub name with leading markup
            $txt ~= $val if $val;
            $txt ~= ' ' ~ @words[1];
            # add a leading newline to provide spacing between 
            # the preceding subroutine
            $txt = "\n" ~ $txt;
        }
        when 'Purpose'    {
            # pass back all with leading markup
            $txt ~= $val if $val;
            $txt ~= ' ' ~ join ' ', @words;
        }
        when 'Params'     {
            # pass back all with leading markup
            $txt ~= $val if $val;
            $txt ~= ' ' ~ join ' ', @words;
            # need an extra space to prettify the total appearance
            $txt ~~ s/Params/Params /;
        }
        when 'Returns'    {
            # pass back all with leading markup
            $txt ~= $val if $val;
            $txt ~= ' ' ~ join ' ', @words;
        }
        when 'file:'      {
        }
        when 'title:'     {
            # pass back all with leading markup
            $txt ~= $val if $val;
            $txt ~= ' ' ~ join ' ', @words;
        }
    }

    return $txt;
}


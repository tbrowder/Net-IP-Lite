unit module Net::IP::Lite:ver<1.0.0>;

my $debug = 0;

#------------------------------------------------------------------------------
# Subroutine ip-bintoip
# Purpose           : Transform a bit string into an IP address
# Params            : bit string, IP version
# Returns           : IP address on success, undef otherwise
sub ip-bintoip($binip is copy where /^<[01]>+$/,
               $ip-version where /^<[46]>?$/) is export {

    # Define normal size for address
    my $len = ip-iplengths($ip-version);

    if $len < $binip.chars {
        warn "Invalid IP length ({$binip.chars}, should be $len) for binary IP $binip\n" if $debug;
        return;
    }

    # Prepend 0s if address is less than normal size
    $binip = '0' x ($len - $binip.chars) ~ $binip;

    # IPv4
    if $ip-version == 4 {
        #return join '.', unpack('C4C4C4C4', pack('B32', $binip));
	# split into individual bits
	my @c = $binip.comb;

	# convert each 8-bit octet to decimal and combine into the ip
	my $ip = '';
	for 0, 8, 16, 24 -> $i {
	    $ip ~= '.' if $i;
	    # get the next 8 bits
	    my $byte = join '', @c[$i..$i+7];
	    # convert next 8 bits to decimal
	    my $decimal = bin2dec($byte);
  	    $ip ~= $decimal;
	}
	return $ip;
    }

    # IPv6
    #return join(':', unpack('H4H4H4H4H4H4H4H4', pack('B128', $binip)));

    # split into individual bits
    my @c = $binip.comb;

    # convert each 16-bit field to 4 hex chars and combine into the ip
    my $ip = '';
    for 0, 16, 32, 48, 64, 80, 96, 112 -> $i {
	$ip ~= ':' if $i;
	# get the next 16 bits
	my $half-word = join '', @c[$i..$i+15];
	# convert next 16 bits to hex
	my $hex = bin2hex($half-word, 4);
	$ip ~= $hex;
    }
    return $ip;
} # ip-bintoip


#------------------------------------------------------------------------------
# Subroutine ip_compress_address
# Purpose           : Compress an IPv6 address
# Params            : IP, IP version
# Returns           : Compressed IP or undef (problem)
sub ip-compress-address($ip is copy, $ip-version where /^<[46]>?$/) is export {

    # Just return if IP is IPv4
    return $ip if $ip-version == 4;

    # already compressed addresses must be expanded first
    $ip = ip-expand-address($ip, $ip-version);

    my @quads = split ':', $ip;

    # Remove leading 0s: 0034 -> 34; 0000 -> 0
    for @quads <-> $q {
	my @q = $q.comb;
	while +@q {
	    last if @q[0] != 0;
	    shift @q;
	}
	if !+@q {
	    $q = 0;
	}
	else {
	    $q = join '', @q;
	}

	$q = 0 if !+@q;
    }

    say "DEBUG";
    say @quads.perl;

    my $reg = '';

    # Find the longest :0:0: sequence
    #my $longest-seq = 0;
    #my $longest-seq-index;
    while 0 {

    }

    # Replace sequence by '::'

    return $ip;

} # ip-compress-address

#------------------------------------------------------------------------------
# Subroutine ip-iptobin
# Purpose           : Transform an IP address into a bit string
# Params            : IP address, IP version
# Returns           : bit string on success, undef otherwise
sub ip-iptobin($ip is copy, $ipversion) is export {

    # v4 -> return 32-bit array
    if $ipversion == 4 {
        #return unpack('B32', pack('C4C4C4C4', split(/\./, $ip)));
	my @octets = split '.', $ip;
	my $binip = '';
	for @octets -> $decimal {
	    my $s = sprintf "%08b", $decimal;
	    $binip ~= $s;
	}
	my $nbits = $binip.chars;
	if $nbits == 32 {
	    return $binip;
	}
	else {
	    warn "binip has $nbits bits, should be 32\n" if $debug;
	    return;
	}
    }

    # expand to full size
    $ip = ip-expand-address($ip, 6);
    # Strip ':'
    $ip ~~ s:g/':'//;

    # Check hex size
    unless $ip.chars == 32 {
        warn "Bad IP address $ip\n" if $debug;
        return;
    }


    # v6 -> return 128-bit array
    #return unpack('B128', pack('H32', $ip));
    # split into individual hex chars
    $ip.lc;
    my @c = $ip.comb;

    # convert each 4-bit hex digit to 4-bit binary, and combine into the ip
    my $binip = '';
    for @c -> $c {
	$binip ~= hexchar2bin($c);
    }
    # Check binary size
    my $nbits = $binip.chars;
    if $nbits == 128 {
	return $binip;
    }
    else {
	warn "binip has $nbits bits, should be 128\n" if $debug;
	return;
    }

} # ip-iptobin

#------------------------------------------------------------------------------
# Subroutine ip-iplengths
# Purpose           : Get the length in bits of an IP from its version
# Params            : IP version
# Returns           : Number of bits: 32, 128, 0 (don't know)
sub ip-iplengths($version) is export {
    if $version == 4 {
        return 32;
    }
    elsif $version == 6 {
        return 128;
    }
    else {
        return 0; # unknown
    }
} # ip-iplengths

#------------------------------------------------------------------------------
# Subroutine ip_get_version
# Purpose           : Get an IP version
# Params            : IP address
# Returns           : 4, 6, 0 (don't know)
sub ip-get-version($ip) is export {
    # If the address does not contain any ':', maybe it's IPv4
    return '4' if $ip !~~ /\:/ and ip-is-ipv4($ip);

    # Is it IPv6 ?
    return '6' if ip-is-ipv6($ip);

    return '0'; # unknown
} # ip-get-version

#------------------------------------------------------------------------------
# Subroutine ip_expand_address
# Purpose           : Expand an address from compact notation
# Params            : IP address, IP version
# Returns           : expanded IP address or undef on failure
sub ip-expand-address($ip is copy, $ip-version where /^<[46]>?$/) is export {

    # IPv4 : add .0 for missing quads
    if $ip-version == 4 {
        my @quads = split / '.' /, $ip;

        # check number of quads
        if +@quads > 4 {
            warn "Not a valid IPv4 address $ip\n" if $debug;
            return;
        }
        my @clean_quads;
        for @quads.reverse -> $q {

            #check quad data
            if $q !~~ /^ \d ** 1..3 $/ {
                warn "Not a valid IPv4 address $ip\n" if $debug;
                return;
            }

            # build clean ipv4

            #unshift (@clean_quads, $q + 1 - 1);
	    unshift @clean_quads, $q;

        }

	my $nq = +@clean_quads;
	while $nq < 4 {
	    push @clean_quads, '0';
	    ++$nq;
	}
        #return (join '.', @clean_quads[ 0 .. 3 ]);
        return (join '.', @clean_quads);
    }

    # IPv6

    # Keep track of ::
    my $num-double-colons = count-substrs($ip, '::');
    if $num-double-colons > 1 {
        warn "Too many :: in ip\n" if $debug;
        return;
    }
    # mark the double colons
    $ip ~~ s/ '::' /:!:/;

    # IP as an array
    my @ip = split ':', $ip;

    # Number of actual octets
    my $num = +@ip;

    my $finalip = '';
    for @ip <-> $q {

        # Embedded IPv4
        if $q ~~ / '.' / {

            # Expand Ipv4 address
            # Convert into binary
            # Convert into hex
            # Keep the last two octets

	    die "fix this";

            $q = substr( ip-bintoip( ip-iptobin( ip-expand-address($q, 4), 4), 6), -9);

            # Has an error occured here ?
            return unless $q;

            # ++$num because we now have one more octet:
            # IPv4 address becomes two octets
            ++$num;
            next;
        }

        # Find the pattern
	if $q !~~ / '!' / {
	    $finalip ~= ':' if $finalip;
            # Add missing leading 0s
	    my $s = '0' x (4 - $q.chars);
	    $finalip ~= $s ~ $q;
	    next;
	}

	# how many zero fields do we need to fill?
	my $nfields = 9 - $num;
	for 1..$nfields {
	    $finalip ~= ':' if $finalip;
	    $finalip ~= '0000';
	}
    }

    return $finalip;

} # ip-expand-address

#------------------------------------------------------------------------------
# Subroutine ip-is-ipv4
# Purpose           : Check if an IP address is version 4
# Params            : IP address
# Returns           : True (yes) or False (no)
sub ip-is-ipv4($ip is copy where /^<[\d\.]>+$/) is export {

    if $ip ~~ /^ '.' / {
        warn "Invalid IP $ip - starts with a dot\n" if $debug;
        return False;
    }

    if $ip ~~ / '.' $/ {
        warn "Invalid IP $ip - ends with a dot\n" if $debug;
        return False;
    }

    # Single Numbers are considered to be IPv4
    if ($ip ~~ /^ (\d+) $/ and $0 < 256) { return True }

    # Count quads
    # IPv4 must have from 1 to 4 quads
    my $n = count-substrs($ip, '.');
    unless $n >= 0 and $n < 4 {
        warn "Invalid IP address $ip ($n dots found)\n" if $debug > 1;
        return False;
    }
    warn "DEBUG: found $n dots\n" if $debug;

    # Check for empty quads
    if $ip ~~ / '..' / {
        warn "Empty quad in IP address $ip\n" if $debug;
        return False;
    }

    for split /'.'/, $ip {
        # Check for invalid quads
        unless $_ >= 0 and $_ < 256 {
            warn "Invalid quad in IP address $ip - $_\n" if $debug;
            return False;
        }
    }

    return True;
} # ip-is-ipv4

#------------------------------------------------------------------------------
# Subroutine ip-is-ipv6
# Purpose           : Check if an IP address is version 6
# Params            : IP address
# Returns           : True (yes) or False (no)
sub ip-is-ipv6($ip is copy) is export {
    # Count octets
    # IPv4 must have from 1 to 8 octets (at least one colon)
    #my $n = ($ip ~~ tr/:/:/);
    my $n = count-substrs($ip, ':');
    return False unless $n > 0 and $n < 8;

    # $k is a counter
    my $k;

    for split /':'/, $ip {
        ++$k;

        # Empty octet ?
        next if $_ eq '';

        # Normal v6 octet ?
        next if m:i/^ <[a..f\d]> ** 1..4 $/;

        # Last octet - is it IPv4 ?
        if ($k == $n + 1) && ip-is-ipv4($_) {
            ++$n; # ipv4 is two octets
            next;
        }

        warn "Invalid IP address $ip\n" if $debug;
        return False;
    }

    # Does the IP address start with a single : ?
    if $ip ~~ /^ ':' <-[\:]> / {
        warn "Invalid address $ip (starts with :)\n" if $debug;
        return False;
    }

    # Does the IP address finish with a single : ?
    if $ip ~~ / <-[\:]> ':' $/ {
        warn "Invalid address $ip (ends with :)\n" if $debug;
        return False;
    }

    # Does the IP address have more than one '::' pattern ?
    my $ncolonpairs = count-substrs($ip, '::');
    if $ncolonpairs > 1 {
        warn "Invalid address $ip (More than one :: pattern)\n" if $debug;
        return False;
    }

    # number of octets
    if $n != 7 && $ip !~~ /'::'/ {
        warn "Invalid number of octets $ip\n" if $debug;
        return False;
    }

    # valid IPv6 address
    return True;
} # ip-is-ipv6

sub count-substrs($ip, $substr) {
    my $nsubstrs = 0;
    my $idx = index $ip, $substr;
    while $idx.defined {
	++$nsubstrs;
	$idx = index $ip, $substr, $idx+1;
    }
    return $nsubstrs;
}

sub hexchar2bin($hexchar) is export {
    my $decimal = hexchar2dec($hexchar);
    return sprintf "%04b", $decimal;
}

sub hexchar2dec($hexchar is copy) is export {
    fail "FATAL: \$hexchar = '$hexchar' has > 1 char" if $hexchar.chars != 1;
    my $num;
    $hexchar .= lc;

    if $hexchar ~~ /^ \d+ $/ {
	# 0..9
	$num = $hexchar;
    }
    elsif $hexchar eq 'a' {
	$num = 10;
    }
    elsif $hexchar eq 'b' {
	$num = 11;
    }
    elsif $hexchar eq 'c' {
	$num = 12;
    }
    elsif $hexchar eq 'd' {
	$num = 13;
    }
    elsif $hexchar eq 'e' {
	$num = 14;
    }
    elsif $hexchar eq 'f' {
	$num = 15;
    }
    else {
	fail "FATAL: \$hexchar '$hexchar' is unknown";
    }
    return $num;
}

sub hex2dec($hex) is export {
    my @chars = $hex.comb;
    @chars .= reverse;
    my $decimal = 0;
    my $power = 0;
    for @chars -> $c {
        $decimal += hexchar2dec($c) * 16 ** $power;
	++$power;
    }
    return $decimal;
}

sub hex2bin($hex, $len?) is export {
    my @chars = $hex.comb;
    my $bin = '';
    for @chars -> $c {
        $bin ~= hexchar2bin($c);
    }
    if $len && $len > $bin.chars {
	my $s = '0' x ($len - $bin.chars);
	$bin ~= $s ~ $bin;
    }
    return $bin;
}

sub dec2bin($dec, $len?) {
}

sub bin2dec($bin) is export {
    my @bits = $bin.comb;
    @bits .= reverse;
    my $decimal = 0;
    my $power = 0;
    for @bits -> $bit {
        $decimal += $bit * 2 ** $power;
	++$power;
    }
    return $decimal;
}

sub bin2hex($bin, $len?) is export {
    my $decimal = bin2dec($bin);
    if $len {
	return sprintf "%0*x", $len, $decimal;
    }
    else {
	return sprintf "%x", $decimal;
    }
}

=begin pod
#------------------------------------------------------------------------------
# Subroutine ip_get_version
# Purpose           : Get an IP version
# Params            : IP address
# Returns           : 4, 6, 0(don't know)
sub ip_get_version {
    my $ip = shift;

    # If the address does not contain any ':', maybe it's IPv4
    $ip !~ /:/ and ip_is_ipv4($ip) and return '4';

    # Is it IPv6 ?
    ip_is_ipv6($ip) and return '6';

    return;
}

#------------------------------------------------------------------------------
# Subroutine ip_is_ipv4
# Purpose           : Check if an IP address is version 4
# Params            : IP address
# Returns           : 1 (yes) or 0 (no)
sub ip_is_ipv4 {
    my $ip = shift;

    # Check for invalid chars
    unless ($ip =~ m/^[\d\.]+$/) {
        $ERROR = "Invalid chars in IP $ip";
        $ERRNO = 107;
        return 0;
    }

    if ($ip =~ m/^\./) {
        $ERROR = "Invalid IP $ip - starts with a dot";
        $ERRNO = 103;
        return 0;
    }

    if ($ip =~ m/\.$/) {
        $ERROR = "Invalid IP $ip - ends with a dot";
        $ERRNO = 104;
        return 0;
    }

    # Single Numbers are considered to be IPv4
    if ($ip =~ m/^(\d+)$/ and $1 < 256) { return 1 }

    # Count quads
    my $n = ($ip =~ tr/\./\./);

    # IPv4 must have from 1 to 4 quads
    unless ($n >= 0 and $n < 4) {
        $ERROR = "Invalid IP address $ip";
        $ERRNO = 105;
        return 0;
    }

    # Check for empty quads
    if ($ip =~ m/\.\./) {
        $ERROR = "Empty quad in IP address $ip";
        $ERRNO = 106;
        return 0;
    }

    foreach (split /\./, $ip) {

        # Check for invalid quads
        unless ($_ >= 0 and $_ < 256) {
            $ERROR = "Invalid quad in IP address $ip - $_";
            $ERRNO = 107;
            return 0;
        }
    }
    return 1;
}

#------------------------------------------------------------------------------
# Subroutine ip_is_ipv6
# Purpose           : Check if an IP address is version 6
# Params            : IP address
# Returns           : 1 (yes) or 0 (no)
sub ip_is_ipv6 {
    my $ip = shift;

    # Count octets
    my $n = ($ip =~ tr/:/:/);
    return 0 unless ($n > 0 and $n < 8);

    # $k is a counter
    my $k;

    foreach (split /:/, $ip) {
        $k++;

        # Empty octet ?
        next if ($_ eq '');

        # Normal v6 octet ?
        next if (/^[a-f\d]{1,4}$/i);

        # Last octet - is it IPv4 ?
        if ( ($k == $n + 1) && ip_is_ipv4($_) ) {
            $n++; # ipv4 is two octets
            next;
        }

        $ERROR = "Invalid IP address $ip";
        $ERRNO = 108;
        return 0;
    }

    # Does the IP address start with : ?
    if ($ip =~ m/^:[^:]/) {
        $ERROR = "Invalid address $ip (starts with :)";
        $ERRNO = 109;
        return 0;
    }

    # Does the IP address finish with : ?
    if ($ip =~ m/[^:]:$/) {
        $ERROR = "Invalid address $ip (ends with :)";
        $ERRNO = 110;
        return 0;
    }

    # Does the IP address have more than one '::' pattern ?
    if ($ip =~ s/:(?=:)/:/g > 1) {
        $ERROR = "Invalid address $ip (More than one :: pattern)";
        $ERRNO = 111;
        return 0;
    }

    # number of octets
    if ($n != 7 && $ip !~ /::/) {
        $ERROR = "Invalid number of octets $ip";
        $ERRNO = 112;
        return 0;
    }

    # valid IPv6 address
    return 1;
}

#------------------------------------------------------------------------------
# Subroutine ip_expand_address
# Purpose           : Expand an address from compact notation
# Params            : IP address, IP version
# Returns           : expanded IP address or undef on failure
sub ip_expand_address {
    my ($ip, $ip_version) = @_;

    unless ($ip_version) {
        $ERROR = "Cannot determine IP version for $ip";
        $ERRNO = 101;
        return;
    }

    # v4 : add .0 for missing quads
    if ($ip_version == 4) {
        my @quads = split /\./, $ip;

        # check number of quads
        if (scalar(@quads) > 4) {
            $ERROR = "Not a valid IPv address $ip";
            $ERRNO = 102;
            return;
        }
        my @clean_quads = (0, 0, 0, 0);

        foreach my $q (reverse @quads) {

            #check quad data
            if ($q !~ m/^\d{1,3}$/) {
                $ERROR = "Not a valid IPv4 address $ip";
                $ERRNO = 102;
                return;
            }

            # build clean ipv4
            unshift(@clean_quads, $q + 1 - 1);
        }

        return (join '.', @clean_quads[ 0 .. 3 ]);
    }

    # Keep track of ::
    my $num_of_double_colon = ($ip =~ s/::/:!:/g);
    if ($num_of_double_colon > 1) {
        $ERROR = "Too many :: in ip";
        $ERRNO = 102;
        return;
    }

    # IP as an array
    my @ip = split /:/, $ip;

    # Number of octets
    my $num = scalar(@ip);

    foreach (0 .. (scalar(@ip) - 1)) {

        # Embedded IPv4
        if ($ip[$_] =~ /\./) {

            # Expand Ipv4 address
            # Convert into binary
            # Convert into hex
            # Keep the last two octets

            $ip[$_] = substr( ip_bintoip( ip_iptobin( ip_expand_address($ip[$_], 4), 4), 6), -9);

            # Has an error occured here ?
            return unless (defined($ip[$_]));

            # $num++ because we now have one more octet:
            # IPv4 address becomes two octets
            $num++;
            next;
        }

        # Add missing trailing 0s
        $ip[$_] = ('0' x (4 - length($ip[$_]))) . $ip[$_];
    }

    # Now deal with '::' ('000!')
    foreach (0 .. (scalar(@ip) - 1)) {

        # Find the pattern
        next unless ($ip[$_] eq '000!');

        # @empty is the IP address 0
        my @empty = map { $_ = '0' x 4 } (0 .. 7);

        # Replace :: with $num '0000' octets
        $ip[$_] = join ':', @empty[ 0 .. 8 - $num ];
        last;
    }

    return (lc(join ':', @ip));
}

#------------------------------------------------------------------------------
# Subroutine ip_bintoip
# Purpose           : Transform a bit string into an IP address
# Params            : bit string, IP version
# Returns           : IP address on success, undef otherwise
sub ip_bintoip {
    my ($binip, $ip_version) = @_;

    # Define normal size for address
    my $len = ip_iplengths($ip_version);

    if ($len < length($binip)) {
        $ERROR = "Invalid IP length for binary IP $binip\n";
        $ERRNO = 189;
        return;
    }

    # Prepend 0s if address is less than normal size
    $binip = '0' x ($len - length($binip)) . $binip;

    # IPv4
    if ($ip_version == 4) {
        return join '.', unpack('C4C4C4C4', pack('B32', $binip));
    }

    # IPv6
    return join(':', unpack('H4H4H4H4H4H4H4H4', pack('B128', $binip)));
}

#------------------------------------------------------------------------------
# Subroutine ip_iptobin
# Purpose           : Transform an IP address into a bit string
# Params            : IP address, IP version
# Returns           : bit string on success, undef otherwise
sub ip_iptobin {
    my ($ip, $ipversion) = @_;

    # v4 -> return 32-bit array
    if ($ipversion == 4) {
        return unpack('B32', pack('C4C4C4C4', split(/\./, $ip)));
    }

    # Strip ':'
    $ip =~ s/://g;

    # Check size
    unless (length($ip) == 32) {
        $ERROR = "Bad IP address $ip";
        $ERRNO = 102;
        return;
    }

    # v6 -> return 128-bit array
    return unpack('B128', pack('H32', $ip));
}
=end pod

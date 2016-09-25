unit module Net::IP::Lite:ver<1.0.0>;

#------------------------------------------------------------------------------
# Subroutine ip-bintoip
# Purpose           : Transform a bit string into an IP address
# Params            : bit string, IP version
# Returns           : IP address on success, undef otherwise
sub ip-bintoip($binip, $ip_version) {

    # Define normal size for address
    my $len = ip-iplengths($ip_version);

    if $len < $binip.chars {
        $ERROR = "Invalid IP length for binary IP $binip\n";
        return;
    }

    # Prepend 0s if address is less than normal size
    $binip = '0' x ($len - $binip.chars) ~ $binip;

    # IPv4
    if $ip_version == 4 {
        return join '.', unpack('C4C4C4C4', pack('B32', $binip));
    }

    # IPv6
    return join(':', unpack('H4H4H4H4H4H4H4H4', pack('B128', $binip)));
} # ip-bintoip

#------------------------------------------------------------------------------
# Subroutine ip-iptobin
# Purpose           : Transform an IP address into a bit string
# Params            : IP address, IP version
# Returns           : bit string on success, undef otherwise
sub ip-iptobin($ip is copy, $ipversion) {

    # v4 -> return 32-bit array
    if $ipversion == 4 {
        return unpack('B32', pack('C4C4C4C4', split(/\./, $ip)));
    }

    # Strip ':'
    $ip =~~ s:g/://;

    # Check size
    unless $ip.chars == 32 {
        $ERROR = "Bad IP address $ip";
        return;
    }

    # v6 -> return 128-bit array
    return unpack('B128', pack('H32', $ip));
} # ip-iptobin

#------------------------------------------------------------------------------
# Subroutine ip-iplengths
# Purpose           : Get the length in bits of an IP from its version
# Params            : IP version
# Returns           : Number of bits: 32, 128, 0 (don't know)
sub ip-iplengths($version) {
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
# Returns           : expanded IP address orundef on failure
sub ip-expand-address($ip is copy, $ip-version) is export {

    unless $ip-version {
        warn "Cannot determine IP version for $ip";
        return;
    }

    # v4 : add .0 for missing quads
    if $ip-version == 4) {
        my @quads = split /\./, $ip;

        # check number of quads
        if +@quads > 4) {
            warn "Not a valid IPv address $ip";
            return;
        }
        my @clean_quads = (0, 0, 0, 0);

        for @quads.reverse -> $q {

            #check quad data
            if $q !~~ /^\d{1..3}$/ {
                warn "Not a valid IPv4 address $ip";
                return;
            }

            # build clean ipv4
            unshift (@clean_quads, $q + 1 - 1);
        }

        return (join '.', @clean_quads[ 0 .. 3 ]);
    }

    # Keep track of ::
    my $num_of_double_colon = ($ip ~~ s:g/::/:!:/);
    if $num_of_double_colon > 1 {
        warn "Too many :: in ip";
        return;
    }

    # IP as an array
    my @ip = split /:/, $ip;

    # Number of octets
    my $num = +@ip;

    for 0 .. (+@ip - 1) {

        # Embedded IPv4
        if @ip[$_] ~~ /\./ {

            # Expand Ipv4 address
            # Convert into binary
            # Convert into hex
            # Keep the last two octets

            @ip[$_] = substr( ip-bintoip( ip-iptobin( ip-expand-address(@ip[$_], 4), 4), 6), -9);

            # Has an error occured here ?
            return unless @ip[$_];

            # ++$num because we now have one more octet:
            # IPv4 address becomes two octets
            ++$num;
            next;
        }

        # Add missing trailing 0s
        @ip[$_] = ('0' x (4 - @ip[$_].chars)) ~ @ip[$_];
    }

    # Now deal with '::' ('000!')
    for 0 .. (+@ip - 1) {

        # Find the pattern
        next unless @ip[$_] eq '000!';

        # @empty is the IP address 0
        my @empty = map { $_ = '0' x 4 } (0 .. 7);

        # Replace :: with $num '0000' octets
        @ip[$_] = join ':', @empty[ 0 .. 8 - $num ];
        last;
    }

    return (lc (join ':', @ip));
} # ip-expand-address

#------------------------------------------------------------------------------
# Subroutine ip_is_ipv4
# Purpose           : Check if an IP address is version 4
# Params            : IP address
# Returns           : True (yes) or False (no)
sub ip-is-ipv4($ip) is export {
    # Check for invalid chars
    unless $ip ~~ /^<[\d\.]>+$/ {
        warn "Invalid chars in IP $ip";
        return False;
    }

    if $ip ~~ /^\./ {
        warn "Invalid IP $ip - starts with a dot"
        return False;
    }

    if $ip ~~ /\.$/ {
        warn "Invalid IP $ip - ends with a dot";
        return False;
    }

    # Single Numbers are considered to be IPv4
    if ($ip ~~ /^(\d+)$/ and $0 < 256) { return True }

    # Count quads
    my $n = ($ip =~~ tr/\./\./);

    # IPv4 must have from 1 to 4 quads
    unless $n >= 0 and $n < 4 {
        warn "Invalid IP address $ip";
        return False;
    }

    # Check for empty quads
    if $ip ~~ /\.\./ {
        warn "Empty quad in IP address $ip";
        return False;
    }

    for split /\./, $ip {
        # Check for invalid quads
        unless $_ >= 0 and $_ < 256 {
            warn "Invalid quad in IP address $ip - $_";
            return False;
        }
    }

    return True;
} # ip-is-ipv4

#------------------------------------------------------------------------------
# Subroutine ip_is_ipv6
# Purpose           : Check if an IP address is version 6
# Params            : IP address
# Returns           : True (yes) or False (no)
sub ip-is-ipv6($ip is copy) is export {
    # Count octets
    my $n = ($ip ~~ tr/:/:/);
    return False unless $n > 0 and $n < 8;

    # $k is a counter
    my $k;

    for split /:/, $ip {
        $k++;

        # Empty octet ?
        next if $_ eq '';

        # Normal v6 octet ?
        next if i:/^<[a-f\d]>{1..4}$/;

        # Last octet - is it IPv4 ?
        if ($k == $n + 1) && ip_is_ipv4($_) {
            $n++; # ipv4 is two octets
            next;
        }

        warn "Invalid IP address $ip";
        return False;
    }

    # Does the IP address start with : ?
    if $ip ~~ /^:<[^:]>/ {
        warn "Invalid address $ip (starts with :)";
        return False;
    }

    # Does the IP address finish with : ?
    if $ip ~~ /<[^:]>:$/ {
        warn "Invalid address $ip (ends with :)";
        return False;
    }

    # Does the IP address have more than one '::' pattern ?
    if $ip ~~ s:g/:(?=:)/:/ > 1 {
        warn "Invalid address $ip (More than one :: pattern)";
        return False;
    }

    # number of octets
    if $n != 7 && $ip !~~ /::/) {
        warn "Invalid number of octets $ip";
        return False;
    }

    # valid IPv6 address
    return True;
} # ip-is-ipv6

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

# Subroutines Exported by Default

### ip-reverse-address
- Purpose : Reverse an IP address, use dots for separators for all types
- Params  : IP address, IP version
- Returns : Reversed IP address on success, undef otherwise
```Perl6
sub ip-reverse-address(Str:D $ip is copy, UInt $ip-version where &ip-version)
  returns Str is export {...}
```

### ip-bintoip
- Purpose : Transform a bit string into an IP address
- Params  : bit string, IP version
- Returns : IP address on success, undef otherwise
```Perl6
sub ip-bintoip(Str:D $binip is copy where &binary,
  UInt $ip-version where &ip-version) returns Str is export {...}
```

### ip-remove-leading-zeroes
- Purpose : Remove leading (unneeded) zeroes from octets or quads
- Params  : IP address
- Returns : IP address with no unneeded zeroes
```Perl6
sub ip-remove-leading-zeroes(Str:D $ip is copy, UInt $ip-version where &ip-version)
  returns Str is export {...}
```

### ip-compress-address
- Purpose : Compress an IPv6 address
- Params  : IP, IP version
- Returns : Compressed IP or undef (problem)
```Perl6
sub ip-compress-address(Str:D $ip is copy, UInt $ip-version where &ip-version)
  returns Str is export {...}
```

### ip-iptobin
- Purpose : Transform an IP address into a bit string
- Params  : IP address, IP version
- Returns : bit string on success, undef otherwise
```Perl6
sub ip-iptobin(Str:D $ip is copy, UInt $ipversion)
  returns Str is export {...}
```

### ip-iplengths
- Purpose : Get the length in bits of an IP from its version
- Params  : IP version
- Returns : Number of bits: 32, 128, 0 (don't know)
```Perl6
sub ip-iplengths(UInt:D $version)
  returns UInt is export {...}
```

### ip-get-version
- Purpose : Get an IP version
- Params  : IP address
- Returns : 4, 6, 0 (don't know)
```Perl6
sub ip-get-version(Str:D $ip)
  returns UInt is export {...}
```

### ip-expand-address
- Purpose : Expand an address from compact notation
- Params  : IP address, IP version
- Returns : expanded IP address or undef on failure
```Perl6
sub ip-expand-address(Str:D $ip is copy, UInt $ip-version where &ip-version)
  returns Str is export {...}
```

### ip-is-ipv4
- Purpose : Check if an IP address is version 4
- Params  : IP address
- Returns : True (yes) or False (no)
```Perl6
sub ip-is-ipv4(Str:D $ip is copy)
  returns Bool is export {...}
```

### ip-is-ipv6
- Purpose : Check if an IP address is version 6
- Params  : IP address
- Returns : True (yes) or False (no)
```Perl6
sub ip-is-ipv6(Str:D $ip is copy)
  returns Bool is export {...}
```

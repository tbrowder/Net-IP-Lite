# Default Exported Subroutines

- Subroutine ip-reverse-address
  - Purpose : Reverse an IP address, use dots for separators for all types
  - Params  : IP address, IP version
  - Returns : Reversed IP address on success, undef otherwise

```Perl6
sub ip-reverse-address(Str:D $ip is copy, UInt $ip-version where &ip-version) returns Str is export {
```
#------------------------------------------------------------------------------
# Subroutine ip-bintoip
# Purpose : Transform a bit string into an IP address
# Params  : bit string, IP version
# Returns : IP address on success, undef otherwise
sub ip-bintoip(Str:D $binip is copy where &binary,
               UInt $ip-version where &ip-version) returns Str is export {

#------------------------------------------------------------------------------
# Subroutine ip-remove-leading-zeroes
# Purpose : Remove leading (unneeded) zeroes from octets or quads
# Params  : IP address
# Returns : IP address with no unneeded zeroes
sub ip-remove-leading-zeroes(Str:D $ip is copy, UInt $ip-version where &ip-version) returns Str is export {

#------------------------------------------------------------------------------
# Subroutine ip-compress-address
# Purpose : Compress an IPv6 address
# Params  : IP, IP version
# Returns : Compressed IP or undef (problem)
sub ip-compress-address(Str:D $ip is copy, UInt $ip-version where &ip-version) returns Str is export {

#------------------------------------------------------------------------------
# Subroutine ip-iptobin
# Purpose : Transform an IP address into a bit string
# Params  : IP address, IP version
# Returns : bit string on success, undef otherwise
sub ip-iptobin(Str:D $ip is copy, UInt $ipversion) returns Str is export {

#------------------------------------------------------------------------------
# Subroutine ip-iplengths
# Purpose : Get the length in bits of an IP from its version
# Params  : IP version
# Returns : Number of bits: 32, 128, 0 (don't know)
sub ip-iplengths(UInt:D $version) returns UInt is export {

#------------------------------------------------------------------------------
# Subroutine ip-get-version
# Purpose : Get an IP version
# Params  : IP address
# Returns : 4, 6, 0 (don't know)
sub ip-get-version(Str:D $ip) returns UInt is export {

#------------------------------------------------------------------------------
# Subroutine ip-expand-address
# Purpose : Expand an address from compact notation
# Params  : IP address, IP version
# Returns : expanded IP address or undef on failure
sub ip-expand-address(Str:D $ip is copy, UInt $ip-version where &ip-version) returns Str is export {

#------------------------------------------------------------------------------
# Subroutine ip-is-ipv4
# Purpose : Check if an IP address is version 4
# Params  : IP address
# Returns : True (yes) or False (no)
sub ip-is-ipv4(Str:D $ip is copy) returns Bool is export {

#------------------------------------------------------------------------------
# Subroutine ip-is-ipv6
# Purpose : Check if an IP address is version 6
# Params  : IP address
# Returns : True (yes) or False (no)
sub ip-is-ipv6(Str:D $ip is copy) returns Bool is export {

#=======================================================
# export(:util) subs below here
#=======================================================

#------------------------------------------------------------------------------
# Subroutine count-substrs
# Purpose : Count instances of a substring in a string
# Params  : String, Substring
# Returns : Number of substrings found
sub count-substrs(Str:D $ip, Str:D $substr) returns UInt is export(:util) {

#------------------------------------------------------------------------------
# Subroutine hexchar2bin
# Purpose : Convert a single hexadecimal character to a binary string
# Params  : Hexadecimal character
# Returns : Binary string
sub hexchar2bin(Str:D $hexchar where &hexadecimalchar) is export(:util) {

#------------------------------------------------------------------------------
# Subroutine hexchar2dec
# Purpose : Convert a single hexadecimal character to a decimal number
# Params  : Hexadecimal character
# Returns : Decimal number
sub hexchar2dec(Str:D $hexchar is copy where &hexadecimalchar) returns UInt is export(:util) {

#------------------------------------------------------------------------------
# Subroutine hex2dec
# Purpose : Convert a positive hexadecimal number (string) to a decimal number
# Params  : Hexadecimal number (string), desired length (optional)
# Returns : Decimal number (or string)
sub hex2dec(Str:D $hex where &hexadecimal, UInt $len = 0) returns Cool is export(:util) {

#------------------------------------------------------------------------------
# Subroutine hex2bin
# Purpose : Convert a positive hexadecimal number (string) to a binary string
# Params  : Hexadecimal number (string), desired length (optional)
# Returns : Binary number (string)
sub hex2bin(Str:D $hex where &hexadecimal, UInt $len = 0) returns Str is export(:util) {

#------------------------------------------------------------------------------
# Subroutine dec2hex
# Purpose : Convert a positive integer to a hexadecimal number (string)
# Params  : Positive decimal number, desired length (optional)
# Returns : Hexadecimal number (string)
sub dec2hex(UInt $dec, UInt $len = 0) returns Str is export(:util) {

#------------------------------------------------------------------------------
# Subroutine dec2bin
# Purpose : Convert a positive integer to a binary number (string)
# Params  : Positive decimal number, desired length (optional)
# Returns : Binary number (string)
sub dec2bin(UInt $dec, UInt $len = 0) returns Str is export(:util) {

#------------------------------------------------------------------------------
# Subroutine bin2dec
# Purpose : Convert a binary number (string) to a decimal number
# Params  : Binary number (string), desired length (optional)
# Returns : Decimal number (or string)
sub bin2dec(Str:D $bin where &binary, UInt $len = 0) returns Cool is export(:util) {

#------------------------------------------------------------------------------
# Subroutine bin2hex
# Purpose : Convert a binary number (string) to a hexadecimal number (string)
# Params  : Binary number (string), desired length (optional)
# Returns : Hexadecimal number (string)
sub bin2hex(Str:D $bin where &binary, UInt $len = 0) returns Str is export(:util) {

# Net::IP::Lite

[![Build Status](https://travis-ci.org/tbrowder/Net-IP-Lite-Perl6.svg?branch=master)]
  (https://travis-ci.org/tbrowder/Net-IP-Lite-Perl6)

This is a limited version of CPAN's Net::IP for Perl 6 and provides a
subset of its basic IPv4 and IPv6 address manipulation functions.

## Debugging

For debugging, use one the following methods:

- set the module's $DEBUG variable:

```
$Net::IP::Lite::DEBUG = True;
```

- set the environment variable:

```
NET_IP_LITE_DEBUG=1
```

## Functions Provided by Default

    use Net::IP::Lite;

  * ip-expand-address

  * Purpose : Expand an address from compact notation

  * Params : IP address

  * Returns : expanded IP address or the empty string ('') on failure

      my $full-addr = ip-expand-address($ip);

  * ip-reverse-address

Purpose : Reverse an address from compact notation

Params : IP address

Returns : reversed IP address or the empty string ('') on failure

    my $rev-addr = ip-reverse-address($ip);

Additional Functions Exported with Named Parameter `:util`
----------------------------------------------------------

The following functions are used internally by the default exported functions. Users should not normally need them.

    use Net::IP::Lite :internal;

  * ip-get-version export(:util)

  * Purpose : Get an IP version

  * Params : IP address

item2Returns
============

: 4, 6, or 0 (don't know)

      my $ipver = ip-get-version($ip);

  * ip-is-ipv4 export(:util)

Purpose : Check if an IP address is version 4

Params : IP address

Returns : True or False

    my $is-ipv4 = ip-is-ipv4($ip);

  * ip-is-ipv6 export(:util)

Purpose : Check if an IP address is version 6

Params : IP address

Returns : True or False

    my $is-ipv6 = ip-is-ipv6($ip);

All functions may be exported if desired:

    use Net::IP::Lite :ALL;

Limitations
-----------

Addresses may be entered in CIDR format and the network will be considered.

For the moment, no consideration for plain addresses (those without the network prefix and length) is made for invalidity other than the format.

All "plain" addresses will be expanded to the 32-bit (IPv4) or 128-bit (IPv6) format, but the network prefix will be respected in the expansion of addresses in CIDR format. Any CIDRs will be checked for validity for the type of address.

Installation
------------

Use one of the following two methods for a normal Perl 6 environment:

    zef install Net::IP::Lite
    panda install Net::IP::Lite

If either attempt shows that the module isn't found or available, ensure your installer is current:

    zef update
    panda update

If you want to use the latest version in the git repository, clone it and then:

    cd /path/to/cloned/repository/directory
    zef install .

or

    panda install .

Development
-----------

It is the intent of this author to gradually add functions from the parent module as needed, eventually approaching its full functionality. Interested users are encouraged to contribute improvements and corrections to this module, and pull requests, bug reports, and suggestions are always welcome.

While testing will be normally be done as part of the zef or panda installation, cloning this project will result in a Makefile that can be used in fine-tuning tests and yielding more verbose results during the development process. The Makefile can be tailored as desired.

Acknowledgements
----------------

This module is indebted to the CPAN Perl IP::Net module authors for providing such a useful set of functions:

  * Manuel Valente <manuel.valente@gmail.com>

  * Monica Cortes Sack <mcortes@ripe.net>

  * Lee Wilmot <lee@ripe.net>

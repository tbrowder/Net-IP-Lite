# Net::IP::Lite

[![Build Status](https://travis-ci.org/tbrowder/Net-IP-Lite-Perl6.svg?branch=master)]
  (https://travis-ci.org/tbrowder/Net-IP-Lite-Perl6)

This is a limited version of CPAN's Net::IP for Perl 6 and provides a
subset of its basic IPv4 and IPv6 address manipulation functions.

## Debugging

For debugging, use one the following methods:

- set the module's $DEBUG variable:

```Perl6
$Net::IP::Lite::DEBUG = True;
```

- set the environment variable:

```Perl6
NET_IP_LITE_DEBUG=1
```

## Functions Provided by Default

```Perl6
use Net::IP::Lite;
```

See [DEFAULT-SUBS](https://github.com/tbrowder/Net-IP-Lite-Perl6/DEFAULT-SUBS.md)

## Additional Functions Exported with Named Parameter `:util`

```Perl6
use Net::IP::Lite :util;
```

See [UTIL-SUBS](https://github.com/tbrowder/Net-IP-Lite-Perl6/UTIL-SUBS.md)

The following functions are used internally by the default exported
functions. Users should not normally need them.
- bin2hex

- ...


## Current Limitations

Addresses must be in "plain" format (no CIDR or other newtwork information).

For the moment, no consideration for addresses is made for invalidity
other than the format.

## Installation

Use one of the following two methods for a normal Perl 6 environment:

```Perl6
zef install Net::IP::Lite
panda install Net::IP::Lite
```

If either attempt shows that the module isn't found or available, ensure your installer is current:

```Perl6
zef update
panda update
```

If you want to use the latest version in the git repository, clone it and then:

```Perl6
cd /path/to/cloned/repository/directory
zef install .
```

or

```Perl6
panda install .
```

## Development

It is the intent of this author to gradually add functions from the
parent module as needed, eventually approaching its full
functionality. Interested users are encouraged to contribute
improvements and corrections to this module, and pull requests, bug
reports, and suggestions are always welcome.

While testing will be normally be done as part of the zef or panda
installation, cloning this project will result in a Makefile that can
be used in fine-tuning tests and yielding more verbose results during
the development process. The Makefile can be tailored as desired.

## Acknowledgements

This module is indebted to the CPAN Perl IP::Net module authors for
providing such a useful set of functions:

- Manuel Valente <manuel.valente@gmail.com>

- Monica Cortes Sack <mcortes@ripe.net>

- Lee Wilmot <lee@ripe.net>

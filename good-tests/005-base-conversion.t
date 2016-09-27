use v6;
use Test;

use Net::IP::Lite;

plan 6;

# base conversions
is hexchar2decimal('a'), 10;
is hexchar2binary('a'), '1010';

is hex2decimal('ff'), 255;
is bin2decimal('11'), 3;

is bin2hex('11'), 3;
is bin2hex('11', 4), '0003';

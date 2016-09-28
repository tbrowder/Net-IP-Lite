use v6;
use Test;

use Net::IP::Lite;

plan 6;

# base conversions
is hexchar2dec('a'), 10;
is hexchar2bin('a'), '1010';

is hex2dec('ff'), 255;
is bin2dec('11'), 3;

is bin2hex('11'), 3;
is bin2hex('11', 4), '0003';

#is hex2bin(), '';
#is dec2bin(), '';
#is dec2hex(), '';

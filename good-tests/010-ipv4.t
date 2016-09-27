use v6;
use Test;

use Net::IP::Lite;

plan 16;

# valid
ok ip-is-ipv4('10.10.10.10'), '4 octets';
ok ip-is-ipv4('10.10.10'),    '3 octets';
ok ip-is-ipv4('10.10'),       '2 octets';
ok ip-is-ipv4('10'),          '1 octet';

# not valid
nok ip-is-ipv4('a'),              'no letters allowed';
nok ip-is-ipv4('10.10.10.10.10'), 'too many octets';

# valid
is ip-get-version('1'),       '4', 'ipv4?';
is ip-get-version('1.2'),     '4', 'ipv4?';
is ip-get-version('1.2.3'),   '4', 'ipv4?';
is ip-get-version('1.2.3.4'), '4', 'ipv4?';

# not valid
is ip-get-version('a.2.3.4'),   '0', 'ipv4?';
is ip-get-version('1.2.3.4.5'), '0', 'ipv4?';

# valid
is ip-expand-address('1', 4),       '1.0.0.0';
is ip-expand-address('1.2', 4),     '1.2.0.0';
is ip-expand-address('1.2.3', 4),   '1.2.3.0';
is ip-expand-address('1.2.3.4', 4), '1.2.3.4';

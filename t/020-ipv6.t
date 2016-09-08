use v6;
use Test;

plan 5;

# valid
ok ip-is-ipv6 '1::1';
ok ip-is-ipv6 '1:a:c:1';

# not valid
nok ip-is-ipv6 '1::1::1';
nok ip-is-ipv6 '::1';
nok ip-is-ipv6 '1:2:3:4:5:6:7:8:9';

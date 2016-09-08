use v6;
use Test;

plan 6;

# valid
ok ip-is-ipv4 '0.0.0.0';
ok ip-is-ipv4 '0.0.0';
ok ip-is-ipv4 '0.0';
ok ip-is-ipv4 '0';

# not valid
nok ip-is-ipv4 'a';
nok ip-is-ipv4 '0.0.0.0.0;

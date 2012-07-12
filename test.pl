#!/usr/bin/perl -w

use Math::Compute ':all';

my %map = ('t', 2);
my $expr = 'ln(5+((1+t)*4)-3)/ln(14)'; # 14

my $new_expr = &compute(&to_RPN($expr, \%map));

print "$expr=";
print "$new_expr\n";

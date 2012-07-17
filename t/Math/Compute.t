#!/usr/bin/perl -w

use Math::Compute ':all';
use Test;

BEGIN { plan tests => 3}

&testParsing();
&testComputing();
&testParsingComputing();
&testSub();
&wrongNumberOfParams();

sub testParsing {
	my $wanted = "0 3 - x 2 * Z0 5 - 2 35 ^ ^ / +";
	my $expr = "-3+x*2/(Z0-5 )^2^y'";
	
	my %map = ();
	
	$map{"y'"} = 35;

	my $result = &to_RPN($expr, \%map);
	
	&ok($wanted, $result); 
	
	$wanted = "5 1 2 + 4 * + 3 -";
	$expr = "5+((1+2)*4)-3";
	
	$result = &to_RPN($expr, \%map);
	&ok($wanted, $result); 
	
	
	$wanted = "1 2 / m g * 2 ^ m log + g exp + * sqrt";
	$expr = "sqrt((1/2)*(m*g)^2+log(m) + exp(g))";
	
	$result = &to_RPN($expr, \%map);
	&ok($wanted, $result); 
}

sub testComputing {
	my $wanted = "-1";
	my $expr = "3 4 -";
	
	my $result = &compute($expr);
	&ok($wanted, $result); 

	$wanted = "1";
	$expr = "1e+1 log";
	
	$result = &compute($expr);
	&ok($wanted, $result); 		
}

sub testParsingComputing {
	my %map = ();
	my $wanted = "5";
	my $expr = "sqrt(a^2 + b^2)";
	$map{'a'} = 3;
	$map{'b'} = 4;
	my $result = &compute(&to_RPN($expr, \%map));
	&ok($wanted, $result); 	
	
	
	$wanted = "6";
	$expr = "sqrt((1/4)*(m*g)^2) + log(10) - exp(0)";
	$map{'m'} = 3;
	$map{'g'} = 4;
	$result = &compute(&to_RPN($expr, \%map));
	&ok($wanted, $result); 	
	
	
	$wanted = 3**10**2;
	$expr = "3^10^2";
	$result = &compute(&to_RPN($expr, \%map));
	&ok($wanted, $result); 	


	$wanted = (3**10)**2;
	$expr = "(3^10)^2";
	$result = &compute(&to_RPN($expr, \%map));
	&ok($wanted, $result); 	
}

sub testSub {
	my %map = ();
	my $wanted = "-3";
	my $expr = "(-1)+(-2)";
	my $result = &compute(&to_RPN($expr, \%map));
	&ok($wanted, $result);
	

	$wanted = "0";
	$expr = "3+($result)";
	$result = &compute(&to_RPN($expr, \%map));
	&ok($wanted, $result);
	
	
}

sub wrongNumberOfParams {
	my %map = ();
	my $expr = "log(2,1)";

	my $result = &compute(&to_RPN($expr, \%map));
	
	
	
}



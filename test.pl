#!/usr/bin/perl -w

use Math::Compute ':all';

&testParsing();
&testComputing();
&testParsingComputing();
&testSub();

sub testParsing {
	my $wanted = "0 3 - x 2 * Z0 5 - 2 35 ^ ^ / +";
	my $expr = "-3+x*2/(Z0-5 )^2^y'";
	
	my %map = ();
	
	$map{"y'"} = 35;

	my $result = &to_RPN($expr, \%map);
	
	print "testParsing 1 :\n";
	&assert($wanted, $result); 
	
	$wanted = "5 1 2 + 4 * + 3 -";
	$expr = "5+((1+2)*4)-3";
	
	$result = &to_RPN($expr, \%map);
	print "testParsing 2 :\n";
	&assert($wanted, $result); 
	
	
	$wanted = "1 2 / m g * 2 ^ m log + g exp + * sqrt";
	$expr = "sqrt((1/2)*(m*g)^2+log(m) + exp(g))";
	
	$result = &to_RPN($expr, \%map);
	print "testParsing 3 :\n";
	&assert($wanted, $result); 
}

sub testComputing {
	my $wanted = "-1";
	my $expr = "3 4 -";
	
	my $result = &compute($expr);
	print "testComputing 1 :\n";
	&assert($wanted, $result); 

	$wanted = "1";
	$expr = "1e+1 log";
	
	$result = &compute($expr);
	print "testComputing 2 :\n";
	&assert($wanted, $result); 		
}

sub testParsingComputing {
	my %map = ();
	my $wanted = "5";
	my $expr = "sqrt(a^2 + b^2)";
	$map{'a'} = 3;
	$map{'b'} = 4;
	my $result = &compute(&to_RPN($expr, \%map));
	print "testParsingComputing 1 :\n";
	&assert($wanted, $result); 	
	
	
	$wanted = "6";
	$expr = "sqrt((1/4)*(m*g)^2) + log(10) - exp(0)";
	$map{'m'} = 3;
	$map{'g'} = 4;
	$result = &compute(&to_RPN($expr, \%map));
	print "testParsingComputing 2 :\n";
	&assert($wanted, $result); 	
	
	
	$wanted = 3**10**2;
	$expr = "3^10^2";
	$result = &compute(&to_RPN($expr, \%map));
	print "testParsingComputing 3 :\n";
	&assert($wanted, $result); 	


	$wanted = (3**10)**2;
	$expr = "(3^10)^2";
	$result = &compute(&to_RPN($expr, \%map));
	print "testParsingComputing 4 :\n";
	&assert($wanted, $result); 	
}

sub testSub {
	my %map = ();
	my $wanted = "-3";
	my $expr = "(-1)+(-2)";
	my $result = &compute(&to_RPN($expr, \%map));
	print "testSub 1 :\n";
	&assert($wanted, $result);
	

	$wanted = "0";
	$expr = "3+($result)";
	$result = &compute(&to_RPN($expr, \%map));
	print "testSub 2 :\n";
	&assert($wanted, $result);
	
	
}

sub assert {
	my ($wanted, $result) = @_;
	
	if ($wanted ne $result) {
		print "Error [$result] is not equals to\n      [$wanted]\n";
	} else {
		print "OK    [$result] is equals to\n      [$wanted]\n";
	}
	print "\n";
}

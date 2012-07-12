package Math::Compute;

use 5.014002;
use strict;
use warnings;
use Carp;
use Scalar::Util 'looks_like_number';

use Data::Dumper;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration    use Math::Compute ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
    to_RPN compute 
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.01';

#require XSLoader;
#XSLoader::load('Math::Compute', $VERSION);

# Preloaded methods go here.
our $DEBUG_LOG = 1;

our $NB_ARG = 'nb_arg';
our $CALC   = 'calc';
our $REGEX  = 'regex';
our $PRECEDENCE = 'precedence';
our $LEFT_ASSO  = 'left_associative';

our $TRUE = 1;
our $FALSE= 0;

our %operator = (
        '+' => { $NB_ARG     => 2, 
                 $REGEX      => '[+]',
                 $PRECEDENCE => 12,
                 $LEFT_ASSO  => $TRUE,
                 $CALC       => \&_add},
        '-' => { $NB_ARG => 2,
                 $REGEX  => '[-]',
                 $PRECEDENCE => 12,
                 $LEFT_ASSO  => $TRUE,
                 $CALC    => \&_sub },
        '*' => { $NB_ARG => 2,
                 $REGEX  => '[*]',
                 $PRECEDENCE => 13,
                 $LEFT_ASSO  => $TRUE,
                 $CALC    => \&_mul },
        '/' => { $NB_ARG => 2,
                 $REGEX  => '[/]',
                 $PRECEDENCE => 13,
                 $LEFT_ASSO  => $TRUE,
                 $CALC    => \&_div },
        '%' => { $NB_ARG => 2,
                 $REGEX  => '[%]',
                 $PRECEDENCE => 13,
                 $LEFT_ASSO  => $TRUE,
                 $CALC    => \&_mod },
        '^' => { $NB_ARG => 2,
                 $REGEX  => '[\^]',
                 $PRECEDENCE => 14,
                 $LEFT_ASSO  => $FALSE,
                 $CALC    => \&_pow },
);

our %function = (
        'ln' => {
                $NB_ARG => 1,
                $CALC   => \&_ln},

);

sub _ln {
    log $_[0];
}

sub _add {
    my ($op1, $op2) = @_;
    return $op1 + $op2;
}

sub _sub{
    my ($op1, $op2) = @_;
    return $op1 - $op2;
}

sub _mul{
    my ($op1, $op2) = @_;
    return $op1 * $op2;
}

sub _div{
    my ($op1, $op2) = @_;
    return $op1 / $op2;
}

sub _mod{
    my ($op1, $op2) = @_;
    return $op1 / $op2;
}

sub _pow{
    my ($op1, $op2) = @_;
    return $op1 ** $op2;
}
#private function that format its input string.
# return a formatted string.
sub _format_expression {
    my $expr = shift;
    
    $expr =~ s/\(/ \( /g;
    $expr =~ s/\)/ \) /g;
    $expr =~ s/,/ , /g;
    
    
    
    for my $op ( keys %operator) {
        $expr =~ s/$operator{$op}{$REGEX}/ $op /g;
    }
    
    
    $expr =~ s/\s+/ /g;
    
    
    $expr;
}

# Takes a math expression string as parameter, and a map name->value of variables
# return a RPN notation of the expression.
sub to_RPN {
    my $expr = shift;
    my $map_ref = shift;
    
    my %var = %$map_ref;
    
    $expr = _format_expression($expr);
    
    my @stack = ();
    my @queue = ();
    
    my @tokens = split / /, $expr;
    
    _analyze(\@tokens, \@queue, \@stack, \%var);
}

#private function that takes 4 arguments passed by reference : 
#    @tokens : a list of math token
#    @queue  : the output queue
#    @stack  : the operator stack
#    %var    : a map name<->value for the variables.
sub _analyze {
    &log("Analyzing ...");
    my ($token_ref, $queue_ref, $stack_ref, $var_ref) = @_;
    
    my @tokens = @$token_ref;
    my @queue  = @$queue_ref;
    my @stack  = @$stack_ref;
    my %var    = %$var_ref;

    foreach my $token (@tokens) {
        &log("\nTreatment of token '$token'.");
        if (&looks_like_number($token)) {
            &log("$token is a number. Adding it to the queue.");
            push @queue, $token;
            next;
        } elsif (&_isVariable($token, $var_ref)) {
            &log("$token is a variable. Adding its value if defined to the queue.");
            if(defined $var{$token}) {
                my $val = $var{$token};
                &log("Replacing variable $token by its value $val.");
                push @queue, $val;
            } else {
                push @queue, $token;
            }
            next;
        } elsif (&_isOperator($token)) {
            &log("Token $token is an operator.");
            
            my $peek = $stack[$#stack];
            if (defined $peek) {
                if (&_isOperator($peek)) {
                    # peek stack
                    
                    my $op1 = $operator{$token};
                    my $op2 = $operator{$peek};
                    
                    #print Dumper($op1);
                    #print "$op1{$PRECEDENCE} : $op2{$PRECEDENCE}\n";
                    if (($op1->{$PRECEDENCE} <= $op2->{$PRECEDENCE} && $op1->{$LEFT_ASSO})
                     || ($op1->{$PRECEDENCE}  < $op2->{$PRECEDENCE} && !$op1->{$LEFT_ASSO})) {
                        &log("$token priority is <= $peek priority and $token is left-associative.") if $op1->{$LEFT_ASSO};
                        &log("$token priority is <= $peek priority and $token is right-associative.") if !$op1->{$LEFT_ASSO};
                        &log("Popping $peek from the stack, and push it to the queue.");
                        
                        push @queue, (pop @stack);
                    } else {
                        if ($op1->{$PRECEDENCE} > $op2->{$PRECEDENCE}) {
                            &log("$token priority is > $peek priority.");
                        }
                    }
                }
            }
            &log("Pushing $token onto the stack.");
            push @stack, $token;
            next; # verifier si necessaire, n'y est pas en java. 
        } elsif (&_isFunction($token)) {
            &log("$token is a function. Pushing it onto the stack.");
            push @stack, $token;
            next;
        } elsif (&_isFunctionArgSeparator($token)) {
            &log("$token is a function arg separator.");
            
            while ('(' ne $stack[$#stack]) {
                my $pop = pop @stack;
                &log("Pop $pop from stack, adding it to the queue.");
                push @queue, $pop;
                if( @stack == 0) {
                    croak 'Parenthesis mismatch.';
                }
            }
            next;
        } elsif ('(' eq $token) {
            &log("Pushing $token onto the stack;");
            push @stack, $token;
            next;
        } elsif (')' eq $token) {
            &log("until ( is found on the stack, pop token from the stack to the queue.");
            
            while ('(' ne $stack[$#stack]) {
                my $pop = pop @stack;
                &log("\tAdding $pop to the queue.");
                push @queue, $pop;
            }
            &log("( found. Dismiss from the stack.");
            pop @stack;
            
            if (&_isFunction($stack[$#stack])) {
                my $peek  = $stack[$#stack];
                &log("$peek is a function, pop it from the stack to the queue.");
                push @queue, (pop @stack);
            }
        } else {
            &log("$token unknown. Maybe a variable ?. Added to the queue.");
            push @queue, $token;
        }
        next;
    }
    
    &log("No more token to read.");
    while(@stack != 0) { 
        if( '(' eq $stack[$#stack]) {
            croak "Parenthesis mismatch.";
        }
        my $pop = pop @stack;
        &log("Popping $pop from the stack to the queue.");
        push @queue, $pop;
    }
    
    my $result = join ' ', @queue;
    print "$result\n";
    return $result;
}

# Takes a RPN expression string.
# return the result of the computation.
sub compute {
    my $expr = shift;
    
    my @tokens = split ' ', $expr;
    
    my @stack = ();
    
    foreach my $token (@tokens) {
        if (&_isFunction($token)) {
            &log("$token is a function. Computing...");
            my $nb_args = $function{$token}->{$NB_ARG};
            my @args = ();
            for(0..$nb_args-1) {
                push @args, pop @stack;
            }
            
            @args = reverse @args;
        
            my $result = $function{$token}->{$CALC}->(@args);
            &log("$token(@args)=$result");
            push @stack, $result;
        } elsif (&_isOperator($token)) {
            &log("$token is an operator. Computing...");
            
            my $nb_args = $operator{$token}->{$NB_ARG};
            my @args = ();
            for(0..$nb_args-1) {
                push @args, pop @stack;
            }
            @args = reverse @args;
            my $result = $operator{$token}->{$CALC}->(@args);
            &log("$token(@args)=$result");
            push @stack, $result;
        } else {
            &log("Push $token onto the stack.");
            push @stack, $token;
        }
    }
    
    if(@stack != 1) { # only the final result should be on the stack
        croak "Some tokens are still on the stack, though all the formula has been analyzed.";
    }
    
    return pop @stack;
    
}



## Private methods



sub log {
    print $_[0]."\n" if $DEBUG_LOG;
}

sub _isNumber {
    &looks_like_number($_[0]);
}

sub _isVariable {
    my ($token, $map_ref) = @_;
    $map_ref->{$token};
}

sub _isOperator {
    defined $operator{$_[0]};
}

sub _isFunction {
    defined $function{$_[0]};
}

sub _isFunctionArgSeparator {
    ',' eq $_[0];
}

1;
__END__

=head1 NAME

Math::Compute - Perl extension for Math formula expression.

=head1 SYNOPSIS

  use Math::Compute;
  

=head1 DESCRIPTION


=head2 EXPORT



=head1 HISTORY

=over 8

=back



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

B. MORIN

=head1 COPYRIGHT AND LICENSE

  Copyright 2012 B. MORIN
  
  Licensed under the Apache License, Version 2.0 (the "License"); you may not
  use this file except in compliance with the License. You may obtain a copy of
  the License at
  
  http://www.apache.org/licenses/LICENSE-2.0
  
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
  License for the specific language governing permissions and limitations under
  the License.

=cut

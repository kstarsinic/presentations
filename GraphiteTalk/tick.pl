#!/home/kstar/perl5/perlbrew/perls/perl-5.16.0/bin/perl

use strict;
use warnings;

require Net::Graphite;
require POSIX;

my $TPD = 60 * 60 * 6.5; # 2340 ticks per day -- whisper can't handle fractional seconds
print "TPD is $TPD\n";

my %U = (
    GOOG    => { open => 677.50, close => 688.21, max_tick => 2, volume => 1_120_000, block_size => 50, },
    IBM     => { open => 194.30, close => 196.94, max_tick => 5, volume => 1_750_000,                   },
    SSTK    => { open =>  24.75, close =>  24.69, max_tick => 7, volume =>    15_000,                   },
    # Thomson/Reuters
    # BofA
);

foreach my $u (values %U) {
    $$u{current}        = $$u{open};
    $$u{block_size}   ||= 100;
    $$u{threshold}      = $$u{volume} / $$u{block_size} / $TPD;
    $$u{p_size}         = 2 * $$u{max_tick} + 1;
    $$u{booked}         = 0;
}


my $G = Net::Graphite->new;

my ($month, $year) = (10, 112); # November, 2012
my $begin = 9.5 * 60 * 60; # 9:30 AM
my @mday = @ARGV ? @ARGV : (1, 2, 5);
foreach my $mday (@mday) {
    printf "%02d-%02d-%04d\n", $month+1, $mday, $year+1900;
    for (my $t = $begin; $t < $begin+$TPD; ++$t) {
        my $sec     = $t % 60;
        my $min     = int($t/60) % 60;
        my $hour    = int($t/3600) % 60;
        my $time    = POSIX::mktime($sec, $min, $hour, $mday, $month, $year);
        my $scale   = $t / $TPD;

        while (my ($name, $u) = each %U) {
            if (rand() < $$u{threshold}) {
                my $mean    = $$u{open} * (1 - $scale) + $$u{close} * $scale;
                my $size    = (int(rand $$u{p_size}) - $$u{max_tick}) * .01;
                my $note    = '';

                if      ($size > 0 and $$u{current} > $mean + .02*$$u{max_tick}) {
                    $$u{current} += $size - .01;
                    $note = '-';
                } elsif ($size < 0 and $$u{current} < $mean - .02*$$u{max_tick}) {
                    $$u{current} += $size + .01;
                    $note = '+';
                } else {
                    $$u{current} += $size;
                }

                $$u{booked} += $$u{block_size};
                my $localtime = localtime($time);
                printf(
                    "%1s %-5s \$%6.2f [%6.2f - %6.2f; %6.2f] \@ %s (%8d/%8d)\n",
                    $note, $name,
                    $$u{current}, $$u{open}, $$u{close}, $mean,
                    $localtime, $$u{booked}, $$u{volume}
                ) if rand() > .99;
                $G->send(
                    path    => "system.useq.$name",
                    time    => $time,
                    value   => $$u{current},
                );
            }
        }
    }

    while (my ($name, $u) = each %U) {
        $$u{open}   = $$u{close};
        $$u{close}  = sprintf "%.2f", $$u{close} * 1.05;
    }
}


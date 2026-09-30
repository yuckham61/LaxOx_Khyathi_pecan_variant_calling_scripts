#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use Data::Dumper;

# ------------------------------------------------------------
# Usage:
#   perl vcf_variant_windows_records.pl \
#        --vcf input.vcf --winsize 100 --step 50
#
# Output (one line per sample per window):
#   CHROM  start_pos  stop_pos  SAMPLE  missing_count  minor_alleles  median_call_freq
#
# Definitions
# - winsize and step are in number of variants (not basepair window)
# - missing_count: number of missing GTs for the sample in the window
# - minor_alleles: number of sites where the sample carries the minor allele
# - median_call_freq: median over variants in the window on a per sample basis
#   Variants where the sample is missing are excluded from the median.
# ------------------------------------------------------------

my ($winsize, $step);

GetOptions(
    'winsize=i' => \$winsize,
    'step=i'    => \$step,
) or die "Argument parsing error\n";

my $total_threshold = 10;
warn "must be at least $total_threshold explicit calls to calculate frequency of a variant\n";

my $freqThreshold = 10;
warn "must have at least $freqThreshold values per window to calculate median frequency for a sample\n";

die "Usage: $0 --winsize N --step N input.vcf \n  can't find winsize $winsize or step $step \n" unless $winsize && $step;

my @samples;
my $nsamples;

my @window;          # array of variant records
my $current_chr;

print join("\t",
    "chr",
    "start_pos",
    "stop_pos",
    "sample",
    "miss_ct",
    "minor_ct",
    "median_freq"
), "\n";

while (<>) {
    chomp;

    # ----------------- Header -----------------
    if (/^#CHROM/) {
        my @F = split /\t/;
        @samples  = @F[9 .. $#F];
        $nsamples = scalar(@samples);
        next;
    }
    next if /^#/;

    my @F = split /\t/;
    my ($chr, $pos, $fmt) = @F[0,1,8];
	
    # ----------------- Chromosome reset -----------------
    if (!defined $current_chr || $chr ne $current_chr) {
        @window      = ();
        $current_chr = $chr;
    }

	push @window, $_; #adds chomp line to window

    # ----------------- Emit windows -----------------
    while (@window >= $winsize) {
		my $start_pos;
		my $stop_pos;
		my @freqs;
		my @miss_ct = (0) x $nsamples;
		my @min_ct = (0) x $nsamples;
		foreach my $windex (0 .. $#window) {
			my @F = split /\t/, $window[$windex];
		    my ($chr, $pos, $fmt) = @F[0,1,8];
		    my @gt_fields = @F[9 .. $#F];
			
			$start_pos = $pos if $windex == 0;
			$stop_pos = $pos if $windex == $#window;
			
			my %count;
		    for my $i (0 .. $#gt_fields) {
		        my $gt  = $gt_fields[$i];
		        if (!defined $gt || $gt eq '.' || $gt =~ /\./) {
		            $miss_ct[$i]++;
		        } else {
		            $count{$gt}++;
		        }
		    }
		    # ----------------- Determine minor allele -----------------
		    
			my $minor;
			my %minors;
		    if (keys %count >= 2) {
		        my @sorted = sort { $count{$a} <=> $count{$b} } keys %count;
		        $minor = $sorted[0];
				foreach (@sorted) {
					$minors{$_}=1 if $count{$_} == $minor;
				}
		    }
			
		    for my $i (0 .. $#gt_fields) {
		        my $gt  = $gt_fields[$i];
		        $min_ct[$i]++ if defined $minors{$gt} && $minors{$gt};
		    }
			
		    my $den = 0;
		    $den += $_ for values %count;   # non-missing samples
			
		    for my $i (0 .. $#gt_fields) {
				my $gt  = $gt_fields[$i];
				next unless $count{$gt} && ($den > $total_threshold);
		    	push @{$freqs[$i]}, $count{$gt} / $den;
			}
			
		}
		for my $s (0 .. $#samples) {
			my $med = 'NA';
			$med = sprintf("%.3f", median($freqs[$s])) if defined($freqs[$s]) && scalar(@{$freqs[$s]}) > $freqThreshold;
			print join("\t",
	            $current_chr,
	            $start_pos,
	            $stop_pos,
	            $samples[$s],
	            $miss_ct[$s] / $winsize,
	            $min_ct[$s] / $winsize,
	            $med
	        ), "\n";
		}
        # Slide window
        splice(@window, 0, $step);
    }
}

# ----------------- Median -----------------
sub median {
    my ($aref) = @_;
    return 'NA' unless $aref && @$aref;

    my @sorted = sort { $a <=> $b } @$aref;
    my $n = @sorted;

    return $n % 2
        ? $sorted[int($n / 2)]
        : ($sorted[$n/2 - 1] + $sorted[$n/2]) / 2;
}

####
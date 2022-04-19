#!/usr/bin/perl
use strict;
use List::Util qw(max);
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);

&title;

my $fasta = "";
my $ref = "";
my $start = "";
my $end = "";
my $bam = "";
my $temp = "temp";
my $output = "contig.bam";
my $max = "10000";
my $check = "1";
my $small = "500";
my $cpu = "8";

GetOptions('f=s' => \$fasta,'b=s' => \$bam, 'o=s' => \$output, 'O=s' => \$temp, 'm=i' => \$max, 'c=f' => \$check, 'p=i' => \$cpu, 'r=s' => \$ref, 's=i' => \$start, 'e=i' => \$end);
my $size = $end - $start;
die "\ntarget chromosome and target position is required !\n\n\n" if($start eq "" && $end eq "" && $ref eq "");
die "\nfasta fileis required !\n\n\n" if($fasta eq "");
die "\nbam fileis required !\n\n\n" if($bam eq "");
die "\nend position must be larger than start position !\n\n\n" if($end <= $start);
die "\nMax assembly size is 10000-bp.\n\n\n" if($max < $size);
&fastq;
&assembly;
&mapping;
print "Local assembly and mapping is finished. \n\n";

#######################################################################################################################################################################################
### SUBROUTINES ###

sub title {
	####################################################################################################################################
	#
	#						local_assembly_and_alignment 1.0
	#
	#						Kazuma Uesaka
	#						University of Nagoya
	#						17 April 2022
	#		
	#						A Perl scripts to call SV position from mapped.bam.
	#	                    Install; run "mamba install -c bioconda -y bamutil samtools spades seqkit"
	#
	#						Input:
	#							Paired-end short read bam(-b) and their reference.fasta(-f). Chr (-r), start (-s), and end position (-e), respectively. 
	#
	#						Outnput:
	#							Bam file; locally assembled contig from the reads in user specified region
	#						
	#						Usage:
	#						perl local_assembly_and_alignment.pl -f assembly.fasta -r chr1 -s 100 -e 1000 -b mapping.bam
	#
	####################################################################################################################################

	print "\n\n############################################################################################################################################################\n";
	print "Program: local_assembly_and_alignment\n";
	print "version 1.0\n\n";
	print "\nUsage:	perl local_assembly_and_alignment.pl -f assembly.fasta -r chr1 -s 100 -e 1000 -b mapping.bam <options>\n\n";
	print "Input/output options:\n\n";
	print "\t -b	input BAM (Required)\n";
	print "\t -f	input fasta (Required)\n";
	print "\t -o	output file name (default contig.bam)\n";
	print "\t -O	temporary directory (default temp)\n";
	print "############################################################################################################################################################\n\n";
	my @now = localtime;print "\nINFO $now[2]:$now[1]:$now[0]\t";
}

#-----------------------------------------------------------------------------------------------------------------------------------
sub fastq {
    system("mkdir temp");
    system("samtools view -@ $cpu -b $bam ${ref}\:${start}-${end} > temp/target.bam");
    system("bam bam2FastQ --in temp/target.bam --outBase out 2> temp/log");
    system("mv out_1.fastq out_2.fastq out.fastq temp/");
}
#-----------------------------------------------------------------------------------------------------------------------------------
sub assembly {
    system("spades.py -1 temp/out_1.fastq -2 temp/out_2.fastq -s temp/out.fastq -t $cpu -k auto -o temp/spades 1> temp/log 2> temp/errorlog");
    system("seqkit seq -m 300 temp/spades/contigs.fasta > temp/contig.fasta");
}
#-----------------------------------------------------------------------------------------------------------------------------------
sub mapping {
    system("minimap2 -ax asm5 $fasta temp/contig.fasta |samtools sort - > $output");
    system("samtools index $output");
}
#-----------------------------------------------------------------------------------------------------------------------------------

# local_assembly_and_alignment
local_assembly_and_alignment 1.0  
  
Kazuma Uesaka  
University of Nagoya  
17 April 2022  
A Perl scripts to call SV position from mapped.bam.  

Install; run "mamba install -c bioconda -y bamutil samtools spades seqkit"  
Input: Paired-end short read bam(-b) and their reference.fasta(-f). Chr (-r), start (-s), and end position (-e), respectively.   
Outnput: Bam file; locally assembled contig from the reads in user specified region  
Usage: perl local_assembly_and_alignment.pl -f assembly.fasta -r chr1 -s 100 -e 1000 -b mapping.bam  

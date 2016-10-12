#!/usr/bin/perl


#This function takes in a hash of terms and their counts and computes the
#TF for each term
sub get_TF{
my %hash = @_;
my @term_keys = keys %hash;
my $i = 0;
my $num_terms = 0;
while (defined($term_keys[$i])) {
	$num_terms+=$hash{$term_keys[$i]};
	$i++;
}
$i = 0;
while (defined($term_keys[$i])) {
$tf = $hash{$term_keys[$i]} / $num_terms; 

$hash{$term_keys[$i]} = $tf;
$i++;
}
return %hash;
}

#this function will read from the TF outfile, count how many files contain each
#unique term, and then calculate the IDF for each term and return a hash with
#terms as keys and their IDF as their values 
sub get_IDF{

my @TF = @_;

my %hash;
my $i = 0;
while (defined($TF[$i])){
	$line = $TF[$i];
	chomp($line);
	my @array = split(",", $line);
	if (exists $hash{$array[1]}){
		$hash{$array[1]} += 1;
	} else {
		$hash{$array[1]} = 1;
	}
	$i++;


}
@keys = keys %hash;
@keys = sort(@keys);
$i = 0;
while(defined($keys[$i])){
$idf = $num_files/$hash{$keys[$i]};
$idf = log ($idf);
$hash{$keys[$i]} = $idf;
 
$i++;
}



return %hash;

}

#this function calculates the TF-IDF, from the passed in IDF hash and TF data and prints the results to the outfile
sub getTFIDF {
my %hash = @_;
open(TFIN,"<",$tf_out);
open(TFIDFOUT,">",$tf_idf_out);
	while (my $line = <TFIN>) {
		chomp($line);
		@line_parts = split(',',$line);
		$idf = $hash{$line_parts[1]};
		$line_parts[2] *=$idf;
		print TFIDFOUT "$line_parts[0], $line_parts[1], $line_parts[2]\n";
	}	
close TFIN;
} 



$num_args = $#ARGV + 1;

if ($num_args != 1) {
	print"Usage: exam1.pl file_name\n";
	die;
}

$com_file = $ARGV[0];

open(COMMAND, "<",$com_file) or die("can't open file\n");

$i = 0;
while (my $line = <COMMAND>) {

	chomp($line);
	$first =substr($line, 0, 1);
	if ($first eq "#") {
	
	} else {
		($key,$value) = split(":",$line);
		if ($key eq "filedir") {
			
		$dir = $value;
		} elsif ($key eq "tfoutput") {

		$tf_out = $value;
		} elsif ($key eq "idfoutput") {
		
		
		$idf_out = $value;
		} elsif ($key eq "tf-idfoutput") {
		
		$tf_idf_out = $value;

		} else {
		
		}
	}

}

chdir($dir);
open(TFOUT,">",$tf_out) or die("can't open $tf_out\n");
open(IDFOUT,">",$idf_out) or die("can't open $idf_out\n");
open(TFIDFOUT,">",$tf_idf_out) or die("can't open $tf_idf_out");
@files = glob '*';

$num_files = scalar @files;

$i = 0;
while (defined($files[$i])) {
	
	open(FILE, "<",$files[$i]);
	my %terms;
	$num_terms = 0;
	while(my $line = <FILE>){
		chomp($line);
		@line_words = split('\s',$line);
		$j = 0;
		while(defined($line_words[$j])){
			$word = uc $line_words[$j];
			$word =~ s/\W//g;
			$num_terms++;
			if(exists($terms{$word})) {
				$terms{$word} += 1;
			} else {
				$terms{$word} = 1;
			}
			$j += 1;
		}
	}
	close FILE;
	
	%tfs = get_TF(%terms);  
	@keys = keys %tfs;
	@keys = sort(@keys);
	$k = 0;
while (defined($keys[$k])) {
	print TFOUT  "$files[$i], $keys[$k] , $tfs{$keys[$k]}\n";
		$k++;
	}
	
	$i++;
 }
close TFOUT;

open(TFIN,"<",$tf_out)or die("can't open $tf_out\n");
@tflines;
while(my $tfline = <TFIN>){
	
	push(@tflines, $tfline);
}
%idf = get_IDF(@tflines);
@idkeys = keys %idf;
@idkeys = sort(@idkeys);
$z = 0;
while(defined($idkeys[$z])) {

print IDFOUT "$idkeys[$z] , $idf{$idkeys[$z]}\n";

$z++;
}

getTFIDF(%idf);

print "Finished\n";
close TFOUT;
close IDFOUT;
close TFIDFOUT;



		





#!/usr/bin/perl -w

use List::MoreUtils qw(uniq);

# The index.md-file is generated with this little script
# use it the following way:
#
# ls | ./gen.pl > index.md
#
# This script generates valid markdown-output with a jekyll-header.
# It reads all files and compiles the versions together in a table.

my @files = (); # ".tar.gz", "-1.deb", "-1_all.deb", "-1.noarch.rpm" );
my @sigs = ( "asc", "sha1", "md5", "sha256");
my @versions = ();

for(<>){
	if(m/rsnapshot(-|_)(([0-9]+\.)+[0-9]+)/){
		push @versions, $2;
		$_ =~ s/^\s+|\s+$//g;
		push @files, $_;
	}
}

print "---\n";
print "layout: page\n";
print "title: All rsnapshot versions\n";
print "hide: true\n";
print "---\n";

print "| VERSION | FILE | CHECKSUMS |\n";
print "| :-----: | :--: | :-------: |\n";

for $version (uniq reverse sort @versions){

	print " | ";

	print "$version";

	print " | ";

	for $file (@files){
		if( $file =~ /rsnapshot.$version.*\.(tar\.gz|deb|_all\.deb|noarch\.rpm)$/ ){
			print "[`$file`]($file)<br>";
		}
	}

	print " | ";

	for $file (@files){
		if( $file =~ /rsnapshot.$version[^.]*\.(.*\.(asc|sha1|md5|sha256))$/ ){
		  my $visual = $1;
			print "[`$visual`]($file)<br>";
		}
	}

	print " |\n";
}

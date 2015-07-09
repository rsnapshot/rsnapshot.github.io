#!/usr/bin/perl -w

use List::MoreUtils qw(uniq);

my @files = ( ".tar.gz", "-1.deb", "-1.noarch.rpm" );
my @sigs = ( "asc", "sha1", "md5", "sha256");
my @versions = ();

for(<>){
	if(m/rsnapshot(-|_)(([0-9]+\.)+[0-9]+)/){
		push @versions, $2;
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
		if( -e "rsnapshot-$version$file"){
			print "[rsnapshot-$version$file](rsnapshot-$version$file)<br>";
		}
	}

	print " | ";

	for $file (@files){
		my $visual = $file;
		$visual =~ s/^(-1)?\.?//;
		for $sig (@sigs){
			if( -e "rsnapshot-$version$file.$sig" ){
				print " [$visual.$sig](rsnapshot-$version$file.$sig)<br>";
			}
		}
	}
	
	print " |\n";
}

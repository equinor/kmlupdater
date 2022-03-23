#!/usr/bin/perl

# Changed 25.02.2022 : Changed rel_path function

#
use Cwd;
use File::Spec;

my $entry = shift;
my $split_at = getcwd();

my $dir = splitPathAt("webdocs");			# replace with webdocs
my $server = "earth.equinor.com";		# server part of href string

my $stdout ='';
if (not -d $entry) {exit 0;}
my $wdir =  getcwd();

sub rel_path($){
	my $path = shift;
	return File::Spec->abs2rel ($path,  $split_at);
}
sub iskml($){
	my $filename = shift;
	my @fsplit = split(/\./,$filename);
	my $ext = lc($fsplit[1]);
	if ($ext eq "kml") {return 1; } else {if ($ext eq "kmz"){return 1;} else {return 0;}}
}
sub splitPathAt ($) {
	my $split_at = shift;
	my $dir = getcwd();
	my @dirsplit = split(/$split_at/,$dir);
	$dir= $dirsplit[1];
	return $dir;
}

sub cData($){
my $in = shift;
my $out = '<![CDATA[' . $in . ']]>';
return $out;
}
sub is_empty_folder($){
	my $folder = shift;
	my @entries = sort {uc($a) cmp uc($b)} <*>;
	my @files = sort {uc($a) cmp uc($b)} <*.km[l,z]>;
	my @folders = ();
	foreach  $fol (@entries) {
		if (-d $fol) {
			push (@folders,$fol);
		}
	} 
	if ($folders[0]) {
		return 0;
	} else {
		if ($files[0]) 
		{
			return 0;
		}
	return 1;
	}
}
sub validate($){
	my $in = shift;
	my $out = '';
	if (index($in, 'NetworkLink') != -1) {
		$out .= $in;
	}
	return $out;	
}

sub do_entry($){
	my $entry = shift;
	my $out = '';
	my $dirdout = '';
	my $fileout = '';
	my $wdir =  getcwd();
	my $reldir = rel_path(getcwd());
	chdir($entry);
	my @entries = sort {uc($a) cmp uc($b)} <*>;
	#foreach $entry (@entries) {print "$entry\n";}
	foreach $entry (@entries) {
		if (-f $entry){
			if (iskml($entry) == 1){
				my $subname = cData($entry);
				my $subDirname = cData("$reldir/$entry");
				$fileout .= "<NetworkLink>\n\t<visibility>0</visibility>\n\t\t<name>$subname</name>\n\t<Link>\n\t\t<href>$subDirname</href>\n\t</Link>\n\</NetworkLink>";}
		} else {
			if (-d $entry){
				chdir("$wdir/$entry");	
				if (is_empty_folder($entry)) {chdir($wdir);next;}
				my $subname = cData($entry);
				$dirout .=  "<Folder>\n\t<name>$subname</name>\n\t<visibility>0</visibility>\n\t<open>0</open>\n";
				$dirout = do_entry($entry);
				$dirout .=  "$stdout\n";
				$dirout .=  "</Folder>\n";
				$dirout = validate($dirout);
				chdir($wdir);
			}
		}
	}
	$out .= $dirout . $fileout;
	$out = validate($out);
	return $out;
}
# do_entry

sub iskml($){
	my $filename = shift;
	my @fsplit = split(/\./,$filename);
	my $ext = lc($fsplit[1]);
	if ($ext eq "kml") {return 1; } else {if ($ext eq "kmz"){return 1;} else {return 0;}}
}
sub doName ($) {
	my $in = shift;
	my $out = "";
	my @tmp = split(</>,$in);
	foreach $el  (@tmp) {
		$out = $el;
	}
	return $out;
}

sub contentType {
	return "Content-type: application/vnd.google-earth.kml+xml\n\n";
}

sub kmlComment($){
	my $comment = shift;
	return "<!-- " . $comment . " -->";
}

sub kmlHeader ($) {
	my $name = shift;
	#my $subname = doName($name);
	my $subname = $name;
	my $comment = "Dynamicly created kml index";
	my $kmlcomment = kmlComment($comment);
	return <<KML_HEADER;
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
$kmlcomment
<Document>
	<visibility>0</visibility>
	<snippet></snippet>
	<description><![CDATA[<p>$comment</p>
	<h3>http://$server$name</h3>]]></description>
	<name>$subname</name>
KML_HEADER
}
sub kmlFooter ($) {
	my $nam = shift;
	$nam = kmlComment($nam);
	return <<KML_FOOTER;
</Document> $nam
</kml> 
KML_FOOTER
}


# main 
my $kml = '';
chdir($entry);
#print contentType;
$kml .= kmlHeader ($entry);
$kml .= do_entry($entry);
$kml .= kmlFooter ($entry); 
chdir($wdir);
$kml = validate($kml);
print $kml;
exit 0;

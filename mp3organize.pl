#!/usr/bin/perl -w

use Tk;
use Encode;
use Tk::PNG;
use MP3::Tag;
use File::Copy;

my $albumCBV = 0;
my $artistCBV = 0;
my $yearCBV = 0;
my $imagePath = "images/None.png";
my $trackNumNameCBV = 1;
my $artistNameCBV = 0;
my $albumNameCBV = 0;
my $trackNameCBV = 1;
my $clearCommentCBV = 0;

my $mw = new MainWindow(-height => 690, -width => 700 ); #Creates an instance of the window that will contain the widgets
my $mainLabel = $mw -> Label(-text => "Welcome to mp3organize! Use the options below to configure your folder structure, then apply.") -> place(-x => 350, -y => 0, -anchor => 'n');

my $chooseDirLabel = $mw -> Label(-text => "Please choose the directory containing the files:") -> place(-x => 350, -y => 24, -anchor => 'n');
my $directoryButton = $mw -> Button(-text => "Select Directory",
        -command => sub { $workingDir = $mw->chooseDirectory; #The subroutine for the directory selection button: Open a folder slection dialog
	$die = encode('UTF-8', $workingDir) })
	-> place(-x => 350, -y => 52, -anchor => 'n');

my $currentImage = $mw -> Photo(-file => $imagePath);

my $folderSchemeLabel = $mw -> Label(-text => "Folder Scheme:") -> place(-x => 0, -y => 98, -anchor => 'w');
my $artistFolderToggle = $mw -> Checkbutton(-text => 'Create Artist Folder?', -onvalue => '1', 
	-offvalue => '0', -variable => \$artistCBV, -command => sub {&updateImage;}) -> place(-x => 0, -y => 122, -anchor => 'w');
my $yearFolderToggle = $mw -> Checkbutton(-text => 'Create Year Folder?', -onvalue => '1',
        -offvalue => '0', -variable => \$yearCBV, -state => 'disabled', -command => sub { &updateImage();}) -> place(-x => 0, -y => 146, -anchor => 'w');
my $albumFolderToggle = $mw -> Checkbutton(-text => 'Create Album Folder?', -onvalue => '1',
	-offvalue => '0', -variable => \$albumCBV, -command => sub { &updateImage();}) -> place(-x => 0, -y => 170, -anchor => 'w');


my $separatorLabel = $mw -> Label(-text => "___________________________") -> place(-x => 0, -y => 188, -anchor => 'w');
my $nameSchemeLabel = $mw -> Label(-text => "File Naming Scheme:") -> place(-x => 0, -y => 212, -anchor => 'w');
my $TrackNumNameToggle = $mw -> Checkbutton(-text => 'Include Track Number?', -onvalue => '1',
        -offvalue => '0', -variable => \$trackNumNameCBV) -> place(-x => 0, -y => 236, -anchor => 'w');
my $artistNameToggle = $mw -> Checkbutton(-text => 'Include Artist Name?', -onvalue => '1',
        -offvalue => '0', -variable => \$artistNameCBV) -> place(-x => 0, -y => 260, -anchor => 'w');
my $albumNameToggle = $mw -> Checkbutton(-text => 'Include Album Name?', -onvalue => '1',
        -offvalue => '0', -variable => \$albumNameCBV) -> place(-x => 0, -y => 284, -anchor => 'w');
my $trackNameToggle = $mw -> Checkbutton(-text => 'Include Track Name?', -onvalue => '1',
        -offvalue => '0', -variable => \$trackNameCBV) -> place(-x => 0, -y => 308, -anchor => 'w');

my $separatorLabel2 = $mw -> Label(-text => "___________________________")
	-> place(-x => 0, -y => 326, -anchor => 'w');
my $otherLabel = $mw -> Label(-text => "Other Options:") -> place(-x => 0, -y => 350, -anchor => 'w');
my $clearCommentToggle = $mw -> Checkbutton(-text => 'Clear Comment Tag?', -onvalue => '1',
        -offvalue => '0', -variable => \$clearCommentCBV) -> place(-x => 0, -y => 374, -anchor => 'w');


my $fileSepLabel= $mw -> Label(-text => "Filename field separator:")
 -> place(-x => 0, -y => 400, -anchor => 'w');

my $tvar = "dropdownItems";
my $spacerType;
my $opt = $mw->Optionmenu(
	-options => [["Dashes w/ Spaces"=> " - "], ["Dashes"=> "-"], ["Periods"=>"."], ["Spaces"=>" "]], 
	-variable => \$spacerType,
	-textvariable => \$tvar)
	-> place(-x => 4, -y => 428,  -anchor => 'w');

my $separatorLabel3 = $mw -> Label(-text => "___________________________")
	-> place(-x => 0, -y => 460, -anchor => 'w');

my $exampleImage = $mw -> Label(-image => $currentImage) -> place(-x => 194, -y => 92);
my $refreshButton = $mw -> Button(-text => "Refresh", -command => sub { $currentImage -> configure(-file => $imagePath);
	if ($artistCBV == 0 and $albumCBV == 0){
		$yearFolderToggle -> deselect;
		$yearFolderToggle -> configure(-state => 'disabled');
	}
	else {
		$yearFolderToggle -> configure(-state => 'normal');
	}
 }) -> place(-x => 56, -y => 500, -anchor => 'w');

my $processButton = $mw -> Button(-text => "PROCESS!", -command => sub { &process($die) }) -> place(-x => 92, -y => 548, -anchor => 's');


my $exitButton = $mw -> Button(-text => "Quit", -command => sub { exit }) -> place(-x => 350, -y => 664, -anchor => 's');

MainLoop;

sub updateImage {
        if ($albumCBV == 1){
                if($artistCBV == 1){
                        if($yearCBV == 1){
                                $imagePath = "images/ArYrAl.png";
                        }
                        else {
                                $imagePath = "images/ArAl.png";
                        }
                }
                elsif ($yearCBV == 1) {
                        $imagePath = "images/YrAl.png";
                }
                else {
                        $imagePath = "images/Al.png"
                }
        }
        elsif($artistCBV == 1){
                if($yearCBV == 1){
                        $imagePath = "images/YrAr.png";
                }
                else {
                        $imagePath = "images/Ar.png";
                }
        }
        else {
                $imagePath = "images/None.png";
        }
}

sub process {
	my $workDir = $_[0];
	opendir(DIR, $workDir) or die "Could not open folder\n";
	my @files = glob "$workDir/*.mp3";
	closedir(DIR);
	foreach $key (@files){
		$mp3 = MP3::Tag->new($key); # create object 

		$mp3->get_tags(); # read tags

		if (exists $mp3->{ID3v2}) { # print track information
			my $artist = $mp3->{ID3v2}->artist;
			my $album = $mp3->{ID3v2}->album;
			my $year = $mp3->{ID3v2}->year;
			my $title = $mp3->{ID3v2}->title;
			my $trackno = $mp3->{ID3v2}->track;

			if (($trackno < 10)&&!(substr($trackno, 0, 1) == "0")){
				$trackno = "0" . "$trackno";
			}

			my $newFile = "";

			if ($artistNameCBV == 1){
				$newFile .= "$artist";
			}
			if ($albumNameCBV == 1){
				if ($artistNameCBV == 1){
					$newFile .= "$spacerType";
				}
				$newFile .= "$album";
			}
			if ($trackNumNameCBV == 1){
				if (($artistNameCBV == 1) || ($albumNameCBV == 1)){
					$newFile .= "$spacerType";
				}
				$newFile .= "$trackno";
			}
			if ($trackNameCBV == 1){
				if (($artistNameCBV == 1) || ($albumNameCBV == 1) || ($trackNumNameCBV == 1)){
					$newFile .= "$spacerType";
				}
				$newFile .= "$title";
			}
			$newFile .= ".mp3";

			if (!(-d "$artist")&&($artistCBV == 1)){
				mkdir "$workDir" . "/" . "$artist";
				if (!(-d "$year")&&($yearCBV == 1)){
					mkdir "$workDir" . "/" . "$artist" . "/" . "$year";
					if (!(-d "$album")&&($albumCBV == 1)){
						mkdir "$workDir" . "/" . "$artist" . "/" . "$year" . "/" . "$album";
					}
				}
				if (!(-d "$album")&&($albumCBV == 1)&&!($yearCBV == 1 )){
					 mkdir "$workDir" . "/" . "$artist" . "/" . "$album";
				}
			} 

			if (($artistCBV == 1)&&($yearCBV == 0)&&($albumCBV == 0)){
				move("$key" ,"$workDir" . "/" . "$artist" . "/" . "$newFile");
			}
			if (($artistCBV == 1)&&($yearCBV == 1)&&($albumCBV == 0)){
				move("$key" ,"$workDir" . "/" . "$artist" . "/" . "$year" . "/" . "$newFile");
			}
			if (($artistCBV == 1)&&($yearCBV == 1)&&($albumCBV == 1)){
				move("$key" ,"$workDir" . "/" . "$artist" . "/" . "$year" . "/" . "$album" . "/" . "$newFile");
			}
			if (($artistCBV == 0)&&($yearCBV == 1)&&($albumCBV == 1)){
				move("$key" ,"$workDir" . "/" . "$year" . "/" . "$album" . "/" . "$newFile");
			}
			if (($artistCBV == 1)&&($yearCBV == 0)&&($albumCBV == 1)){
				move("$key" ,"$workDir" . "/" . "$artist" . "/" . "$album" . "/" . "$newFile");
			}

			print "Filename: $key - PROCESSED!\n";
		}
		elsif (!(exists $mp3->{ID3v2}) || !(exists $mp3->{ID3v1})){
			$unsortedFolder = "$workDir" . "/" . "unsorted";
			if (!(-d "$unsortedFolder")){
				mkdir ("$workDir" . "/" . "unsorted");
				move("$key" ,"$workDir" . "/" . "unsorted");
			}
			move("$key" ,"$workDir" . "/" . "unsorted");
			print "$key has no tags! - MOVED TO UNSORTED FOLDER!";
		}
	}
}

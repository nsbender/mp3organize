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

#Create the main Tk window that will hold the 'widgets' and write some welcome text at the top
my $mw = new MainWindow(-height => 690, -width => 700 );
my $mainLabel = $mw -> Label(-text => "Welcome to mp3organize! Use the options below to configure your folder structure, then apply.") -> place(-x => 350, -y => 0, -anchor => 'n');

my $chooseDirLabel = $mw -> Label(-text => "Please choose the directory containing the files:") -> place(-x => 350, -y => 24, -anchor => 'n');

#Create a button that executes a routine that opens a system dialog to chose a working directory
my $directoryButton = $mw -> Button(-text => "Select Directory",
        -command => sub { $workingDir = $mw->chooseDirectory;
	$die = encode('UTF-8', $workingDir) })
	-> place(-x => 350, -y => 52, -anchor => 'n');

#Create the instance that will contain the sample folder image at the specified path
my $currentImage = $mw -> Photo(-file => $imagePath);

#Create the label above the folder structure check boxes that identifies them as such
my $folderSchemeLabel = $mw -> Label(-text => "Folder Scheme:") -> place(-x => 0, -y => 98, -anchor => 'w');

#Create the check boxes that allow the user to create a folder structure
my $artistFolderToggle = $mw -> Checkbutton(-text => 'Create Artist Folder?', -onvalue => '1', 
	-offvalue => '0', -variable => \$artistCBV, -command => sub {&updateImage;}) -> place(-x => 0, -y => 122, -anchor => 'w');
my $yearFolderToggle = $mw -> Checkbutton(-text => 'Create Year Folder?', -onvalue => '1',
        -offvalue => '0', -variable => \$yearCBV, -state => 'disabled', -command => sub { &updateImage();}) -> place(-x => 0, -y => 146, -anchor => 'w');
my $albumFolderToggle = $mw -> Checkbutton(-text => 'Create Album Folder?', -onvalue => '1',
	-offvalue => '0', -variable => \$albumCBV, -command => sub { &updateImage();}) -> place(-x => 0, -y => 170, -anchor => 'w');

#Print a separator between the sections of the menu for neatness
my $separatorLabel = $mw -> Label(-text => "___________________________") -> place(-x => 0, -y => 188, -anchor => 'w');


my $nameSchemeLabel = $mw -> Label(-text => "File Naming Scheme:") -> place(-x => 0, -y => 212, -anchor => 'w');

#Create the checkboxes that allow the user to specify the track info they would like included in the filename
my $TrackNumNameToggle = $mw -> Checkbutton(-text => 'Include Track Number?', -onvalue => '1',
        -offvalue => '0', -variable => \$trackNumNameCBV) -> place(-x => 0, -y => 236, -anchor => 'w');
my $artistNameToggle = $mw -> Checkbutton(-text => 'Include Artist Name?', -onvalue => '1',
        -offvalue => '0', -variable => \$artistNameCBV) -> place(-x => 0, -y => 260, -anchor => 'w');
my $albumNameToggle = $mw -> Checkbutton(-text => 'Include Album Name?', -onvalue => '1',
        -offvalue => '0', -variable => \$albumNameCBV) -> place(-x => 0, -y => 284, -anchor => 'w');
my $trackNameToggle = $mw -> Checkbutton(-text => 'Include Track Name?', -onvalue => '1',
        -offvalue => '0', -variable => \$trackNameCBV) -> place(-x => 0, -y => 308, -anchor => 'w');

#Another separator label
my $separatorLabel2 = $mw -> Label(-text => "___________________________")
	-> place(-x => 0, -y => 326, -anchor => 'w');

#Create a section for the other options
my $otherLabel = $mw -> Label(-text => "Other Options:") -> place(-x => 0, -y => 350, -anchor => 'w');

#The checkbox for the option to remove the pesky comment tag that is occasionally in mp3 tags. NOT IMPLEMENTED YET
my $clearCommentToggle = $mw -> Checkbutton(-text => 'Clear Comment Tag?', -onvalue => '1',
        -offvalue => '0', -variable => \$clearCommentCBV) -> place(-x => 0, -y => 374, -anchor => 'w');

#Create the label and dropdown box that allows the user to select the separator they would like used
# in the filenames between the fields they selected in the above section
my $fileSepLabel= $mw -> Label(-text => "Filename field separator:")
 -> place(-x => 0, -y => 400, -anchor => 'w');
my $tvar = "dropdownItems";
my $spacerType;
my $opt = $mw->Optionmenu(
	-options => [["Dashes w/ Spaces"=> " - "], ["Dashes"=> "-"], ["Periods"=>"."], ["Spaces"=>" "]], 
	-variable => \$spacerType,
	-textvariable => \$tvar)
	-> place(-x => 4, -y => 428,  -anchor => 'w');

#Another separator label
my $separatorLabel3 = $mw -> Label(-text => "___________________________")
	-> place(-x => 0, -y => 460, -anchor => 'w');

#Display a sample image of what the folder will look like after processing based on the users options.
#DOES NOT REFLECT FILE NAMING SCHEME, ONLY FOLDER STRUCTURE
my $exampleImage = $mw -> Label(-image => $currentImage) -> place(-x => 194, -y => 92);

#The image doesn't update automatically, a subprogram needs to be called to select the correct photo and re-load it
# based on the settings
my $refreshButton = $mw -> Button(-text => "Refresh", -command => sub { $currentImage -> configure(-file => $imagePath);
	#If neither Artist or Album folder checkboxes are checked, the year checkbox is greyed out.
	#Sorting files only by year is counter-intuitive and not a good feature
	if ($artistCBV == 0 and $albumCBV == 0){
		$yearFolderToggle -> deselect;
		$yearFolderToggle -> configure(-state => 'disabled');
	}
	else {
		$yearFolderToggle -> configure(-state => 'normal');
	}
 }) -> place(-x => 56, -y => 500, -anchor => 'w');

#Create a process button near the bottom of the window. It calls the 'process' subprogram.
my $processButton = $mw -> Button(-text => "PROCESS!", -command => sub { &process($die) }) -> place(-x => 92, -y => 548, -anchor => 's');

#Create an exit button that breaks the main window loop and the whole script.
my $exitButton = $mw -> Button(-text => "Quit", -command => sub { exit }) -> place(-x => 350, -y => 664, -anchor => 's');

MainLoop;

#The subroutine that examines the users settings and chooes the approprite sample image and sets the
# current image path to point to it.
#This will eventually be changed to avoid the 'if-then pyramids'
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

#The subroutine to process the files
sub process {
	#Load the current working directory
	my $workDir = $_[0];
	opendir(DIR, $workDir) or die "Could not open folder\n";
	
	#Create an array of all of the files in the directory
	my @files = glob "$workDir/*.mp3";
	closedir(DIR);
	foreach $key (@files){
		#Create a new 'Tag' object to hold the MP3 info
		$mp3 = MP3::Tag->new($key);
		#Get the tags from the current file into the tag object
		$mp3->get_tags();

		if (exists $mp3->{ID3v2}) {
			#Store all of the fields in separate variables
			my $artist = $mp3->{ID3v2}->artist;
			my $album = $mp3->{ID3v2}->album;
			my $year = $mp3->{ID3v2}->year;
			my $title = $mp3->{ID3v2}->title;
			my $trackno = $mp3->{ID3v2}->track;

			#Append a 0 to track numbers that are only a single digit
			#This is the norm and looks more consistent.
			if (($trackno < 10)&&!(substr($trackno, 0, 1) == "0")){
				$trackno = "0" . "$trackno";
			}

			#Create the variable for the modified filename
			my $newFile = "";

			#The following if statements append the information to the filename
			# if the user has specified
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
			#Append the extension to the filename. Forgetting this is detrimental.
			$newFile .= ".mp3";

			#Another 'if-then' tree to create the new folder structure based on selected settings
			# 	"If artist is selected, then create an artist folder..." and so on.
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

			#Move the new file to the new directories based on settings
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

			#Output to the terminal that the current track in the array was processed correctly
			print "Filename: $key - PROCESSED!\n";
		}

		#If the file has no tags, create a folder in the working directory called "unsorted"
		# and move the tagless file there
		elsif (!(exists $mp3->{ID3v2}) || !(exists $mp3->{ID3v1})){
			$unsortedFolder = "$workDir" . "/" . "unsorted";
			if (!(-d "$unsortedFolder")){
				mkdir ("$workDir" . "/" . "unsorted");
				move("$key" ,"$workDir" . "/" . "unsorted");
			}
			move("$key" ,"$workDir" . "/" . "unsorted");
			#Output to the terminal that there was a failure.
			print "$key has no tags! - MOVED TO UNSORTED FOLDER!";
		}
	}
}

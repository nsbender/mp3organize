#!/usr/bin/perl -w

use Tk;
use Encode;
use Tk::PNG;

my $albumCBV = 0;
my $artistCBV = 0;
my $yearCBV = 0;
my $imagePath = "None.png";

sub updateImage {
        if ($albumCBV == 1){
                if($artistCBV == 1){
                        if($yearCBV == 1){
                                $imagePath = "ArYrAl.png";
                        }
                        else {
                                $imagePath = "ArAl.png";
                        }
                }
                elsif ($yearCBV == 1) {
                        $imagePath = "YrAl.png";
                }
		else {
			$imagePath = "Al.png"
		}
        }
        elsif($artistCBV == 1){
                if($yearCBV == 1){
                        $imagePath = "YrAr.png";
                }
                else {
                        $imagePath = "Ar.png";
                }
        }
	else {
		$imagePath = "None.png";
	}
}

my $mw = new MainWindow; #Creates an instance of the window that will contain the widgets

my $mainLabel = $mw -> Label(-text => "Welcome to mp3organize! Use the options below to configure your folder structure, then apply.") -> pack();

my $chooseDirLabel = $mw -> Label(-text => "Please choose the directory containing the files:") -> pack();
my $directoryButton = $mw -> Button(-text => "Select Directory",
        -command => sub { my $workingDir = $mw->chooseDirectory; #The subroutine for the directory selection button: Open a folder slection dialog
	$die = encode("windows-1252", $workingDir) })
	-> pack();

my $currentImage = $mw -> Photo(-file => $imagePath);

my $artistFolderToggle = $mw -> Checkbutton(-text => 'Create Artist Folder?', -onvalue => '1', 
	-offvalue => '0', -variable => \$artistCBV, -command => sub {&updateImage;}) -> pack(-anchor => 'nw');
my $yearFolderToggle = $mw -> Checkbutton(-text => 'Create Year Folder?', -onvalue => '1',
        -offvalue => '0', -variable => \$yearCBV, -state => 'disabled', -command => sub { &updateImage();}) -> pack(-anchor => 'nw');
my $albumFolderToggle = $mw -> Checkbutton(-text => 'Create Album Folder?', -onvalue => '1',
	-offvalue => '0', -variable => \$albumCBV, -command => sub { &updateImage();})-> pack(-anchor => 'nw');

my $seperatorLabel = $mw -> Label(-text => "___________________________") -> pack(-anchor => 'w');

my $exampleImage = $mw -> Label(-image => $currentImage) -> pack(-anchor => 'e');
my $refreshButton = $mw -> Button(-text => "Refresh", -command => sub { $currentImage -> configure(-file => $imagePath);
	if ($artistCBV == 0 and $albumCBV == 0){
		$yearFolderToggle -> deselect;
		$yearFolderToggle -> configure(-state => 'disabled');
	}
	else {
		$yearFolderToggle -> configure(-state => 'normal');
	}
 }) -> pack(-anchor => 's');

my $exitButton = $mw -> Button(-text => "Quit", -command => sub { exit }) -> pack(-anchor => 's');
my $c = $mw -> Canvas(-width => 700, -height => 480); #Set the window size of mw
$c -> pack;

MainLoop;

#!/usr/bin/perl

use Tk;
use Encode;
use Tk::PNG;

my $mw = new MainWindow; #Creates an instance of the window that will contain the widgets
my $mainLabel = $mw -> Label(-text => "Welcome to mp3organize! Use the options below to configure your folder structure, then apply.") -> pack();

my $chooseDirLabel = $mw -> Label(-text => "Please choose the directory containing the files:") -> pack();
my $directoryButton = $mw -> Button(-text => "Select Directory",
        -command => sub { my $workingDir = $mw->chooseDirectory; #The subroutine for the directory selection button: Open a folder slection dialog
	$die = encode("windows-1252", $dir) })
	-> pack();

my $albumCBValue = '0';
my $artistCBValue = 0;

my $artistFolderToggle = $mw -> Checkbutton(-text => 'Create Artist Folder?', -onvalue => '1', 
	-offvalue => '0', -command => \&updateImage) -> pack(-anchor => 'nw');
my $yearFolderToggle = $mw -> Checkbutton(-text => 'Create Year Folder?', -onvalue => '1',
        -offvalue => '0', -command => \&updateImage) -> pack(-anchor => 'nw');
my $albumFolderToggle = $mw -> Checkbutton(-text => 'Create Album Folder?', -onvalue => '1',
	-offvalue => '0', -variable => \$albumCBValue, -command => \&updateImage) -> pack(-anchor => 'nw');

my $seperatorLabel = $mw -> Label(-text => "___________________________") -> pack(-anchor => 'w');

my $imageAl = $mw -> Photo(-file => "Al.png");
#$imageAr = $mw -> Photo(-file => "Ar.png");
#$imageArYr = $mw -> Photo(-file => "ArYr.png");
#$imageArYrAl = $mw -> Photo(-file => "ArYrAl.png");
#$imageArAl = $mw -> Photo(-file => "ArAl.png");
#$imageYrAl = $mw -> Photo(-file => "YrAl.png");

my $currentImage = ''
my $exampleImage = $mw -> Label(-image => $currentImage) -> pack(-anchor => 'ne');



my $c = $mw -> Canvas(-width => 700, -height => 480); #Set the window size of mw
        $c -> pack;

my $exitButton = $mw -> Button(-text => "Quit",
        -command => sub { exit })
        -> pack();

MainLoop;

sub updateImage {
	if ($albumCBValue == '1'){$currentImage = $imageAl);}
}

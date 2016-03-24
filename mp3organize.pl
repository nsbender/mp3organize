#!/usr/bin/perl

use Tk;
use Encode;

my $mw = new MainWindow; #Creates an instance of the window that will contain the widgets
my $label = $mw -> Label(-text=>"Hello World") -> pack();

my $exitButton = $mw -> Button(-text => "Quit", 
        -command => sub { exit })
    -> pack();

my $chooseDirLabel = $mw -> Label(-text=>"Please choose the directory containing the files:") -> pack();
my $directoryButton = $mw -> Button(-text => "Select Directory",
        -command => sub { my $dir = $mw->chooseDirectory;
		$die = encode("windows-1252", $dir) })
    -> pack();


MainLoop;

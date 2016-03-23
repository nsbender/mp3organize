#!/usr/bin/perl

use Tk;
my $mw = new MainWindow; #Creates an instance of the window that will contain the widgets
my $label = $mw -> Label(-text=>"Hello World") -> pack();
my $button = $mw -> Button(-text => "Quit", 
        -command => sub { exit })
    -> pack();
MainLoop;

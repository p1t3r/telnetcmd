#!/usr/bin/perl
use v5.20;
use strict;
use warnings;
use diagnostics;
use Net::Telnet ();
use Getopt::Long qw(GetOptions);
Getopt::Long::Configure ('bundling');


        ######################################################
        #           		                             #
        # Login to a remote host & execute a defined command #
        #                       	                     #
        ######################################################


### Variables
my $user;
my $pass;
my $host;
my $cmd;					# Stores command to execute on a remote host
my $telnet = new Net::Telnet (Timeout=>360);	# Sets the timeout (if command execution lasts too long the command will be automatically aborted)
my @output;					# Stores command output from the remote host
my $outfile;					# File to command output will be written
my $prompt = 0;					# Asks what to do next

# Subroutine "usage" - prints instructions
sub usage_sub {
        return "\nUsage:\t$0 -f filename\n\n";
}

# Subroutine "exec_sub" - execute main code
sub exec_sub {
	# Opens telnet connection to host
	$telnet->open($host);

	# Login on the host
	$telnet->login($user, $pass);

	# Execute a command on remote host and writes the output into array
	@output = $telnet->cmd($cmd);

	# Opens file to write in addition mode
	open (FILE, ">> $outfile") || die "Can't open file $outfile\n";

	# Writes the content of the array into file
	print FILE @output;
	print FILE "\n\n";

	# Closes file handle
	close(FILE);

	print "Bye!\n";

	# Closes telnet session
	$telnet->prompt("//");
	$telnet->cmd("exit");
	$telnet->close();
}

# Get options from command line and assign them to each variable
GetOptions(
        'f=s' => \$outfile
) || die print &usage_sub;

# Test if all options were passed to the script
if (defined $outfile) {
	# Asks for login data
	print "Host: ";
	chomp($host = <STDIN>);
	print "Login: ";
	chomp($user = <STDIN>);
	print "Password: ";
	system("stty -echo");
	chomp($pass = <STDIN>);
	system("stty echo");
	print "\n";

	# Asks for command to execute
	print "What command should I execute? ";
	chomp($cmd = <STDIN>);
	
	# Call &exec_sub
	&exec_sub;

} else {
       	print &usage_sub;
}

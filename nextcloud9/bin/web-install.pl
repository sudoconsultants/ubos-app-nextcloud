#!/usr/bin/perl
#
# Access the NextCloud installation for the first time.
#

use strict;

use UBOS::Logging;
use UBOS::Utils;
use POSIX;

my $dir         = $config->getResolve( 'appconfig.apache2.dir' );
my $datadir     = $config->getResolve( 'appconfig.datadir' ) . '/data';
my $apacheUname = $config->getResolve( 'apache2.uname' );
my $apacheGname = $config->getResolve( 'apache2.gname' );
my $hostname    = $config->getResolve( 'site.hostname' );

if( 'install' eq $operation ) {
    # now we need to hit the installation ourselves, otherwise the first user gets admin access
    my $out;
    my $err;

    my $cmd = "cd '$dir';";
    $cmd .= "sudo -u '$apacheUname' php";
    $cmd .= " -d 'open_basedir=$dir:/tmp/:/usr/share/:$datadir'";
    $cmd .= ' -d always_populate_raw_post_data=-1';
    $cmd .= ' index.php';

    if( UBOS::Utils::myexec( $cmd, undef, \$out, \$err ) != 0 ) {
        error( "Activating NextCloud in $dir failed: out: $out\nerr: $err" );
    }

    # now replace 'localhost' in the 'trusted_domains' section of the
    # generated config.php with the actual site hostname
    my $configFile = "$dir/config/config.php";
    if( -e $configFile ) {
        my $configContent = UBOS::Utils::slurpFile( $configFile );

        $configContent =~ s!(\d+\s*=>\s*)'localhost'!$1'$hostname'!;

        UBOS::Utils::saveFile( $configFile, $configContent, 0640, $apacheUname, $apacheGname );
    }
}

1;

#!/usr/bin/perl
#
# Configure fulltextsearch
#
# Copyright (C) 2016 and later, Indie Computing Corp. All rights reserved. License: see package.
#

use strict;

use UBOS::Logging;
use UBOS::Utils;

my $dir = $config->getResolve( 'appconfig.apache2.dir' );

my $cmdPrefix = "cd $dir; sudo -u http php";
$cmdPrefix .= ' -d memory_limit=512M';
$cmdPrefix .= ' occ';

my $out;

if( 'install' eq $operation || 'upgrade' eq $operation ) {

    my $json = <<JSON;
{
    "files_local": "1",
    "files_external": "0",
    "files_group_folders": "1",
    "files_size": "20",
    "files_pdf": "1",
    "files_office": "1"
}
JSON
    # local: yes
    # external: index path only
    # group folders: yes
    # size: up to 20MB
    # extract PDF and Office files

    if( UBOS::Utils::myexec( "$cmdPrefix files_fulltextsearch:configure '$json'", undef, \$out, \$out ) != 0 ) {
        error( "Configuring Nextcloud app files_fulltextsearch failed:", $out );
    }
}

1;

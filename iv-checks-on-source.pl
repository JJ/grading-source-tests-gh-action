#!/usr/bin/env perl

use strict;
use warnings;
use v5.14;

use Git;
use GitHub::Actions;

use File::Slurper qw(read_text);
use YAML qw(LoadFile);

use lib "lib";

use Utility;
use Objetivos;

my $fase = $ENV{'objetivo'};
my $config_file = $ENV{'CONFIGFILE'};

# Comenzando
groupify( sub { say "Objetivo $fase" }, "Metadatos" )->();

# Previa
my $student_repo = Git->repository ( Directory => "." );

# Algunas variables previas al objetivo 0
my @repo_files = $student_repo->command("ls-files");
my $README = pre_objetivo_0(\@repo_files);

objetivo_0(\@repo_files, $README);

exit_action() if $fase <= 1;

# Fase 2
my $iv;

my $file = "$config_file.yaml";
file_present( $file, \@repo_files, "Fichero metadatos" );
eval { $iv = LoadFile($file); };
if ($@) {
  set_failed( sorry( "Hay algún problema leyendo «$file» ⤷ $@" ) );
} else {
  say all_good( "Fichero de configuración ⚙ «$file» encontrado" );
}
$iv->{'CONFIGFILE'} = $file;

objetivo_2( $iv, \@repo_files );

exit_action() if $fase < 3;

objetivo_3( $iv, $README, \@repo_files );

exit_action() if $fase < 4;

objetivo_4( $iv, $README, \@repo_files );

exit_action() if $fase < 5;

if ( -f "DOCKER_USER" ) {
  say "❢ Usuario de Docker alternativo";
  open( my $fh, "<", "DOCKER_USER" ) || die "No puedo abrir DOCKER_USER";
  my $docker_user = <$fh>;
  chomp $docker_user;
  set_env( 'docker_user', $docker_user );
} else {
  set_env( 'docker_user', $ENV{'user'} );
}

objetivo_5( $iv,  \@repo_files );

exit_action() if $fase < 6;

objetivo_6( $iv,  \@repo_files );

exit_action() if $fase < 7;

objetivo_7( $iv,  \@repo_files );

exit_action() if $fase < 8;

objetivo_8( $iv);

exit_action();


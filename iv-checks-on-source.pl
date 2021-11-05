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

# Fase
my ($fase) = $ENV{'objetivo'};
metadatos( $fase );

# Previa
my $student_repo = Git->repository ( Directory => "." );

# Algunas variables
my @repo_files = $student_repo->command("ls-files");

if ( -f "DOCKER_USER" ) {
  say "❢ Usuario de Docker alternativo";
  open( my $fh, "<", "DOCKER_USER" ) || die "No puedo abrir DOCKER_USER";
  my $docker_user = <$fh>;
  chomp $docker_user;
  set_output( 'DOCKER_USER', $docker_user );
}

objetivo_0(@repo_files);

exit if $fase <= 1;

# Fase 2
my ($readme_file) = grep( /^README/, @repo_files );
my $README =  read_text( $readme_file );
my $iv;

eval { $iv = LoadFile("iv.yaml"); };
if ($@) {
  set_failed( sorry( "Hay algún problema leyendo «iv.yaml» ⤷ $@" ) );
} else {
  say all_good( "Fichero de configuración ⚙ «iv.yaml» encontrado" );
}

objetivo_1( $iv, \@repo_files );

exit_action();

# Mensajes diversos
sub metadatos {
  my $fase = shift;
  doing( "Metadatos");
  say "Fase $fase";
  end_group();
}

# Objetivos
sub objetivo_0 {
  my @repo_files = @_;
  # Objetivo 0
  doing( "🎯 Objetivo 0" );
  for my $f (qw( README.md .gitignore LICENSE )) {
    if ( grep( $f, @repo_files) )  {
      say all_good( "🗄 $f presente" );
    } else {
      error( sorry( "Falta $f" ) );
    }
  }
  end_group();
}

sub objetivo_1 {
  doing( "🎯 Objetivo 1" );
  my $iv = shift;
  for my $k (qw(lenguaje entidad)) {
    comprueba( $iv->{$k},
               "🗝️ $k está presente",
               "🗝️ $k no está presente"
             );
  }

  my $repo_files = shift;
  file_present( $iv->{'entidad'}, $repo_files, "Con la entidad" );
  end_group();
}


# Funciones de utilidad
sub comprueba {
  my ( $expresion, $bien, $mal ) = @_;
  if ( $expresion ) {
    say all_good($bien);
  } else {
    error( sorry( $mal ) );
  }
}

sub file_present {
  my ($file, $ls_files_ref, $name ) = @_;
  my @files = (ref($file) eq 'ARRAY')?@$file:($file);
  for my $file (@files ) {
    comprueba( grep( /$file/, @$ls_files_ref ),
               "Fichero $name → $file presente",
               "Fichero $name → $file no está presente" );
  }

}

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
my ($fase) = $ARGV[0];
say "Fase $fase";

# Previa
my $student_repo = Git->repository ( Directory => "." );

# Algunas variables
my @repo_files = $student_repo->command("ls-files");

objetivo_0(@repo_files);

exit if $fase <= 2;

# Fase 2
my ($readme_file) = grep( /^README/, @repo_files );
my $README =  read_text( $readme_file );
my $iv;

eval { $iv = LoadFile("iv.yaml"); };
if ($@) {
  error( sorry( "Hay algún problema leyendo «iv.yaml» ⤷ $_" ) );
} else {
  say all_good( "Fichero de configuración ⚙ «iv.yaml» encontrado" );
}

objetivo_1( $iv, \@repo_files );


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
  my $iv = shift;
  for my $k (qw(lenguaje entidad)) {
    comprueba( $iv->{$k},
               "Clave $k está presente",
               "Clave $k no está presente"
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

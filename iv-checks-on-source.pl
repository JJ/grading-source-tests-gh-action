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
  set_output( 'docker_user', $docker_user );
  set_env( 'docker_user', $docker_user );
} else {
  set_output( 'docker_user', $ENV{'user'} );
  set_env( 'docker_user', $ENV{'user'} );
}

objetivo_0(@repo_files);

exit_action() if $fase <= 1;

# Fase 2
my ($readme_file) = grep( /^README/, @repo_files );
my $README =  read_text( $readme_file );
my $iv;

my $file = "is.yaml";
eval { $iv = LoadFile($file); };
if ($@) {
  set_failed( sorry( "Hay algún problema leyendo «$file» ⤷ $@" ) );
} else {
  say all_good( "Fichero de configuración ⚙ «$file» encontrado" );
}

objetivo_1( $iv, \@repo_files );

exit_action() if $fase < 3;

objetivo_3( $iv, $README, \@repo_files );

exit_action() if $fase < 4;

objetivo_4( $iv, $README, \@repo_files );

exit_action() if $fase < 5;

objetivo_5( $iv,  \@repo_files );

exit_action() if $fase < 6;

objetivo_6( $iv,  \@repo_files );

exit_action() if $fase < 7;

objetivo_7( $iv,  \@repo_files );

exit_action() if $fase < 8;

objetivo_8( $iv);

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
               "🗝️ $k está presente en «iv.yaml»",
               "🗝️ $k no está presente en «iv.yaml»"
             );
  }
  comprueba_caps( $iv->{'entidad'} );
  if ($iv->{'entidad'}) {
    my $repo_files = shift;
    file_present( $iv->{'entidad'}, $repo_files, "Con la entidad" );
  }
  end_group();
}

sub objetivo_3 {
  doing( "🎯 Objetivo 3" );
  my $iv = shift;
  my $README = shift;
  my $repo_files = shift;

  comprueba( $iv->{'automatizar'}, "🗝️ «automatizar» presente", "Falta clave «automatizar»" );
  comprueba( ref $iv->{'automatizar'} eq "HASH",
             "🗝️ «automatizar» es un diccionario",
             "La clave «automatizar» no contiene un diccionario, sino un " . ref $iv->{'automatizar'} );
  comprueba( $iv->{'automatizar'}{'fichero'}, "🗝️  «automatizar→fichero» presente", "Falta clave «automatizar→fichero»" );
  file_present( $iv->{'automatizar'}{'fichero'}, $repo_files, "Con el fichero de tareas" );
  comprueba( $iv->{'automatizar'}{'orden'}, "🗝️ «automatizar→orden» presente", "Falta clave «automatizar→orden»" );
  README_contiene( "$iv->{'automatizar'}{'orden'} check", $README );
  set_output( 'ORDEN', $iv->{'automatizar'}{'orden'} );
  set_env( 'ORDEN', $iv->{'automatizar'}{'orden'} );
  end_group();
}

sub objetivo_4 {
  doing( "🎯 Objetivo 4" );
  my $iv = shift;
  my $README = shift;
  my $repo_files = shift;

  clave_presente( 'test' );
  file_present( $iv->{'test'}, $repo_files, "Con un fichero de test" );
  comprueba_caps( $iv->{'test'} );
  README_contiene( "$iv->{'automatizar'}{'orden'} test", $README );
  end_group();
}

sub objetivo_5 {
  doing( "🎯 Objetivo 5" );
  my $iv = shift;
  my $repo_files = shift;
  file_present( 'Dockerfile', $repo_files, "Dockerfile" );
  end_group();
}

sub objetivo_6 {
  doing( "🎯 Objetivo 6" );
  my $iv = shift;
  my $repo_files = shift;
  clave_presente( 'CI' );
  file_present( $iv->{'CI'}, $repo_files, "Configuración CI" ) if $iv->{'CI'};
  comprueba_caps( $iv->{'CI'} );
  end_group();
}

sub objetivo_7 {
  doing( "🎯 Objetivo 7" );
  my $iv = shift;
  my $repo_files = shift;
  clave_presente( 'configuracion' );
  file_present( $iv->{'configuracion'}, $repo_files, "Configuración app" ) if $iv->{'configuracion'};
  my $gitignore =  read_text( ".gitignore" );
   if ( index( $gitignore, ".env" ) >= 0 ) {
    say all_good( ".gitignore evita los .env");
  } else {
    error (sorry( "⚠  .gitignore no evita los ficheros de configuración ⚠" ));
  }

  end_group();
}

sub objetivo_8 {
  doing( "🎯 Objetivo 8" );
  my $iv = shift;
  clave_presente( 'framework' );
  if ( $iv->{'framework'} !~ /(express|flask)/ ) {
    say all_good( "No has elegido ninguno de los frameworks «malditos»");
  } else {
    error (sorry( "⚠ ¿Te has pensado bien lo de elegir ".$iv->{'framework'}." como framework? ⚠" ));
  }

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

sub comprueba_caps {
  my $nombre_fichero = shift;
  my @files = (ref($nombre_fichero) eq 'ARRAY')?@$nombre_fichero:($nombre_fichero);
  for my $file (@files) {
    if ( $file =~ /[A-Z]/ ) {
      error (sorry( "⚠ «$file» tiene mayúsculas, no una buena práctica en repos ⚠" ));
    }
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

sub README_contiene {
  my ($cadena, $README) = @_;
  if ( index( $README, $cadena ) >= 0 ) {
    say all_good( "El README contiene «$cadena»");
  } else {
    error (sorry( "El README no contiene «$cadena»" ));
  }
}

sub clave_presente {
  my $clave = shift;
  comprueba( $iv->{$clave}, "🗝️ «$clave» presente", "Falta clave «$clave»" );
}

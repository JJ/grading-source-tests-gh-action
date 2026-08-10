use Test::More; # -*- mode: cperl -*-
use v5.36;
use strict;
use warnings;

use lib qw(lib ../lib);

use Objetivos;

use Test::Output;
use File::Slurper qw(read_text);

my @all_repo_files = qw( README.md .gitignore LICENSE configuración.png);

subtest "Funciones de utilidad" => sub {
  plan tests => 4;
  my $fake_readme_dir = "t/data";
  my $current_dir = `pwd`;
  chop( $current_dir );
  my @mock_repo_files = qw( README.md .gitignore LICENSE );
  my $fakeREADME=read_text("$fake_readme_dir/README.md");
  utf8::encode($fakeREADME);
  my $returnedREADME;

  stdout_like( sub {
    chdir($fake_readme_dir) || die "No encuentro el directorio";
    $returnedREADME = pre_objetivo_0( \@mock_repo_files );
    chdir( $current_dir ) || die "No puedo cambiarme al original $!";
  },
             qr/presente.+contenido/s,
             "Testeando comprobaciones" );

  is( $returnedREADME, $fakeREADME, "Se devuelve el contenido correctamente" );

  stdout_like( sub {
                 $fake_readme_dir = "t/data-empty-README";
                 chdir($fake_readme_dir) || die "No encuentro el directorio";
                 $returnedREADME = pre_objetivo_0( \@mock_repo_files );
                 chdir( $current_dir );
               },
             qr/no tiene nada/s,
               "Testeando comprobaciones con README vacío" );

  stdout_like( sub {
                 README_contiene_con_mensaje("configuración","# Configuración")
               },
               qr/El README contiene/s,
               "Testeando configuración independiente de las mayúsculas"
               );
};

subtest "Objetivo 0" => sub {
  plan tests => 6;
  my $fake_readme_dir = "t/data";
  my $current_dir = `pwd`;
  chop( $current_dir );
  my @mock_repo_files = @all_repo_files;
  my $fakeREADME=read_text("$fake_readme_dir/README.md");
  utf8::encode($fakeREADME);
  my $returnedREADME;
  chdir($fake_readme_dir) || die "No encuentro el directorio";

  stdout_like( sub {
    $returnedREADME = objetivo_0( \@mock_repo_files, $fakeREADME );
  },
             qr/presente.+presente.+configuración/s,
             "Testeando comprobaciones de contenido" );

  chdir( $current_dir ) || die "No puedo cambiarme al original $!";

  @mock_repo_files = qw( README.md LICENSE );
  stdout_like( sub {
    $returnedREADME = objetivo_0( \@mock_repo_files, $fakeREADME );
  },
                 qr/Falta .gitignore/s,
                 "Falta algún fichero" );

  @mock_repo_files = @all_repo_files;

  # Describir la solución en vez del problema es un error fatal, pero se
  # detecta por patrón (no por la simple presencia de la palabra
  # «aplicación», que puede aparecer de forma inocua en el texto).
  my $fakeREADME_solucion = $fakeREADME . " Quiero hacer una aplicación web para esto.";
  stdout_like( sub {
    $returnedREADME = objetivo_0( \@mock_repo_files, $fakeREADME_solucion );
  },
               qr/solución técnica/s,
               "Describir la solución en vez del problema es un error fatal" );

  my $fakeREADME_neutra = $fakeREADME . " Se aplicará un algoritmo sobre la aplicación web resultante.";
  stdout_unlike( sub {
    $returnedREADME = objetivo_0( \@mock_repo_files, $fakeREADME_neutra );
  },
               qr/solución técnica/s,
               "Mencionar «aplicación» de pasada no es, por sí solo, un error" );

  # Usar solo verbos CRUD/almacenamiento, sin ninguna palabra de lógica de
  # negocio, es también un error fatal.
  my $fakeREADME_crud = "Los usuarios podrán buscar información y enviar mensajes a otros usuarios.";
  stdout_like( sub {
    $returnedREADME = objetivo_0( \@mock_repo_files, $fakeREADME_crud );
  },
               qr/CRUD\/almacenamiento/s,
               "Usar solo verbos CRUD sin lógica de negocio es un error fatal" );

  @mock_repo_files = qw( README.md .gitignore LICENSE );
  stdout_like( sub {
    $returnedREADME = objetivo_0( \@mock_repo_files, $fakeREADME );
  },
               qr/Quizás te has olvidado/s,
               "Avisa si el número de ficheros del repo parece escaso" );
};



done_testing;

use Test::More; # -*- mode: cperl -*-
use v5.36;
use strict;
use warnings;

use lib qw(lib ../lib);

use Objetivos;

use Test::Output;
use File::Slurper qw(read_text);

my @all_repo_files = qw( README.md .gitignore LICENSE configuración.png ficha_rol.jpg);

subtest "Funciones de utilidad" => sub {
  plan tests => 2;
  my $fake_readme_dir = "t/data";
  my $current_dir = `pwd`;
  chop( $current_dir );
  my @mock_repo_files = qw( README.md .gitignore LICENSE );
  my $fakeREADME=read_text("$fake_readme_dir/README.md");
  utf8::encode($fakeREADME);
  my ($readme_file) = grep( /^README/, @mock_repo_files );
  my $returnedREADME  =  read_text( "$fake_readme_dir/$readme_file" );
  utf8::encode($returnedREADME);;

  is( $returnedREADME, $fakeREADME, "Se devuelve el contenido correctamente" );

  stdout_like( sub {
                 README_contiene_con_mensaje("configuración","# Configuración")
               },
               qr/El README contiene/s,
               "Testeando configuración independiente de las mayúsculas"
               );
};

subtest "Objetivo 0" => sub {
  plan tests => 7;
  my $fake_readme_dir = "t/data";
  my $current_dir = `pwd`;
  chop( $current_dir );
  my @mock_repo_files = @all_repo_files;
  my $fakeREADME=read_text("$fake_readme_dir/README.md");
  utf8::encode($fakeREADME);
  chdir($fake_readme_dir) || die "No encuentro el directorio";

  stdout_like( sub {
   objetivo_0( \@mock_repo_files, $fakeREADME );
  },
             qr/presente.+presente.+configuración/s,
             "Testeando comprobaciones de contenido" );

  chdir( $current_dir ) || die "No puedo cambiarme al original $!";

  @mock_repo_files = qw( README.md LICENSE );
  stdout_like( sub {
   objetivo_0( \@mock_repo_files, $fakeREADME );
  },
                 qr/Falta .gitignore/s,
                 "Falta algún fichero" );

  @mock_repo_files = @all_repo_files;

  # Describir la solución en vez del problema es un error fatal, pero se
  # detecta por patrón (no por la simple presencia de la palabra
  # «aplicación», que puede aparecer de forma inocua en el texto).
  my $fakeREADME_solucion = $fakeREADME . " Quiero hacer una aplicación web para esto.";
  stdout_like( sub {
   objetivo_0( \@mock_repo_files, $fakeREADME_solucion );
  },
               qr/solución técnica/s,
               "Describir la solución en vez del problema es un error fatal" );

  my $fakeREADME_neutra = $fakeREADME . " Se aplicará un algoritmo sobre la aplicación web resultante.";
  stdout_unlike( sub {
   objetivo_0( \@mock_repo_files, $fakeREADME_neutra );
  },
               qr/solución técnica/s,
               "Mencionar «aplicación» de pasada no es, por sí solo, un error" );

  # Usar solo verbos CRUD/almacenamiento, sin ninguna palabra de lógica de
  # negocio, es también un error fatal.
  my $fakeREADME_crud = "Los usuarios podrán buscar información y enviar mensajes a otros usuarios.";
  stdout_like( sub {
    objetivo_0( \@mock_repo_files, $fakeREADME_crud );
  },
               qr/CRUD\/almacenamiento/s,
               "Usar solo verbos CRUD sin lógica de negocio es un error fatal" );

  @mock_repo_files = qw( README.md .gitignore LICENSE );
  stdout_like( sub {
    objetivo_0( \@mock_repo_files, $fakeREADME );
  },
               qr/Quizás te has olvidado/s,
               "Avisa si el número de ficheros del repo parece escaso" );
  
  stdout_like( sub {
    objetivo_0( \@mock_repo_files, $fakeREADME );
  },
               qr/imagen de la ficha/,
               "Se detecta que falta la imagen de la ficha" );
};

subtest "Objetivo 1: se avisa si falta el directorio «docs»" => sub {
  plan tests => 4;

  my $sin_docs = combined_from( sub {
    objetivo_1( [ qw( README.md .gitignore LICENSE ) ] );
  } );
  like( $sin_docs, qr/No hay un directorio «docs»/,
        "sin docs/: se avisa de que falta el directorio" );
  like( $sin_docs, qr/::warning::/,
        "sin docs/: es un aviso, no un error bloqueante" );

  my $con_docs = combined_from( sub {
    objetivo_1( [ qw( README.md .gitignore LICENSE docs/index.md ) ] );
  } );
  like( $con_docs, qr/directorio «docs» está presente/,
        "con docs/: se reconoce el directorio" );
  unlike( $con_docs, qr/No hay un directorio «docs»/,
          "con docs/: no se avisa" );
};

subtest "Objetivo 2: la clave «entidad» ausente o vacía" => sub {
  plan tests => 9;

  # Con «entidad:» vacío en iv.yaml, en vez de un mensaje claro el
  # estudiante solo veía un aviso de Perl poco informativo:
  # «Use of uninitialized value $file in pattern match».
  my @casos = (
    { desc => "ausente",
      iv   => { CONFIGFILE => "iv.yaml", lenguaje => "perl" } },
    { desc => "vacía",
      iv   => { CONFIGFILE => "iv.yaml", lenguaje => "perl", entidad => "" } },
  );

  for my $caso ( @casos ) {
    my $salida = combined_from( sub {
      objetivo_2( $caso->{iv}, [ qw( README.md LICENSE ) ] );
    } );

    like( $salida, qr/entidad no está presente/,
          "entidad $caso->{desc}: hay un mensaje informativo sobre «entidad»" );
    unlike( $salida, qr/uninitialized value|Use of uninitialized/,
            "entidad $caso->{desc}: no se cuela un aviso de valor no inicializado" );
    unlike( $salida, qr/tiene mayúsculas/,
            "entidad $caso->{desc}: no se comprueba el nombre de un fichero vacío" );
  }

  # El camino feliz sigue funcionando: con «entidad» definida se comprueba
  # que el fichero correspondiente esté en el repo.
  my $salida_ok = combined_from( sub {
    objetivo_2( { CONFIGFILE => "iv.yaml", lenguaje => "perl", entidad => "servidor" },
                [ qw( README.md servidor.pl ) ] );
  } );
  like( $salida_ok, qr/entidad está presente/,
        "entidad definida: se informa de que la clave está presente" );
  like( $salida_ok, qr/servidor presente/,
        "entidad definida: se busca el fichero de la entidad en el repo" );
  unlike( $salida_ok, qr/uninitialized value/,
          "entidad definida: sin avisos de valor no inicializado" );
};


done_testing;

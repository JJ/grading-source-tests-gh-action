use Test::More; # -*- mode: cperl -*-
use v5.36;
use strict;
use warnings;

use lib qw(lib ../lib);

use Objetivos;

use Test::Output;
use File::Slurper qw(read_text);

subtest "Funciones de utilidad" => sub {
  plan tests => 3;
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
};


done_testing;

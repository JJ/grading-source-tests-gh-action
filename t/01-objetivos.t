use Test::More; # -*- mode: cperl -*-
use v5.36;
use strict;
use warnings;

use lib qw(lib ../lib);

use Objetivos;

use Test::Output;
use File::Slurper qw(read_text);

subtest "Funciones de utilidad" => sub {
  plan tests => 2;
  my $fake_readme_dir = "t/data";
  my $current_dir = `pwd`;
  my @mock_repo_files = qw( README.md .gitignore LICENSE );
  my $fakeREADME=read_text("$fake_readme_dir/README.md");
  utf8::encode($fakeREADME);
  my $returnedREADME;

  stdout_like( sub {
    chdir("t/data/") || die "No encuentro el directorio";
    $returnedREADME = pre_objetivo_0( \@mock_repo_files );
    chdir( $current_dir );
  },
             qr/presente.+contenido/s,
             "Testeando comprobaciones" );

  is( $returnedREADME, $fakeREADME, "Se devuelve el contenido correctamente" );

};


done_testing;

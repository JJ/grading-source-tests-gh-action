use Test::More; # -*- mode: cperl -*-
use v5.36;

use lib qw(lib ../lib);

use Objetivos;
use Test::Output;
use Test::MockFile ();

my $BIEN= "Bien";
my $MAL = "Mal";

subtest "Funciones de utilidad" => sub {
  plan tests => 2;
  
  my @mock_repo_files = qw( README.md .gitignore LICENSE );
  my $fakeREADME=<<EOC;
# Proyecto IV

Descripción de la idea
EOC
  my $returnedREADME;

  stdout_is( sub {
               
    my $README_mock = Test::MockFile->file( "README.md", $fakeREADME );
    $returnedREADME = pre_objetivo_0( \@mock_repo_files );
  },
             qw/presente.+contenido/,
             "Testeando comprobaciones" );

  is( $returnedREADME, $fakeREADME, "Se devuelve el contenido correctamente" );

};


done_testing;

use Test::More; # -*- mode: cperl -*-
use v5.36;

use lib qw(lib ../lib);

use Utility;
use Objetivos;

use Test::Output;

my $BIEN= "Bien";
my $MAL = "Mal";

subtest "Funciones de utilidad" => sub {
  plan tests => 4;

  sub salida_para_expresion_incorrecta() {
    comprueba_con_mensaje( 0, $BIEN, $MAL );
  }

  my $mensaje_error = stdout_from { error(sorry($MAL)) };

  stdout_is( \&salida_para_expresion_incorrecta, $mensaje_error, "Errores bien escritos" );

  sub salida_para_expresion_correcta() {
    comprueba_con_mensaje( "yea", $BIEN, $MAL );
  }

  stdout_is( \&salida_para_expresion_correcta, all_good($BIEN)."\n", "Va bene bien escritos" );

  sub readme_no_contiene() {
    README_contiene_con_mensaje( "foo", "bar" );
  }

  stdout_like( \&readme_no_contiene, qr/README/, "Error de no contiene correcto" );

  my $bad = "foo";
  stdout_like( sub { README_no_contiene_con_mensaje( "foo", "$bad\nbar\n$bad\nbar" ) },
               qr/El README no debe contener «$bad»/,
               "Error de contiene correcto" );
};

subtest "Funciones para objetivos" => sub {
  plan tests => 1;
  sub hello {
    my $world = $_[0];
    say "Hello $world";
  };

  my $arg = "Test";
  my $output = stdout_from { hello($arg) };
  my $objetivo = 7;
  my $wrapped_hello = call_objective_with( $objetivo, \&hello );

  stdout_like( sub { $wrapped_hello->( $arg ) }, qr/Objetivo $objetivo.+$output/s, "Can call_objective_with" );

};

subtest "Envolviendo objetivos" => sub {
  plan tests => 1;
  my @ls_files = qw(foo bar baz quux);
  my $fake_readme = "# README \n configuración";
  my $wrapped_objetivo_0 = call_objective_with( 0, \&objetivo_0 );

  stdout_like( sub { $wrapped_objetivo_0->( \@ls_files, $fake_readme ) }, qr/Falta LICENSE/s, "Can call_objective_with objetivo 0" );
};

done_testing;

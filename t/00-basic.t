use Test::More; # -*- mode: cperl -*-
use v5.36;

use lib qw(lib ../lib);

use Utility;
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

  stdout_like( \&readme_no_contiene, qr/README\.md/, "Error de no contiene correcto" );

  my $bad = "foo";
  stdout_like( sub { README_no_contiene_con_mensaje( "foo", "$bad\nbar\n$bad\nbar" ) },
               qr/El README no debe contener «$bad»/,
               "Error de contiene correcto" );
};

subtest "Funciones para objetivos" => sub {

  my $hello = sub {
    my $world = shift;
    say "Hello $world";
  };

  my $groupified_hello = groupify( $hello, "GROUP_HELLO" );

  stdout_like( sub { $groupified_hello->( "Test" ) }, qr/GROUP_HELLO/, "Can groupify" );

};

done_testing;

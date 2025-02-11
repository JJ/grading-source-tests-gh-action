use Test::More; # -*- mode: cperl -*-

use lib qw(lib ../lib);

use Utility;
use Test::Output;

my $BIEN= "Bien";
my $MAL = "Mal";

subtest "Funciones de utilidad" => sub {
  plan tests => 3;
  
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
};

done_testing;

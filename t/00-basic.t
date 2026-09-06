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

subtest "comprueba_caps y file_present con valores vacíos" => sub {
  plan tests => 4;

  # Issue #6: «entidad:» vacío en iv.yaml provocaba
  # «Use of uninitialized value $file in pattern match»
  my @avisos;
  local $SIG{__WARN__} = sub { push @avisos, $_[0] };

  my $salida_caps = stdout_from { comprueba_caps( undef, "iv.yaml" ) };
  is( $salida_caps, "", "comprueba_caps con undef no produce salida" );

  my $salida_present = stdout_from { file_present( undef, [qw(foo bar)], "Con la entidad" ) };
  unlike( $salida_present, qr/no está presente/,
          "file_present con undef no reporta fichero ausente" );

  comprueba_caps( "", "iv.yaml" );
  file_present( "", [qw(foo bar)], "Con la entidad" );

  is( scalar(@avisos), 0, "no se emiten avisos de valor no inicializado" )
    or diag( "avisos: @avisos" );
  ok( 1, "no hay excepción con «entidad» vacía" );
};

subtest "Funciones para objetivos" => sub {
  plan tests => 1;
  sub hello {
    my $world = $_[0];
    say "Hello $world";
  };

  my $arg = "Test";
  my $output = stdout_from { hello($arg) };
  my $group_name =  "GROUP_HELLO";
  my $groupified_hello = groupify( \&hello, $group_name);

  stdout_like( sub { $groupified_hello->( $arg ) }, qr/$group_name.+$output/s, "Can groupify" );

};

subtest "Envolviendo objetivos" => sub {
  plan tests => 1;
  my @ls_files = qw(foo bar baz quux);
  my $fake_readme = "# README \n configuración";
  my $groupified_objetivo_0 = groupify( \&objetivo_0, "Objetivo 0" );

  stdout_like( sub { $groupified_objetivo_0->( \@ls_files, $fake_readme ) }, qr/Falta LICENSE/s, "Can groupify objetivo 0" );
};

done_testing;

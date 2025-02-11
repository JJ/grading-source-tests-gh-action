use GitHub::Actions;
use v5.36;

# Imprime cabeceras de objetivo/hito, principalmente
sub doing {
  my $what = shift;
  start_group "\t✔ Comprobando $what\n";
}

# Cuando los tests van bien
sub all_good {
  return "✅🍊️‍🔥 " . shift
}


# Cuando fallan
sub sorry {
  return "🍋💥❌ " . shift
}

sub comprueba_con_mensaje {
  my ( $expresion, $bien, $mal ) = @_;
  if ( $expresion ) {
    say all_good($bien);
  } else {
    error( sorry( $mal ) );
  }
}

sub README_contiene_con_mensaje {
  my ($cadena, $README) = @_;
  if ( index( $README, $cadena ) >= 0 ) {
    say all_good("El README contiene «$cadena»");
  } else {
    error_on_file( sorry("El README no contiene «$cadena»"), "README.md" );
  }
}

sub README_no_contiene_con_mensaje( $cadena, $README)  {
  my @lineas = split("\n", $README );
  my @lineas_con_cadena = [];
  for (my $l = 0; $l <= $#lineas; $l++ ) {
    push @lineas_con_cadena, $l +1 if index($cadena, $lineas_con_cadena[$l] ) >= 0
  }

  if ( length( @lineas_con_cadena ) >= 1 ) {
    for my $l (@lineas_con-cadena) {
      error_on_file( sorry("El README no debe contener «$cadena»"), "README.md", $l );
    }
  } else {
    say all_good("El README no contiene «$cadena»");
  }
}

sub groupify( $wrapped_function, $group_name ) {
  return sub {
    doing( $group_name );
    &$wrapped_function( @_ );
    end_group();
  }
}

"Yay"

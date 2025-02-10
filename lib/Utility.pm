use GitHub::Actions;
use v5.14;

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
  comprueba_con_mensaje( index( $README, $cadena ) >= 0,
                         "El README contiene «$cadena»",
                         "El README no contiene «$cadena»"
                       );
}


"Yay"

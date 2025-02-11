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
  if ( index( $README, $cadena ) >= 0 ) {
    say all_good("El README contiene «$cadena»");
  } else {
    error_on_file( sorry("El README no contiene «$cadena»"), "README.md" );
  }
}

sub groupify( &wrapped_function, $group_name ) {
  return sub {
    doing( $group_name );
    &wrapped_function( @_ );
    end_group();
  }
}

"Yay"

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
  if (  $README =~ m/$cadena/i  ) {
    say all_good("El README contiene «$cadena»");
  } else {
    error( sorry("El README no contiene «$cadena».\nPor favor, consulta el guión del objetivo para ver por qué es necesario."));
  }
}

sub README_no_contiene_con_mensaje( $cadena, $README)  {
  if ( index( $README, $cadena ) < 0 ) {
    say all_good("El README no contiene «$cadena»");
  } else {
    error( sorry("El README no debe contener «$cadena». Consulta el guión del objetivo para ver por qué esto es un error") );
  }
}

# Cuando hay una advertencia, no bloqueante
sub advierte {
  return "⚠️🍋 " . shift
}

# Convierte una lista de hallazgos (mensajes ya redactados) en avisos de
# GitHub Actions. Si la lista está vacía se informa de que la comprobación
# ha ido bien, en vez de quedarse en silencio.
# $tipo vale 'error' (falla la Action) o 'warning' (no bloquea la entrega).
sub informa_hallazgos {
  my ( $tipo, $mensaje_ok, @hallazgos ) = @_;
  if ( @hallazgos ) {
    for my $hallazgo (@hallazgos) {
      if ( $tipo eq 'error' ) {
        error( sorry( $hallazgo ) );
      } else {
        warning( advierte( $hallazgo ) );
      }
    }
  } else {
    say all_good( $mensaje_ok );
  }
}

sub groupify( $wrapped_function, $group_name ) {
  return sub {
    doing( $group_name );
    $wrapped_function->( @_ );
    end_group();
  }
}

sub comprueba_caps {
  my $nombre_fichero = shift;
  my $contexto = shift;
  my @files = (ref($nombre_fichero) eq 'ARRAY')?@$nombre_fichero:($nombre_fichero);
  for my $file (@files) {
    next unless defined($file) && length($file);
    if ( $file =~ /[A-Z]/ ) {
      error (sorry( "⚠ En $contexto, «$file» tiene mayúsculas, no es una buena práctica en repos ⚠" ));
    }
  }
}

sub file_present {
  my ($file, $ls_files_ref, $name ) = @_;
  my @files = (ref($file) eq 'ARRAY')?@$file:($file);
  @files = grep { defined($_) && length($_) } @files;
  say all_good("Buscando @files en @$ls_files_ref");
  for my $a_file (@files ) {
    comprueba_con_mensaje(  grep( /$a_file/, @$ls_files_ref ),
               "Fichero $name → $a_file presente",
               "Fichero $name → $a_file no está presente" );
  }

}

sub clave_presente {
  my $iv = shift;
  my $clave = shift;
  comprueba_con_mensaje( $iv->{$clave}, "🗝️ «$clave» presente", "Falta clave «$clave»" );
}

"Yay"

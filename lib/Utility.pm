use GitHub::Actions;

# Imprime cabeceras de objetivo/hito, principalmente
sub doing {
  my $what = shift;
  start_group "\tâ Comprobando $what\n";
}

# Cuando los tets van bien
sub all_good {
  return "âğï¸âğ¥ " . shift
}


# Cuando fallan
sub sorry {
  return "ğğ¥â " . shift
}

"Yay"

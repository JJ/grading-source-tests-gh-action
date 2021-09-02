#!/usr/bin/env perl

use strict;
use warnings;
use v5.14;

use Git;

# Previa
my $student_repo = Git->repository ( Directory => "." );

# Algunas variables
my @repo_files = $student_repo->command("ls-files");

# Objetivo 0
for my $f (qw( README.md .gitignore LICENSE )) {
  if ( grep( $f, @repo_files) )  {
    say all_good( "$f presente" );
  } else {
    say sorry( "Falta $f" );
  }
}


# Subs
sub doing {
  my $what = shift;
  say "\n\t✔ Comprobando $what\n";
}

sub all_good {
    return "✅🍊️‍🔥 " . shift
}

sub sorry {
    return "🍋💥❌ " . shift
}

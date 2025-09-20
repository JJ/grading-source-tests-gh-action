use Utility;

use strict;
use warnings;
use v5.14;

use File::Slurper qw(read_text);

sub pre_objetivo_0 {
  my @repo_files = @{$_[0]};
  comprueba_con_mensaje( grep( /^README/, @repo_files ),
                         "El fichero README está presente",
                         "El fichero README no está incluido" );
  my ($readme_file) = grep( /^README/, @repo_files );
  my $README =  read_text( $readme_file );
  comprueba_con_mensaje( $README,
                         "El fichero README tiene contenido",
                         "El fichero README no tiene nada" );

  utf8::encode($README);
  return $README;
}

sub objetivo_0 {
  my @repo_files = @{$_[0]};
  my $README = $_[1];
  for my $f (qw(.gitignore LICENSE )) {
    if ( grep( /$f/, @repo_files) )  {
      say all_good( "🗄 $f presente" );
    } else {
      error( sorry( "Falta $f" ) );
    }
  }

  README_contiene_con_mensaje( "configuración", $README );
  README_no_contiene_con_mensaje( "aplicación", $README );

  comprueba_con_mensaje( @repo_files > 3,
                         "El número de ficheros en el repo parece correcto",
                         "Quizás te has olvidado incluir algún fichero, solo tengo los ficheros ".join("\n",@repo_files)."Consulta el guión" );

}

sub objetivo_2 {
  doing( "🎯 Objetivo 1" );
  my $iv = shift;
  for my $k (qw(lenguaje entidad)) {
    comprueba_con_mensaje(  $iv->{$k},
               "🗝️ $k está presente en «$iv->{'CONFIGFILE'}»",
               "🗝️ $k no está presente en «$iv->{'CONFIGFILE'}»"
             );
  }
  comprueba_caps( $iv->{'entidad'} );
  if ($iv->{'entidad'}) {
    my $repo_files = shift;
    file_present( $iv->{'entidad'}, $repo_files, "Con la entidad" );
  }
  end_group();
}

sub objetivo_3 {
  doing( "🎯 Objetivo 3" );
  my $iv = shift;
  my $README = shift;
  my $repo_files = shift;

  comprueba_con_mensaje(  $iv->{'automatizar'}, "🗝️ «automatizar» presente", "Falta clave «automatizar»" );
  comprueba_con_mensaje(  ref $iv->{'automatizar'} eq "HASH",
             "🗝️ «automatizar» es un diccionario",
             "La clave «automatizar» no contiene un diccionario, sino un " . ref $iv->{'automatizar'} );
  comprueba_con_mensaje(  $iv->{'automatizar'}{'fichero'}, "🗝️  «automatizar→fichero» presente", "Falta clave «automatizar→fichero»" );
  file_present( $iv->{'automatizar'}{'fichero'}, $repo_files, "Con el fichero de tareas" );
  comprueba_con_mensaje(  $iv->{'automatizar'}{'orden'}, "🗝️ «automatizar→orden» presente", "Falta clave «automatizar→orden»" );
  README_contiene_con_mensaje( "$iv->{'automatizar'}{'orden'} check", $README );
  set_output( 'ORDEN', $iv->{'automatizar'}{'orden'} );
  set_env( 'ORDEN', $iv->{'automatizar'}{'orden'} );
  end_group();
}

sub objetivo_4 {
  doing( "🎯 Objetivo 4" );
  my $iv = shift;
  my $README = shift;
  my $repo_files = shift;

  clave_presente( $iv,  'test' );
  file_present( $iv->{'test'}, $repo_files, "Con un fichero de test" );
  comprueba_caps( $iv->{'test'} );
  README_contiene_con_mensaje( "$iv->{'automatizar'}{'orden'} test", $README );
  end_group();
}

sub objetivo_5 {
  doing( "🎯 Objetivo 5" );
  my $iv = shift;
  my $repo_files = shift;
  say all_good("Buscando el Dockerfile");
  file_present( 'Dockerfile', $repo_files, "Dockerfile" );
  end_group();
}

sub objetivo_6 {
  doing( "🎯 Objetivo 6" );
  my $iv = shift;
  my $repo_files = shift;
  clave_presente( $iv,  'CI' );
  file_present( $iv->{'CI'}, $repo_files, "Configuración CI" ) if $iv->{'CI'};
  comprueba_caps( $iv->{'CI'} );
  end_group();
}

sub objetivo_7 {
  doing( "🎯 Objetivo 7" );
  my $iv = shift;
  my $repo_files = shift;
  clave_presente( $iv,  'configuracion' );
  file_present( $iv->{'configuracion'}, $repo_files, "Configuración app" ) if $iv->{'configuracion'};
  my $gitignore =  read_text( ".gitignore" );
   if ( index( $gitignore, ".env" ) >= 0 ) {
    say all_good( ".gitignore evita los .env");
  } else {
    error (sorry( "⚠  .gitignore no evita los ficheros de configuración ⚠" ));
  }

  end_group();
}

sub objetivo_8 {
  doing( "🎯 Objetivo 8" );
  my $iv = shift;
  clave_presente( $iv,  'framework' );
  if ( $iv->{'framework'} !~ /(express|flask)/ ) {
    say all_good( "No has elegido ninguno de los frameworks «malditos»");
  } else {
    error (sorry( "⚠ ¿Te has pensado bien lo de elegir ".$iv->{'framework'}." como framework? ⚠" ));
  }

  end_group();
}

"Objetivo final";



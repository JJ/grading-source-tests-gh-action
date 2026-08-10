use strict;
use warnings;
use v5.36;

# Analiza el texto del README (una vez extraído por pre_objetivo_0) en busca
# de los errores y advertencias comunes descritos en el guión del objetivo 0.
# Ninguna de estas comprobaciones busca frases literales completas: todas se
# basan en patrones (listas de raíces de verbos, estructuras gramaticales
# cortas) para que no sea trivial esquivarlas cambiando un par de palabras.

# --- 1. Normalización del texto ---------------------------------------

# Quita bloques de código, enlaces, imágenes y énfasis markdown, así como
# las cabeceras (título del repo, índices), dejando solo la prosa que
# describe el problema.
sub limpia_texto ( $texto ) {
  $texto //= '';
  $texto =~ s/```.*?```//gs;          # bloques de código
  $texto =~ s/`[^`]*`//g;             # código en línea
  $texto =~ s/!\[[^\]]*\]\([^)]*\)//g;      # imágenes
  $texto =~ s/\[([^\]]*)\]\([^)]*\)/$1/g;   # enlaces: se queda el texto
  $texto =~ s/(\*\*|__)(.+?)\1/$2/gs;       # negrita
  $texto =~ s/(\*|_)(.+?)\1/$2/gs;          # cursiva
  $texto =~ s/^#+.*$//mg;                   # cabeceras (título, índices)
  $texto =~ s/\s+/ /g;
  $texto =~ s/^\s+|\s+$//g;
  return $texto;
}

# --- 2. Errores fatales -------------------------------------------------

# Verbos/expresiones que anuncian la intención de construir software.
my $INTENCION    = qr/(?:quiero|queremos|quisiera|quisiéramos|pretendo|pretendemos|voy\s+a|vamos\s+a|se\s+va\s+a|mi\s+idea\s+es|nuestra\s+idea\s+es)/i;
my $CONSTRUCCION = qr/(?:hacer|crear|desarrollar|construir|programar|dise(?:ñ|n)ar|montar|implementar)/i;
my $ARTEFACTO    = qr/(?:aplicaci(?:ó|o)n|app|web|p(?:á|a)gina|programa|plataforma|sistema|software)/i;

# Patrones (no frases literales) que indican que se está describiendo la
# solución técnica en vez del problema.
my @PATRONES_SOLUCION = (
  qr/\b$INTENCION\b(?:\s+\w+){0,3}\s+$CONSTRUCCION\b(?:\s+\w+){0,2}\s+(?:un|una)\s+$ARTEFACTO\b/i,
  qr/\bmi\s+$ARTEFACTO\s+(?:har(?:á|a)|permitir(?:á|a)|consistir(?:á|a)|ser(?:á|a))(?!\w)/i,
  qr/\bel\s+programa\s+consistir(?:á|a)\s+en\b/i,
  qr/\bla\s+soluci(?:ó|o)n\s+(?:ser(?:á|a)|consiste\s+en|consistir(?:á|a)\s+en)(?!\w)/i,
);

sub detecta_solucion_tecnica ( $texto ) {
  my @hallazgos;
  for my $patron (@PATRONES_SOLUCION) {
    while ( $texto =~ /($patron)/g ) {
      push @hallazgos,
        "Describes una solución técnica en vez de un problema (\xC2\xAB$1\xC2\xBB). "
        . "Este objetivo solo pide describir el problema, no la solución "
        . "(consulta \xC2\xABSobre el contenido específico de este objetivo\xC2\xBB en el guión).";
    }
  }
  return @hallazgos;
}

# Verbos «prohibidos» (operaciones CRUD/almacenamiento) y verbos que sí
# indican lógica de negocio, expresados como raíz + cualquier terminación
# para cubrir conjugaciones sin enumerar frases completas.
my %VERBOS_PROHIBIDOS = (
  buscar             => qr/\b(?:busc\w*|b(?:u|ú)squed\w*)\b/i,
  'dar de alta'      => qr/\bdar\w*\s+de\s+alta\b/i,
  'poner en contacto' => qr/\bpon\w*\s+en\s+contacto\b/i,
  visualizar         => qr/\bvisualiz\w*\b/i,
  avisar             => qr/\bavis\w*\b/i,
  enviar             => qr/\benv(?:i|í)\w*(?!\w)/i,
  recuperar          => qr/\brecuper\w*\b/i,
  integrar           => qr/\bintegr\w*\b/i,
  alertar            => qr/\balert\w*\b/i,
  comunicar          => qr/\bcomunic\w*\b/i,
);

my %VERBOS_LOGICA = (
  calcular => qr/\bcalcul\w*\b/i,
  generar  => qr/\bgener\w*\b/i,
  extraer  => qr/\bextra\w*\b/i,
  resumir  => qr/\bresum\w*\b/i,
  filtrar  => qr/\bfiltr\w*\b/i,
  validar  => qr/\bvalid\w*\b/i,
  analizar => qr/\banaliz\w*\b/i,
);

sub _verbos_encontrados ( $texto, $verbos_ref ) {
  return sort grep { $texto =~ $verbos_ref->{$_} } keys %$verbos_ref;
}

# Fatal SOLO cuando aparece algún verbo prohibido y NINGUNO de lógica de
# negocio: exigir la ausencia total de señales positivas reduce mucho el
# riesgo de falso positivo en un error que bloquea la entrega.
sub detecta_verbos_crud_exclusivos ( $texto ) {
  my @prohibidos = _verbos_encontrados( $texto, \%VERBOS_PROHIBIDOS );
  return () unless @prohibidos;
  my @logica = _verbos_encontrados( $texto, \%VERBOS_LOGICA );
  return () if @logica;
  return (
    "Solo se describen operaciones de tipo CRUD/almacenamiento ("
    . join( ", ", @prohibidos )
    . "), sin ninguna palabra que indique lógica de negocio (por ejemplo: "
    . join( ", ", sort keys %VERBOS_LOGICA )
    . "). Revisa la sección \xC2\xABSobre la lógica de negocio\xC2\xBB del guión."
  );
}

# --- 3. Advertencias ------------------------------------------------------

sub detecta_deseo_cliente ( $texto ) {
  my @hallazgos;
  while ( $texto =~ /((?:el|la)\s+(?:cliente|persona|usuario)\s+(?:quiere|desea|quisiera|necesita)\b[^.]{0,60})/gi ) {
    push @hallazgos,
      "El problema se expresa como un simple deseo (\xC2\xAB$1\xE2\x80\xA6\xC2\xBB). "
      . "Intenta explicar la necesidad real (el \xC2\xABpor qu\xC3\xA9\xC2\xBB) detrás de ese deseo.";
  }
  return @hallazgos;
}

# Solo se avisa si la PRIMERA frase (donde se debería aterrizar el
# problema) es una definición corta y genérica del tipo «el problema de...».
# Restringirlo al arranque del texto evita marcar como vaga una descripción
# que simplemente menciona esa construcción de pasada más adelante.
sub detecta_problema_vago ( $texto ) {
  my ($primera_frase) = split /(?<=[.!?])\s+/, $texto, 2;
  return () unless $primera_frase;
  my @palabras = split ' ', $primera_frase;
  if ( $primera_frase =~ /^\s*el\s+problema\s+(?:del|de\s+la|de\s+los|de\s+las|de)\s+\S+/i
       && @palabras <= 8 ) {
    return (
      "La descripción empieza definiendo el problema de forma muy genérica "
      . "(\xC2\xAB$primera_frase\xC2\xBB). Aterriza en un problema específico y resoluble."
    );
  }
  return ();
}

sub detecta_multiples_problemas ( $texto ) {
  my $n_ademas  = () = $texto =~ /\badem(?:á|a)s\b/gi;
  my $n_tambien = () = $texto =~ /\btambi(?:é|e)n\s+(?:queremos|quiero|necesitamos|se\s+quiere)\b/gi;
  my $total = $n_ademas + $n_tambien;
  return () if $total < 2;
  return (
    "Se detectan varias introducciones de nuevos problemas ($total veces "
    . "\xC2\xABadem\xC3\xA1s\xC2\xBB/\xC2\xABtambi\xC3\xA9n queremos\xC2\xBB). "
    . "Define un único problema con una clientela clara."
  );
}

sub detecta_falta_verbos_logica ( $texto ) {
  my @logica = _verbos_encontrados( $texto, \%VERBOS_LOGICA );
  return () if @logica;
  return (
    "No se detecta ninguna palabra de lógica de negocio ("
    . join( ", ", sort keys %VERBOS_LOGICA )
    . "). Si tu problema requiere procesamiento, revisa que quede reflejado."
  );
}

sub detecta_descripcion_corta ( $texto, $minimo = 50 ) {
  my @palabras = split ' ', $texto;
  return () if @palabras >= $minimo;
  return (
    "La descripción del problema es muy corta (" . scalar(@palabras)
    . " palabras, se recomiendan al menos $minimo). Profundiza más en el problema del cliente."
  );
}

"AnalisisProblema";

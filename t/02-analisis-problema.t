use Test::More; # -*- mode: cperl -*-
use v5.36;
use strict;
use warnings;

use lib qw(lib ../lib);

use AnalisisProblema;

# NOTA: al igual que en el resto del proyecto, este fichero no usa
# `use utf8`, así que las cadenas con tildes que aparecen abajo se tratan
# como bytes, igual que el README que pasa por pre_objetivo_0 (que hace
# utf8::encode antes de devolverlo). Es la misma convención en todo el sitio.

subtest "limpia_texto" => sub {
  plan tests => 4;
  is( limpia_texto("# Título\n\nTexto normal."), "Texto normal.",
      "Quita cabeceras" );
  is( limpia_texto("Antes ```perl\nmy \$x = 1;\n``` después"), "Antes después",
      "Quita bloques de código" );
  is( limpia_texto("Mira [este enlace](http://example.com) y ![una imagen](foo.png) más"),
      "Mira este enlace y más",
      "Quita enlaces (dejando el texto) e imágenes" );
  is( limpia_texto("Esto es **muy** importante y también *bastante* raro"),
      "Esto es muy importante y también bastante raro",
      "Quita negrita y cursiva" );
};

subtest "detecta_solucion_tecnica" => sub {
  plan tests => 6;
  ok( detecta_solucion_tecnica( limpia_texto("Quiero hacer una aplicación que resuelva esto.") ),
      "Detecta «quiero hacer una aplicación»" );
  ok( detecta_solucion_tecnica( limpia_texto("Vamos a desarrollar una web para gestionar pedidos.") ),
      "Detecta «vamos a desarrollar una web»" );
  ok( detecta_solucion_tecnica( limpia_texto("Mi aplicación hará todo el trabajo por el usuario.") ),
      "Detecta «mi aplicación hará»" );
  ok( detecta_solucion_tecnica( limpia_texto("El programa consistirá en varios módulos conectados.") ),
      "Detecta «el programa consistirá en»" );
  ok( !detecta_solucion_tecnica( limpia_texto("Quiero mucho a mi madre, que hace una tarta cada domingo.") ),
      "No falso positivo con «quiero» sin construcción de software" );
  ok( !detecta_solucion_tecnica( limpia_texto(
        "Una idea de proyecto debe tener algún tipo de valor añadido, procesando "
        . "información, extrayéndola, o aplicando algún tipo de algoritmo." ) ),
      "No falso positivo con «aplicando» (no es «aplicación»)" );
};

subtest "detecta_verbos_crud_exclusivos" => sub {
  plan tests => 3;
  ok( detecta_verbos_crud_exclusivos( limpia_texto(
        "Los usuarios podrán buscar ofertas y enviar mensajes a otros usuarios." ) ),
      "Fatal si solo hay verbos CRUD" );
  ok( !detecta_verbos_crud_exclusivos( limpia_texto(
        "Los usuarios podrán buscar ofertas, que luego se analizarán y filtrarán según su perfil." ) ),
      "No es fatal si además hay lógica de negocio" );
  ok( !detecta_verbos_crud_exclusivos( limpia_texto(
        "Un texto neutro sin ningún verbo prohibido mencionado aquí." ) ),
      "No es fatal si no hay ningún verbo prohibido" );
};

subtest "detecta_deseo_cliente" => sub {
  plan tests => 2;
  ok( detecta_deseo_cliente( limpia_texto(
        "El cliente quiere reducir el tiempo que tarda en encontrar un taxi libre." ) ),
      "Detecta «el cliente quiere»" );
  ok( !detecta_deseo_cliente( limpia_texto(
        "Los taxistas de la ciudad pierden mucho tiempo circulando sin pasajeros." ) ),
      "No hay falso positivo sin esa construcción" );
};

subtest "detecta_problema_vago" => sub {
  plan tests => 2;
  ok( detecta_problema_vago( limpia_texto(
        "El problema del transporte. Es muy complejo y afecta a mucha gente de la ciudad entera." ) ),
      "Detecta arranque vago y corto" );
  ok( !detecta_problema_vago( limpia_texto(
        "El problema del transporte público en las zonas rurales de la provincia afecta a "
        . "personas mayores que tardan más de una hora en llegar al centro de salud más cercano." ) ),
      "No hay falso positivo si la primera frase ya está desarrollada" );
};

subtest "detecta_multiples_problemas" => sub {
  plan tests => 2;
  ok( detecta_multiples_problemas( limpia_texto(
        "Los vecinos no tienen parques. Además quieren más luz. Además también queremos "
        . "arreglar las aceras del barrio entero para que sea más grande y agradable." ) ),
      "Detecta uso recurrente de «además»/«también queremos»" );
  ok( !detecta_multiples_problemas( limpia_texto(
        "Los vecinos no tienen parques cercanos. Además de eso, no hay bancos suficientes." ) ),
      "Un único «además» no es scope creep" );
};

subtest "detecta_falta_verbos_logica" => sub {
  plan tests => 2;
  ok( detecta_falta_verbos_logica( limpia_texto(
        "Los usuarios podrán buscar y enviar mensajes a otros usuarios." ) ),
      "Avisa si no hay ningún verbo de lógica de negocio" );
  ok( !detecta_falta_verbos_logica( limpia_texto(
        "El sistema deberá analizar los datos de tráfico para calcular las rutas más rápidas." ) ),
      "No avisa si hay algún verbo de lógica de negocio" );
};

subtest "detecta_descripcion_corta" => sub {
  plan tests => 2;
  ok( detecta_descripcion_corta( limpia_texto("Un problema muy breve descrito en pocas palabras nada más.") ),
      "Avisa si hay menos de 50 palabras" );
  ok( !detecta_descripcion_corta( limpia_texto( join( " ", ("palabra") x 60 ) ) ),
      "No avisa con 60 palabras" );
};

done_testing;

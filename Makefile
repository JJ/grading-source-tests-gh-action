installdeps:
	cpanm --installdeps .

fatpack:
	fatpack pack iv-checks-on-source.pl > dist/iv-checks-on-source.pl

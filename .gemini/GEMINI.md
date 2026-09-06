# Project: check source code of student assignments

## General instructions

- This is written in Perl and uses Perl-only libraries; source needs to be modified at iv-checks-on-source.pl and then generated, but I'll do the generation. Since it uses fatpack to generate the final dist file, it would better not use any Perl library that needs external binary libs.
- Every objective is processed through its own sub, starting with `objetivo_0` up to the last one. Any check on the student code of that objective should be included in that subroutine.
- Heavy-lift code should be spun off to its own module, included as usual in Perl in the `lib` directory.
- All new functions need to be tested, with tests with significant names at the `t/` directory. The mainstream `Test::More` library is used. Ask about any other testing module that needs to be made.
- Messages and output should *always* be in Spanish, this is a Spanich-speaking class
- The maintainer *always* runs the tests, writes the commit messages and pushes. Do not run the test suite, commit or push: hand over the changed/added tests and code and wait for the maintainer to run them. When fixing a bug, write the failing test first and let the maintainer run it before touching the code being fixed.

## Coding style

Use usual Perl conventions, in principle limited to perl 5.36. If something later than that is needed, ask.

- Keep fixes minimal: change only what the issue requires. No drive-by
  style edits, reformatting or reordering.
- Declare variables at the point of first use, not hoisted to the top of
  the sub/block, even when it "reads cleaner". Declaring them where they
  are used keeps their scope tight and makes it obvious what can be
  removed if that code path goes away. Moving a declaration also silently
  widens its lexical scope — call that out if it is ever actually needed.

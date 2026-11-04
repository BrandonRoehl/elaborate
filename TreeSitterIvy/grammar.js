/**
 * Tree-sitter grammar for ivy (https://github.com/robpike/ivy).
 *
 * Token classes mirror ivy's scanner (scan/scan.go). The grammar is flat on
 * purpose: ivy's parse depends on runtime state (operator definitions, input
 * base) so we only classify tokens, which is all syntax highlighting needs.
 */
module.exports = grammar({
  name: 'ivy',

  extras: $ => [/[ \t\r]/, $.comment],

  word: $ => $.identifier,

  rules: {
    source_file: $ => repeat($._token),

    _token: $ => choice(
      $.newline,
      $.string,
      $.number,
      $.keyword,
      $.operator_definition,
      $.assign,
      $.operator,
      $.identifier,
      $.colon,
      $.semicolon,
      $.bracket,
    ),

    comment: _ => token(seq('#', /[^\n]*/)),

    newline: _ => '\n',

    string: _ => token(choice(
      seq('"', repeat(choice(/[^"\\\n]/, seq('\\', /[^\n]/))), '"'),
      seq("'", repeat(choice(/[^'\\\n]/, seq('\\', /[^\n]/))), "'"),
      seq('`', repeat(/[^`]/), '`'),
    )),

    number: _ => token(seq(
      choice(
        /0[xX][0-9a-fA-F_]+/,
        /0[bB][01_]+/,
        /0[oO][0-7_]+/,
        /[0-9][0-9_]*(\.[0-9_]*)?/,
        /\.[0-9][0-9_]*/,
      ),
      optional(/[eEpP][+-]?[0-9]+/),
      // complex form: 1j2
      optional(seq('j', /[+-]?[0-9._]+/)),
    )),

    keyword: _ => choice(':if', ':else', ':elif', ':while', ':end', ':ret'),

    operator_definition: _ => 'op',

    assign: _ => '=',

    operator: _ => token(choice(
      /[?+\-\/&|^\\%@.]/,
      /,%?/,
      /[!=]==?/,
      /[<>]=?/,
      '<<',
      '>>',
      /\*\*?/,
    )),

    identifier: _ => /[a-zA-Z_\u00C0-\uFFFF][a-zA-Z0-9_\u00C0-\uFFFF]*/,

    colon: _ => ':',

    semicolon: _ => ';',

    bracket: _ => choice('(', ')', '[', ']', '{', '}'),
  },
});

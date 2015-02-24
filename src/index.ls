require! {
  './lexer'
  './parser': {parser}
  './ast'
  'source-map': {SourceNode}
}

# Override Jison's default lexer, so that it can accept
# the generic stream of tokens our lexer produces.
parser <<<
  yy: ast
  lexer:
    # Abuse yyleng to store the column index - in newer versions of Jison, yyloc should be used instead
    lex: -> [tag, @yytext, @yylineno, @yyleng] = @tokens[++@pos] or ['']; tag
    set-input: -> @pos = -1; @tokens = it
    upcoming-input: -> ''

exports <<<
  VERSION: '1.3.2'

  # Compiles a string of LiveScript code to JavaScript.
  compile: (code, options = {}) ->
    options.header ?= true
    try
      output = (parser.parse lexer.lex code).compile-root options
      output = new SourceNode(null, null, null, ["// Generated by LiveScript #{exports.VERSION}\n", output]) if options.header
      if options.map
        unless options.filename
          options.filename = "unnamed-" + (Math.floor(Math.random()*4294967296)).toString(16) + ".ls"

        output.setFile(options.filename)
        result = output.toStringWithSourceMap()
        unless options.dontEmbedSource
          result.map.setSourceContent(options.filename, code)
        unless options.dontEmbedMap
          result.code + '\n//# sourceMappingURL=data:application/json;base64,' + new Buffer(result.map.toString()).toString('base64') + '\n'
        else
          result
      else
        output.toString()
    catch
      e.message += "\nat #that" if options.filename
      throw e

  # Parses a string or tokens of LiveScript code,
  # returning the [AST](http://en.wikipedia.org/wiki/Abstract_syntax_tree).
  ast: -> parser.parse if typeof it is 'string' then lexer.lex it else it

  # Tokenizes a string of LiveScript code, returning the array of tokens.
  tokens: lexer.lex

  # Same as `tokens`, except that this skips rewriting.
  lex: -> lexer.lex it, {+raw}

  # Runs LiveScript code directly.
  run: (code, options) -> do Function exports.compile code, {...options, +bare}

exports.tokens.rewrite = lexer.rewrite

# Export AST constructors.
exports.ast <<<< parser.yy

if require.extensions
  (require './node') exports
else
  # Attach `require` for debugging.
  exports <<< {require}

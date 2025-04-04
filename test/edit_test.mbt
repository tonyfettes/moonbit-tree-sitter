///|
struct Edit {
  name : String
  search : String
  replace : String
} derive(Show, ToJson)

///|
fn parse_rules(source : Bytes) -> Array[Edit]! {
  let parser = @tree_sitter.Parser::new()
  let yaml = @tree_sitter_yaml.language()
  parser.set_language(yaml)
  let source_tree = parser.parse_bytes(
    None,
    source,
    encoding=@tree_sitter.InputEncoding::UTF8,
  )
  let source_root = source_tree.root_node()
  let query_source =
    #|(block_mapping_pair
    #| key: (_) @name
    #| value:
    #| (block_node
    #|  (block_mapping
    #|   (block_mapping_pair
    #|    key: (_) @_search
    #|    value: (_) @search)
    #|   (#eq? @_search "search")
    #|   (block_mapping_pair
    #|    key: (_) @_replace
    #|    value: (_) @replace)
    #|   (#eq? @_replace "replace"))))
  let query = @tree_sitter.Query::new!(yaml, query_source)
  let query_cursor = @tree_sitter.QueryCursor::new()
  query_cursor.exec(query, source_root)
  let edits : Array[Edit] = []
  while true {
    guard query_cursor.next_match() is Some(match_) else { break }
    let captures_nodes = {}
    let captures_texts = {}
    for capture in match_.captures {
      let node = capture.node
      let bytes = source[node.start_byte():node.end_byte()]
      let text = @encoding.decoder(UTF8).decode!([..bytes])
      captures_nodes[query.capture_name_for_id(capture.index)] = node
      captures_texts[query.capture_name_for_id(capture.index)] = text
    }
    guard captures_texts["name"] is Some(name) else {
      println("Error: missing name")
      @sys.exit(1)
    }
    guard captures_texts["search"] is Some(search) else {
      println("Error: missing search")
      @sys.exit(1)
    }
    let search : String = match search.trim_space() {
      ['|', '\n', .. search] => [..search]
      search => search
    }
    guard captures_texts["replace"] is Some(replace) else {
      println("Error: missing replace")
      @sys.exit(1)
    }
    let replace : String = match replace.trim_space() {
      ['|', '\n', .. replace] => [..replace]
      replace => replace
    }
    edits.push(Edit::{
      name,
      search: search.trim_space(),
      replace: replace.trim_space(),
    })
  }
  return edits
}

///|
test "parse_rules" {
  let rules =
    #|suggested-for-in:
    #|  search: |
    #|    ((for_expression
    #|      (for_binder
    #|       (lowercase_identifier) @binderDefinition
    #|        (expression
    #|         (pipeline_expression
    #|          (compound_expression
    #|           (simple_expression
    #|            (atomic_expression
    #|             (literal
    #|              (integer_literal) @rangeLower)))))))
    #|        .
    #|        (semicolon)
    #|        (compound_expression
    #|         (binary_expression
    #|         (_) @binderConditional
    #|         "<"
    #|         (_) @rangeUpper))
    #|        (semicolon)
    #|        (for_binder
    #|         (lowercase_identifier) @binderAssignment
    #|         (expression
    #|         (pipeline_expression
    #|          (compound_expression
    #|           (binary_expression
    #|              (_) @binderUpdate
    #|              "+"
    #|              (_) @rangeStep)))))
    #|        (block_expression) @forBody
    #|        (else_clause)? @forBody)
    #|     (#eq? @binderDefinition @binderConditional)
    #|     (#eq? @binderDefinition @binderAssignment)
    #|     (#eq? @binderDefinition @binderUpdate)
    #|     (#eq? @rangeStep "1"))
    #|  replace: |
    #|    for $binderDefinition in $rangeLower..<($rangeUpper) $forBody
    #|
  let rules = parse_rules!(@encoding.encode(UTF8, rules))
  @json.inspect!(rules, content=[
    {
      "name": "suggested-for-in",
      "search": "((for_expression\n      (for_binder\n       (lowercase_identifier) @binderDefinition\n        (expression\n         (pipeline_expression\n          (compound_expression\n           (simple_expression\n            (atomic_expression\n             (literal\n              (integer_literal) @rangeLower)))))))\n        .\n        (semicolon)\n        (compound_expression\n         (binary_expression\n         (_) @binderConditional\n         \"<\"\n         (_) @rangeUpper))\n        (semicolon)\n        (for_binder\n         (lowercase_identifier) @binderAssignment\n         (expression\n         (pipeline_expression\n          (compound_expression\n           (binary_expression\n              (_) @binderUpdate\n              \"+\"\n              (_) @rangeStep)))))\n        (block_expression) @forBody\n        (else_clause)? @forBody)\n     (#eq? @binderDefinition @binderConditional)\n     (#eq? @binderDefinition @binderAssignment)\n     (#eq? @binderDefinition @binderUpdate)\n     (#eq? @rangeStep \"1\"))",
      "replace": "for $binderDefinition in $rangeLower..<($rangeUpper) $forBody",
    },
  ])
}

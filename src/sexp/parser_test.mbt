///|
test "parse" {
  @json.inspect!(
    @sexp.parse!(
      #|(structure
      #| (structure_item
      #|  (function_definition
      #|   (function_identifier
      #|    (lowercase_identifier)))))
      #|(ERROR (UNEXPECTED '`'))
      ,
    ),
    content=[
      [
        "structure",
        [
          "structure_item",
          [
            "function_definition",
            ["function_identifier", ["lowercase_identifier"]],
          ],
        ],
      ],
      ["ERROR", ["UNEXPECTED", "\"`\""]],
    ],
  )
}

///|
test "void" {
  @json.inspect!(
    @sexp.parse!(
      #|
      ,
    ),
    content=[],
  )
}

///|
test "unit" {
  @json.inspect!(
    @sexp.parse!(
      #|()
      ,
    ),
    content=[[]],
  )
}

///|
test "pair" {
  @json.inspect!(
    @sexp.parse!(
      #|(key: value)
      ,
    ),
    content=[[{ "key": "value" }]],
  )
}

///|
test "pair with multiple values" {
  @json.inspect!(
    @sexp.parse!(
      #|(key: value1 value2)
      ,
    ),
    content=[[{ "key": "value1" }, "value2"]],
  )
}

///|
fn main {
  try {
    let args = @sys.get_cli_args()
    guard args is [_, json_path, source_path] else {
      println("Usage: parse_json <path> <source>")
      return
    }
    guard @ts.Language::load(json_path, "json") is Some(json) else {
      println("Failed to load language")
      return
    }
    let source = @fs.read_file_to_string!(source_path)
    let parser = @ts.Parser::new()
    parser.set_language(json)
    let tree = parser.parse_string(None, source)
    let root_node = tree.root_node()
    let array_node = root_node.named_child(0)
    let number_node = array_node.named_child(0)
    println(root_node.type_())
    println(array_node.type_())
    println(number_node.type_())
    println(root_node.child_count())
    println(array_node.child_count())
    println(array_node.named_child_count())
    println(number_node.child_count())
    println("Syntax tree: \{root_node.string()}")
    tree.delete()
    parser.delete()
  } catch {
    error => println("Error: \{error}")
  }
}

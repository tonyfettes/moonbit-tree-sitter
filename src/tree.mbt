///|
type Tree

///|
priv trait Nullable {
  is_null(Self) -> Bool
  to_option(Self) -> Self?
}

///|
impl Nullable with to_option(self : Self) -> Self? {
  if self.is_null() {
    return None
  }
  Some(self)
}

///|
extern "c" fn ts_tree_null() -> Tree = "moonbit_c_null"

///|
#borrow(self)
extern "c" fn ts_tree_is_null(self : Tree) -> Bool = "moonbit_c_is_null"

///|
impl Nullable for Tree with is_null(self : Tree) -> Bool {
  ts_tree_is_null(self)
}

///|
#borrow(self)
extern "c" fn ts_tree_copy(self : Tree) -> Tree = "moonbit_ts_tree_copy"

///|
/// Create a shallow copy of the syntax tree. This is very fast.
///
/// You need to copy a syntax tree in order to use it on more than one thread at
/// a time, as syntax trees are not thread safe.
pub fn Tree::copy(self : Tree) -> Tree {
  ts_tree_copy(self)
}

///|
#borrow(self)
extern "c" fn ts_tree_root_node(self : Tree) -> TSNode = "moonbit_ts_tree_root_node"

///| Get the root node of the syntax tree.
pub fn Tree::root_node(self : Tree) -> Node {
  Node::{ node: ts_tree_root_node(self), tree: self }
}

///|
#borrow(self, offset_extent)
extern "c" fn ts_tree_root_node_with_offset(
  self : Tree,
  offset_bytes : UInt,
  offset_extent : Point
) -> Node = "moonbit_ts_tree_root_node_with_offset"

///|
/// Get the root node of the syntax tree, but with its position
/// shifted forward by the given offset.
pub fn Tree::root_node_with_offset(
  self : Tree,
  offset_bytes : Int,
  offset_extent : Point
) -> Node {
  ts_tree_root_node_with_offset(self, int_to_uint(offset_bytes), offset_extent)
}

///|
#borrow(self)
extern "c" fn ts_tree_language(self : Tree) -> Language = "moonbit_ts_tree_language"

///|
/// Get the language that was used to parse the syntax tree.
pub fn Tree::language(self : Tree) -> Language {
  ts_tree_language(self)
}

///|
#borrow(self)
extern "c" fn ts_tree_included_ranges(self : Tree) -> FixedArray[UInt] = "moonbit_ts_tree_included_ranges"

///|
/// Get the array of included ranges that was used to parse the syntax tree.
pub fn Tree::included_ranges(self : Tree) -> Array[Range] {
  let flatten_ranges = ts_tree_included_ranges(self)
  Array::makei(flatten_ranges.length() / 6, fn(i) {
    Range::_new(
      Point::_new(flatten_ranges[i * 6], flatten_ranges[i * 6 + 1]),
      Point::_new(flatten_ranges[i * 6 + 2], flatten_ranges[i * 6 + 3]),
      flatten_ranges[i * 6 + 4],
      flatten_ranges[i * 6 + 5],
    )
  })
}

///|
#borrow(self, edit)
extern "c" fn ts_tree_edit(self : Tree, edit : InputEdit) = "moonbit_ts_tree_edit"

///|
/// Edit the syntax tree to keep it in sync with source code that has been
/// edited.
///
/// You must describe the edit both in terms of byte offsets and in terms of
/// (row, column) coordinates.
pub fn Tree::edit(self : Tree, edit : InputEdit) -> Unit {
  ts_tree_edit(self, edit)
}

///|
#borrow(self, other)
extern "c" fn ts_tree_get_changed_ranges(
  self : Tree,
  other : Tree
) -> FixedArray[UInt] = "moonbit_ts_tree_get_changed_ranges"

///|
/// Compare an old edited syntax tree to a new syntax tree representing the same
/// document, returning an array of ranges whose syntactic structure has changed.
///
/// For this to work correctly, the old syntax tree must have been edited such
/// that its ranges match up to the new tree. Generally, you'll want to call
/// this function right after calling one of the Parser::parse functions.
/// You need to pass the old tree that was passed to parse, as well as the new
/// tree that was returned from that function.
///
/// The returned ranges indicate areas where the hierarchical structure of syntax
/// nodes (from root to leaf) has changed between the old and new trees. Characters
/// outside these ranges have identical ancestor nodes in both trees.
///
/// Note that the returned ranges may be slightly larger than the exact changed areas,
/// but Tree-sitter attempts to make them as small as possible.
pub fn Tree::get_changed_ranges(self : Tree, other : Tree) -> Array[Range] {
  let flatten_ranges = ts_tree_get_changed_ranges(self, other)
  Array::makei(flatten_ranges.length() / 6, fn(i) {
    Range::_new(
      Point::_new(flatten_ranges[i * 6], flatten_ranges[i * 6 + 1]),
      Point::_new(flatten_ranges[i * 6 + 2], flatten_ranges[i * 6 + 3]),
      flatten_ranges[i * 6 + 4],
      flatten_ranges[i * 6 + 5],
    )
  })
}

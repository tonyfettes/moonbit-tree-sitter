///|
extern type Tree

///|
pub extern "c" fn Tree::root_node(self : Tree) -> Node = "moonbit_ts_tree_root_node"

///|
pub extern "c" fn Tree::delete(self : Tree) = "moonbit_ts_tree_delete"

///|
pub extern "c" fn Tree::edit(self : Tree, edit : InputEdit) -> Tree = "moonbit_ts_tree_edit"

///|
pub extern "c" fn Tree::copy(self : Tree) -> Tree = "moonbit_ts_tree_copy"

///|
struct Lexbuf {
  content : String
  mut pos : Int
}

///|
pub fn Lexbuf::from_string(content : String) -> Lexbuf {
  { content, pos: 0 }
}

// NOTE: MoonBit do have unboxed Option[Char] optimization
///|
fn next(self : Lexbuf) -> Char? {
  if self.pos < self.content.length() {
    let ch = self.content[self.pos]
    self.pos += 1
    Some(ch)
  } else {
    None
  }
}

///|
fn substring(self : Lexbuf, start : Int, end : Int) -> String {
  self.content.substring(start~, end~)
}

///|
typealias LexTagAction = Array[Array[Int]]

///|
typealias LexState = Int

///|
typealias LexInput = Int

///|
pub(all) struct LexEngine {
  graph : Array[(LexState) -> (LexState, LexTagAction)]
  end_nodes : Array[(Int, Array[((Int, Int), (Int, Int))])?]
  start_tags : Array[Int]
  code_blocks_n : Int
}

///|
pub fn run(self : LexEngine, lexbuf : Lexbuf) -> (Int, Array[(Int, Int)]) {
  let mut state = 0
  let mut tagState : Array[Array[Int]] = []
  let backtrace = Array::make(self.code_blocks_n, None)
  for tag in self.start_tags {
    while tagState.length() <= tag {
      tagState.push([])
    }
    tagState[tag].push(lexbuf.pos)
  }
  while state != -1 {
    match self.end_nodes[state] {
      Some(t) => backtrace[t.0] = Some((lexbuf.pos, state, tagState))
      _ => ()
    }
    let b = match lexbuf.next() {
      Some(b) => b.to_int()
      None => -1
    }
    let next = self.graph[state](b)
    state = next.0
    let new_tagState : Array[Array[Int]] = []
    for i = 0; i < next.1.length(); i = i + 1 {
      new_tagState.push([])
      for j = 0; j < next.1[i].length(); j = j + 1 {
        let t = next.1[i][j]
        if t == -1 {
          new_tagState[i].push(lexbuf.pos)
        } else {
          new_tagState[i].push(tagState[i][t])
        }
      }
    }
    tagState = new_tagState
  }
  for index, b in backtrace {
    match b {
      Some((p, state, tagState)) => {
        lexbuf.pos = p
        let captures = self.end_nodes[state].unwrap().1.map(fn {
          ((b_t, b_r), (e_t, e_r)) => (tagState[b_t][b_r], tagState[e_t][e_r])
        })
        break (index, captures)
      }
      None => ()
    }
  } else {
    (self.code_blocks_n, [])
  }
}

///|
enum Token {
  LPAREN
  RPAREN
  LBRACE
  RBRACE
  LBRACKET
  RBRACKET
  COLON
  SYMBOL(String)
  NUMBER(Double)
  STRING(String)
  EOF
} derive(Eq, Show)

///|
enum TokenKind {
  TK_LPAREN
  TK_RPAREN
  TK_LBRACE
  TK_RBRACE
  TK_LBRACKET
  TK_RBRACKET
  TK_COLON
  TK_SYMBOL
  TK_NUMBER
  TK_STRING
  TK_EOF
} derive(Eq, Show)

///|
type! LexError {
  InvalidNumber(String, @json.ParseError)
  UnterminatedString
  UnrecognizedCharacter(String)
} derive(Show)

///|
fn parse_number(string : String) -> Double!@json.ParseError {
  guard @json.parse!(string) is Number(number)
  number
}

///|
let token_tag_action_row_0 : Array[Int] = []

///|
let token_tag_action_row_2 : Array[Int] = [-1]

///|
let token_tag_action_row_1 : Array[Int] = [0]

///|
let token_tag_action_0 : Array[Array[Int]] = [
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_1, token_tag_action_row_2,
  token_tag_action_row_0, token_tag_action_row_0,
]

///|
let token_tag_action_13 : Array[Array[Int]] = [
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_1, token_tag_action_row_2, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0,
]

///|
let token_tag_action_8 : Array[Array[Int]] = [
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_1, token_tag_action_row_2, token_tag_action_row_1, token_tag_action_row_2,
  token_tag_action_row_0, token_tag_action_row_0,
]

///|
let token_tag_action_7 : Array[Array[Int]] = [
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_1, token_tag_action_row_2,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_1, token_tag_action_row_2,
  token_tag_action_row_0, token_tag_action_row_0,
]

///|
let token_tag_action_10 : Array[Array[Int]] = [
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_1, token_tag_action_row_2, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_1, token_tag_action_row_2,
  token_tag_action_row_0, token_tag_action_row_0,
]

///|
let token_tag_action_9 : Array[Array[Int]] = [
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_1, token_tag_action_row_2,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_1, token_tag_action_row_2,
  token_tag_action_row_0, token_tag_action_row_0,
]

///|
let token_tag_action_12 : Array[Array[Int]] = [
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_1, token_tag_action_row_2, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_1, token_tag_action_row_2,
  token_tag_action_row_0, token_tag_action_row_0,
]

///|
let token_tag_action_11 : Array[Array[Int]] = [
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_1, token_tag_action_row_2,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_1, token_tag_action_row_2,
  token_tag_action_row_0, token_tag_action_row_0,
]

///|
let token_tag_action_4 : Array[Array[Int]] = [
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_1, token_tag_action_row_2, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_1, token_tag_action_row_2,
  token_tag_action_row_0, token_tag_action_row_0,
]

///|
let token_tag_action_3 : Array[Array[Int]] = [
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_1, token_tag_action_row_2,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_1, token_tag_action_row_2,
  token_tag_action_row_0, token_tag_action_row_0,
]

///|
let token_tag_action_2 : Array[Array[Int]] = [
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_1, token_tag_action_row_2, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_1, token_tag_action_row_2,
  token_tag_action_row_0, token_tag_action_row_0,
]

///|
let token_tag_action_1 : Array[Array[Int]] = [
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_1, token_tag_action_row_2,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_1, token_tag_action_row_2,
  token_tag_action_row_0, token_tag_action_row_0,
]

///|
let token_tag_action_15 : Array[Array[Int]] = [
  token_tag_action_row_1, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0,
]

///|
let token_tag_action_5 : Array[Array[Int]] = [
  token_tag_action_row_1, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_1, token_tag_action_row_2,
  token_tag_action_row_0, token_tag_action_row_0,
]

///|
let token_tag_action_14 : Array[Array[Int]] = [
  token_tag_action_row_1, token_tag_action_row_2, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0,
]

///|
let token_tag_action_6 : Array[Array[Int]] = [
  token_tag_action_row_1, token_tag_action_row_2, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_0,
  token_tag_action_row_0, token_tag_action_row_0, token_tag_action_row_1, token_tag_action_row_2,
  token_tag_action_row_0, token_tag_action_row_0,
]

///|
fn token_state_0(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    0..=8 => (7, token_tag_action_0)
    9..=10 => (11, token_tag_action_0)
    11..=12 => (7, token_tag_action_0)
    13 => (11, token_tag_action_0)
    14..=31 => (7, token_tag_action_0)
    32 => (11, token_tag_action_0)
    33 => (7, token_tag_action_0)
    34 => (6, token_tag_action_1)
    35..=38 => (7, token_tag_action_0)
    39 => (5, token_tag_action_2)
    40 => (4, token_tag_action_3)
    41 => (10, token_tag_action_4)
    42..=44 => (7, token_tag_action_0)
    45 => (12, token_tag_action_5)
    46..=47 => (7, token_tag_action_0)
    48 => (14, token_tag_action_6)
    49..=57 => (13, token_tag_action_6)
    58 => (3, token_tag_action_7)
    59..=64 => (7, token_tag_action_0)
    65..=90 => (8, token_tag_action_8)
    91 => (2, token_tag_action_9)
    92 => (7, token_tag_action_0)
    93 => (1, token_tag_action_10)
    94 => (7, token_tag_action_0)
    95 => (8, token_tag_action_8)
    96 => (7, token_tag_action_0)
    97..=122 => (8, token_tag_action_8)
    123 => (9, token_tag_action_11)
    124 => (7, token_tag_action_0)
    125 => (15, token_tag_action_12)
    126..=1114111 => (7, token_tag_action_0)
    _ => (-1, [])
  }
}

///|
fn token_state_1(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    _ => (-1, [])
  }
}

///|
fn token_state_2(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    _ => (-1, [])
  }
}

///|
fn token_state_3(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    _ => (-1, [])
  }
}

///|
fn token_state_4(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    _ => (-1, [])
  }
}

///|
fn token_state_5(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    _ => (-1, [])
  }
}

///|
fn token_state_6(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    _ => (-1, [])
  }
}

///|
fn token_state_7(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    _ => (-1, [])
  }
}

///|
fn token_state_8(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    48..=57 => (16, token_tag_action_13)
    65..=90 => (16, token_tag_action_13)
    95 => (16, token_tag_action_13)
    97..=122 => (16, token_tag_action_13)
    _ => (-1, [])
  }
}

///|
fn token_state_9(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    _ => (-1, [])
  }
}

///|
fn token_state_10(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    _ => (-1, [])
  }
}

///|
fn token_state_11(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    _ => (-1, [])
  }
}

///|
fn token_state_12(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    48 => (18, token_tag_action_14)
    49..=57 => (17, token_tag_action_14)
    _ => (-1, [])
  }
}

///|
fn token_state_13(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    46 => (20, token_tag_action_15)
    48..=57 => (21, token_tag_action_14)
    69 => (19, token_tag_action_15)
    101 => (19, token_tag_action_15)
    _ => (-1, [])
  }
}

///|
fn token_state_14(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    69 => (19, token_tag_action_15)
    101 => (19, token_tag_action_15)
    _ => (-1, [])
  }
}

///|
fn token_state_15(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    _ => (-1, [])
  }
}

///|
fn token_state_16(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    48..=57 => (16, token_tag_action_13)
    65..=90 => (16, token_tag_action_13)
    95 => (16, token_tag_action_13)
    97..=122 => (16, token_tag_action_13)
    _ => (-1, [])
  }
}

///|
fn token_state_17(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    46 => (20, token_tag_action_15)
    48..=57 => (21, token_tag_action_14)
    69 => (19, token_tag_action_15)
    101 => (19, token_tag_action_15)
    _ => (-1, [])
  }
}

///|
fn token_state_18(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    69 => (19, token_tag_action_15)
    101 => (19, token_tag_action_15)
    _ => (-1, [])
  }
}

///|
fn token_state_19(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    43 => (23, token_tag_action_15)
    45 => (23, token_tag_action_15)
    48..=57 => (22, token_tag_action_14)
    _ => (-1, [])
  }
}

///|
fn token_state_20(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    48..=57 => (24, token_tag_action_14)
    _ => (-1, [])
  }
}

///|
fn token_state_21(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    46 => (20, token_tag_action_15)
    48..=57 => (21, token_tag_action_14)
    69 => (19, token_tag_action_15)
    101 => (19, token_tag_action_15)
    _ => (-1, [])
  }
}

///|
fn token_state_22(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    48..=57 => (22, token_tag_action_14)
    _ => (-1, [])
  }
}

///|
fn token_state_23(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    48..=57 => (22, token_tag_action_14)
    _ => (-1, [])
  }
}

///|
fn token_state_24(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    48..=57 => (24, token_tag_action_14)
    69 => (19, token_tag_action_15)
    101 => (19, token_tag_action_15)
    _ => (-1, [])
  }
}

///|
let __mbtlex_engine_token : LexEngine = {
  graph: [
    token_state_0, token_state_1, token_state_2, token_state_3, token_state_4, token_state_5,
    token_state_6, token_state_7, token_state_8, token_state_9, token_state_10, token_state_11,
    token_state_12, token_state_13, token_state_14, token_state_15, token_state_16,
    token_state_17, token_state_18, token_state_19, token_state_20, token_state_21,
    token_state_22, token_state_23, token_state_24,
  ],
  end_nodes: [
    Some((13, [((24, 0), (25, 0))])),
    Some((9, [((16, 0), (17, 0))])),
    Some((8, [((14, 0), (15, 0))])),
    Some((10, [((18, 0), (19, 0))])),
    Some((4, [((6, 0), (7, 0))])),
    Some((3, [((4, 0), (5, 0))])),
    Some((2, [((2, 0), (3, 0))])),
    Some((12, [((22, 0), (23, 0))])),
    Some((11, [((20, 0), (21, 0))])),
    Some((6, [((10, 0), (11, 0))])),
    Some((5, [((8, 0), (9, 0))])),
    Some((0, [])),
    Some((12, [((22, 0), (23, 0))])),
    Some((1, [((0, 0), (1, 0))])),
    Some((1, [((0, 0), (1, 0))])),
    Some((7, [((12, 0), (13, 0))])),
    Some((11, [((20, 0), (21, 0))])),
    Some((1, [((0, 0), (1, 0))])),
    Some((1, [((0, 0), (1, 0))])),
    None,
    None,
    Some((1, [((0, 0), (1, 0))])),
    Some((1, [((0, 0), (1, 0))])),
    None,
    Some((1, [((0, 0), (1, 0))])),
  ],
  start_tags: [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 25],
  code_blocks_n: 14,
}

///|
fn token(lexbuf : Lexbuf) -> (Token, Position, Position)!LexError {
  match __mbtlex_engine_token.run(lexbuf) {
    (0, __mbtlex_captures) => token!(lexbuf)
    (1, __mbtlex_captures) => {
      let (_start_pos_of_t, _end_pos_of_t) = __mbtlex_captures[0]
      let t : String = lexbuf.substring(_start_pos_of_t, _end_pos_of_t)
      ignore(t)
      let number = try {
        parse_number!(t)
      } catch {
        error => raise InvalidNumber(t, error)
      }
      (NUMBER(number), _start_pos_of_t, _end_pos_of_t)
    }
    (2, __mbtlex_captures) => {
      let (_start_pos_of_t, _end_pos_of_t) = __mbtlex_captures[0]
      let t : String = lexbuf.substring(_start_pos_of_t, _end_pos_of_t)
      ignore(t)
      let buf = StringBuilder::new()
      buf.write_string(t)
      let endpos = double_quoted_string!(buf, lexbuf)
      (STRING(buf.to_string()), _start_pos_of_t, endpos)
    }
    (3, __mbtlex_captures) => {
      let (_start_pos_of_t, _end_pos_of_t) = __mbtlex_captures[0]
      let t : String = lexbuf.substring(_start_pos_of_t, _end_pos_of_t)
      ignore(t)
      let buf = StringBuilder::new()
      buf.write_string(t)
      let endpos = single_quoted_string!(buf, lexbuf)
      (STRING(buf.to_string()), _start_pos_of_t, endpos)
    }
    (4, __mbtlex_captures) => {
      let (_start_pos_of_t, _end_pos_of_t) = __mbtlex_captures[0]
      let t : String = lexbuf.substring(_start_pos_of_t, _end_pos_of_t)
      ignore(t)
      (LPAREN, _start_pos_of_t, _end_pos_of_t)
    }
    (5, __mbtlex_captures) => {
      let (_start_pos_of_t, _end_pos_of_t) = __mbtlex_captures[0]
      let t : String = lexbuf.substring(_start_pos_of_t, _end_pos_of_t)
      ignore(t)
      (RPAREN, _start_pos_of_t, _end_pos_of_t)
    }
    (6, __mbtlex_captures) => {
      let (_start_pos_of_t, _end_pos_of_t) = __mbtlex_captures[0]
      let t : String = lexbuf.substring(_start_pos_of_t, _end_pos_of_t)
      ignore(t)
      (LBRACE, _start_pos_of_t, _end_pos_of_t)
    }
    (7, __mbtlex_captures) => {
      let (_start_pos_of_t, _end_pos_of_t) = __mbtlex_captures[0]
      let t : String = lexbuf.substring(_start_pos_of_t, _end_pos_of_t)
      ignore(t)
      (RBRACE, _start_pos_of_t, _end_pos_of_t)
    }
    (8, __mbtlex_captures) => {
      let (_start_pos_of_t, _end_pos_of_t) = __mbtlex_captures[0]
      let t : String = lexbuf.substring(_start_pos_of_t, _end_pos_of_t)
      ignore(t)
      (LBRACKET, _start_pos_of_t, _end_pos_of_t)
    }
    (9, __mbtlex_captures) => {
      let (_start_pos_of_t, _end_pos_of_t) = __mbtlex_captures[0]
      let t : String = lexbuf.substring(_start_pos_of_t, _end_pos_of_t)
      ignore(t)
      (RBRACKET, _start_pos_of_t, _end_pos_of_t)
    }
    (10, __mbtlex_captures) => {
      let (_start_pos_of_t, _end_pos_of_t) = __mbtlex_captures[0]
      let t : String = lexbuf.substring(_start_pos_of_t, _end_pos_of_t)
      ignore(t)
      (COLON, _start_pos_of_t, _end_pos_of_t)
    }
    (11, __mbtlex_captures) => {
      let (_start_pos_of_t, _end_pos_of_t) = __mbtlex_captures[0]
      let t : String = lexbuf.substring(_start_pos_of_t, _end_pos_of_t)
      ignore(t)
      (SYMBOL(t), _start_pos_of_t, _end_pos_of_t)
    }
    (12, __mbtlex_captures) => {
      let (_start_pos_of_t, _end_pos_of_t) = __mbtlex_captures[0]
      let t : String = lexbuf.substring(_start_pos_of_t, _end_pos_of_t)
      raise UnrecognizedCharacter(t)
    }
    (13, __mbtlex_captures) => {
      let (_start_pos_of_t, _end_pos_of_t) = __mbtlex_captures[0]
      let t : String = lexbuf.substring(_start_pos_of_t, _end_pos_of_t)
      ignore(t)
      (EOF, _start_pos_of_t, _end_pos_of_t)
    }
    _ => abort("lex: fail to match")
  }
}

///|
let double_quoted_string_tag_action_row_0 : Array[Int] = []

///|
let double_quoted_string_tag_action_row_2 : Array[Int] = [-1]

///|
let double_quoted_string_tag_action_row_1 : Array[Int] = [0]

///|
let double_quoted_string_tag_action_0 : Array[Array[Int]] = [
  double_quoted_string_tag_action_row_0, double_quoted_string_tag_action_row_0, double_quoted_string_tag_action_row_0,
  double_quoted_string_tag_action_row_0, double_quoted_string_tag_action_row_1, double_quoted_string_tag_action_row_2,
]

///|
let double_quoted_string_tag_action_2 : Array[Array[Int]] = [
  double_quoted_string_tag_action_row_0, double_quoted_string_tag_action_row_0, double_quoted_string_tag_action_row_1,
  double_quoted_string_tag_action_row_0, double_quoted_string_tag_action_row_1, double_quoted_string_tag_action_row_2,
]

///|
let double_quoted_string_tag_action_3 : Array[Array[Int]] = [
  double_quoted_string_tag_action_row_0, double_quoted_string_tag_action_row_0, double_quoted_string_tag_action_row_1,
  double_quoted_string_tag_action_row_2, double_quoted_string_tag_action_row_0, double_quoted_string_tag_action_row_0,
]

///|
let double_quoted_string_tag_action_1 : Array[Array[Int]] = [
  double_quoted_string_tag_action_row_1, double_quoted_string_tag_action_row_2, double_quoted_string_tag_action_row_0,
  double_quoted_string_tag_action_row_0, double_quoted_string_tag_action_row_1, double_quoted_string_tag_action_row_2,
]

///|
fn double_quoted_string_state_0(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    0..=33 => (2, double_quoted_string_tag_action_0)
    34 => (1, double_quoted_string_tag_action_1)
    35..=91 => (2, double_quoted_string_tag_action_0)
    92 => (3, double_quoted_string_tag_action_2)
    93..=1114111 => (2, double_quoted_string_tag_action_0)
    _ => (-1, [])
  }
}

///|
fn double_quoted_string_state_1(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    _ => (-1, [])
  }
}

///|
fn double_quoted_string_state_2(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    _ => (-1, [])
  }
}

///|
fn double_quoted_string_state_3(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    34 => (4, double_quoted_string_tag_action_3)
    _ => (-1, [])
  }
}

///|
fn double_quoted_string_state_4(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    _ => (-1, [])
  }
}

///|
let __mbtlex_engine_double_quoted_string : LexEngine = {
  graph: [
    double_quoted_string_state_0, double_quoted_string_state_1, double_quoted_string_state_2,
    double_quoted_string_state_3, double_quoted_string_state_4,
  ],
  end_nodes: [
    Some((3, [])),
    Some((0, [((0, 0), (1, 0))])),
    Some((2, [((4, 0), (5, 0))])),
    Some((2, [((4, 0), (5, 0))])),
    Some((1, [((2, 0), (3, 0))])),
  ],
  start_tags: [0, 2, 4],
  code_blocks_n: 4,
}

///|
fn double_quoted_string(
  buf : StringBuilder,
  lexbuf : Lexbuf
) -> Position!LexError {
  match __mbtlex_engine_double_quoted_string.run(lexbuf) {
    (0, __mbtlex_captures) => {
      let (_start_pos_of_t, _end_pos_of_t) = __mbtlex_captures[0]
      let t : String = lexbuf.substring(_start_pos_of_t, _end_pos_of_t)
      ignore(t)
      buf.write_string(t)
      _end_pos_of_t
    }
    (1, __mbtlex_captures) => {
      let (_start_pos_of_t, _end_pos_of_t) = __mbtlex_captures[0]
      let t : String = lexbuf.substring(_start_pos_of_t, _end_pos_of_t)
      buf.write_string(t)
      double_quoted_string!(buf, lexbuf)
    }
    (2, __mbtlex_captures) => {
      let (_start_pos_of_t, _end_pos_of_t) = __mbtlex_captures[0]
      let t : String = lexbuf.substring(_start_pos_of_t, _end_pos_of_t)
      buf.write_string(t)
      double_quoted_string!(buf, lexbuf)
    }
    (3, __mbtlex_captures) => raise UnterminatedString
    _ => abort("lex: fail to match")
  }
}

///|
let single_quoted_string_tag_action_row_0 : Array[Int] = []

///|
let single_quoted_string_tag_action_row_2 : Array[Int] = [-1]

///|
let single_quoted_string_tag_action_row_1 : Array[Int] = [0]

///|
let single_quoted_string_tag_action_0 : Array[Array[Int]] = [
  single_quoted_string_tag_action_row_0, single_quoted_string_tag_action_row_0, single_quoted_string_tag_action_row_0,
  single_quoted_string_tag_action_row_0, single_quoted_string_tag_action_row_1, single_quoted_string_tag_action_row_2,
]

///|
let single_quoted_string_tag_action_2 : Array[Array[Int]] = [
  single_quoted_string_tag_action_row_0, single_quoted_string_tag_action_row_0, single_quoted_string_tag_action_row_1,
  single_quoted_string_tag_action_row_0, single_quoted_string_tag_action_row_1, single_quoted_string_tag_action_row_2,
]

///|
let single_quoted_string_tag_action_3 : Array[Array[Int]] = [
  single_quoted_string_tag_action_row_0, single_quoted_string_tag_action_row_0, single_quoted_string_tag_action_row_1,
  single_quoted_string_tag_action_row_2, single_quoted_string_tag_action_row_0, single_quoted_string_tag_action_row_0,
]

///|
let single_quoted_string_tag_action_1 : Array[Array[Int]] = [
  single_quoted_string_tag_action_row_1, single_quoted_string_tag_action_row_2, single_quoted_string_tag_action_row_0,
  single_quoted_string_tag_action_row_0, single_quoted_string_tag_action_row_1, single_quoted_string_tag_action_row_2,
]

///|
fn single_quoted_string_state_0(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    0..=38 => (2, single_quoted_string_tag_action_0)
    39 => (1, single_quoted_string_tag_action_1)
    40..=91 => (2, single_quoted_string_tag_action_0)
    92 => (3, single_quoted_string_tag_action_2)
    93..=1114111 => (2, single_quoted_string_tag_action_0)
    _ => (-1, [])
  }
}

///|
fn single_quoted_string_state_1(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    _ => (-1, [])
  }
}

///|
fn single_quoted_string_state_2(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    _ => (-1, [])
  }
}

///|
fn single_quoted_string_state_3(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    39 => (4, single_quoted_string_tag_action_3)
    _ => (-1, [])
  }
}

///|
fn single_quoted_string_state_4(input : LexInput) -> (LexState, LexTagAction) {
  match input {
    _ => (-1, [])
  }
}

///|
let __mbtlex_engine_single_quoted_string : LexEngine = {
  graph: [
    single_quoted_string_state_0, single_quoted_string_state_1, single_quoted_string_state_2,
    single_quoted_string_state_3, single_quoted_string_state_4,
  ],
  end_nodes: [
    Some((3, [])),
    Some((0, [((0, 0), (1, 0))])),
    Some((2, [((4, 0), (5, 0))])),
    Some((2, [((4, 0), (5, 0))])),
    Some((1, [((2, 0), (3, 0))])),
  ],
  start_tags: [0, 2, 4],
  code_blocks_n: 4,
}

///|
fn single_quoted_string(
  buf : StringBuilder,
  lexbuf : Lexbuf
) -> Position!LexError {
  match __mbtlex_engine_single_quoted_string.run(lexbuf) {
    (0, __mbtlex_captures) => {
      let (_start_pos_of_t, _end_pos_of_t) = __mbtlex_captures[0]
      let t : String = lexbuf.substring(_start_pos_of_t, _end_pos_of_t)
      ignore(t)
      buf.write_string(t)
      _end_pos_of_t
    }
    (1, __mbtlex_captures) => {
      let (_start_pos_of_t, _end_pos_of_t) = __mbtlex_captures[0]
      let t : String = lexbuf.substring(_start_pos_of_t, _end_pos_of_t)
      buf.write_string(t)
      single_quoted_string!(buf, lexbuf)
    }
    (2, __mbtlex_captures) => {
      let (_start_pos_of_t, _end_pos_of_t) = __mbtlex_captures[0]
      let t : String = lexbuf.substring(_start_pos_of_t, _end_pos_of_t)
      buf.write_string(t)
      single_quoted_string!(buf, lexbuf)
    }
    (3, __mbtlex_captures) => raise UnterminatedString
    _ => abort("lex: fail to match")
  }
}

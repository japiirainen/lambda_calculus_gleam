import gleam/io
import gleam/string as s
import gleam/list as l

pub type Tok {
  LParen
  RParen
  Lambda
  Dot
  Var(name: String)
}

pub fn tokenize(src: String) -> List(Tok) {
  case s.pop_grapheme(src) {
    Error(_) -> []
    Ok(#(tok, rest)) ->
      case tok {
        "(" -> l.append([LParen], tokenize(rest))
        ")" -> l.append([RParen], tokenize(rest))
        "\\" -> l.append([Lambda], tokenize(rest))
        "." -> l.append([Dot], tokenize(rest))
        c -> {
          let alphabet = "abcdefghijklmnopqrstuvwxyz"
          case s.contains(does: alphabet, contain: c) {
            True -> l.append([Var(c)], tokenize(rest))
            _ -> tokenize(rest)
          }
        }
      }
  }
}

pub fn main() {
  let t1 = "\\x.x"
  let t2 = "(\\x.x \\y.y)"
  tokenize(t1)
  |> io.debug
  tokenize(t2)
  |> io.debug
}

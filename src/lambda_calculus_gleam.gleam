import gleam/io
import gleam/string as s
import gleam/list as l
import gleam/result as r

pub type Tok {
  LParen
  RParen
  Lambda
  Dot
  Var(n: String)
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

pub type EnvItem {
  EnvItem(n: String, t: Term)
}

pub type Term {
  TVar(n: String)
  TLambda(n: String, t: Term)
  TApp(t1: Term, t2: Term)
  TClosure(n: String, t: Term, e: List(EnvItem))
}

pub fn p_single(ts: List(Tok)) -> Result(#(Term, List(Tok)), String) {
  case ts {
    [Var(n), ..rest] -> Ok(#(TVar(n), rest))
    [Lambda, Var(n), Dot, ..b] ->
      p_single(b)
      |> r.map(fn(t) { #(TLambda(n, t.0), t.1) })
    [LParen, ..b] ->
      p_single(b)
      |> r.then(fn(t) {
        p_single(t.1)
        |> r.then(fn(t2) {
          case t2.1 {
            [RParen, ..rest] -> Ok(#(TApp(t.0, t2.0), rest))
            _ -> Error("Expected a right paren ')'")
          }
        })
      })
    _ -> Error("Failed to parse.")
  }
}

pub fn parse(ts: List(Tok)) -> Result(Term, String) {
  p_single(ts)
  |> r.map(fn(t) { t.0 })
}

pub fn main() {
  let t1 = "\\x.x"
  let t2 = "(\\x.x \\y.y)"
  tokenize(t1)
  |> io.debug
  tokenize(t2)
  |> io.debug
}

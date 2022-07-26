import gleam/io
import gleam/string as s
import gleam/string_builder as sb
import gleam/list as l
import gleam/result as r
import gleam/erlang.{get_line}
import gleam/otp/process

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

pub type Term {
  TVar(n: String)
  TLambda(n: String, t: Term)
  TApp(t1: Term, t2: Term)
  TClosure(n: String, t: Term, e: List(#(String, Term)))
}

fn p_single(ts: List(Tok)) -> Result(#(Term, List(Tok)), String) {
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

fn eval_in_env(env: List(#(String, Term)), t: Term) -> Result(Term, String) {
  case t {
    TVar(n) ->
      case l.find(env, fn(e) { e.0 == n }) {
        Ok(t) -> Ok(t.1)
        Error(_) -> Error("Variable not found.")
      }
    TLambda(n, body) -> Ok(TClosure(n, body, env))
    TApp(fun, value) ->
      case eval_in_env(env, fun) {
        Ok(TClosure(arg, body, new_env)) ->
          eval_in_env(new_env, value)
          |> r.then(fn(t) {
            eval_in_env(l.append(l.append([#(arg, t)], new_env), env), body)
          })
        _ -> Error("Expected a closure in function application.")
      }
    TClosure(arg, body, env) -> Ok(TClosure(arg, body, env))
  }
}

pub fn eval(t: Term) -> Result(Term, String) {
  eval_in_env([], t)
}

pub fn pp(t: Term) -> String {
  case t {
    TVar(n) -> n
    TLambda(n, body) ->
      sb.from_string("\\")
      |> sb.append(n)
      |> sb.append(".")
      |> sb.append(pp(body))
      |> sb.to_string
    TApp(fun, x) ->
      sb.from_string("(")
      |> sb.append(pp(fun))
      |> sb.append(" ")
      |> sb.append(pp(x))
      |> sb.append(")")
      |> sb.to_string
    TClosure(n, body, _env) ->
      sb.from_string("\\")
      |> sb.append(n)
      |> sb.append(".")
      |> sb.append(pp(body))
      |> sb.to_string
  }
}

pub fn interpret(src: String) -> Result(String, String) {
  tokenize(src)
  |> parse
  |> r.then(eval)
  |> r.map(pp)
}

pub fn main() {
  let #(sender, receiver) = process.new_channel()
  process.start(fn() {
    assert Ok(line) = get_line("> ")
    case interpret(line) {
      Ok(t) -> {
        io.println(t)
        process.send(sender, t)
      }
      Error(e) -> {
        io.println(s.append("Error: ", e))
        process.send(sender, s.append("Error: ", e))
      }
    }
  })
  let _ = process.receive(receiver, 1000)
  main()
}

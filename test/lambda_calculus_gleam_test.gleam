import gleeunit
import gleeunit/should
import lambda_calculus_gleam.{Dot, LParen, Lambda, RParen, Var, tokenize}

pub fn main() {
  gleeunit.main()
}

pub fn tokenize_handles_empty_input_test() {
  tokenize("")
  |> should.equal([])
}

pub fn tokenize_handles_whitespace_test() {
  tokenize("           ")
  |> should.equal([])
}

pub fn tokenize_simple_lambda_test() {
  tokenize("\\x.x")
  |> should.equal([Lambda, Var("x"), Dot, Var("x")])
}

pub fn tokenize_nested_lambda_whitespace_test() {
  tokenize("(\\x. x \\y. y)")
  |> should.equal([
    LParen,
    Lambda,
    Var("x"),
    Dot,
    Var("x"),
    Lambda,
    Var("y"),
    Dot,
    Var("y"),
    RParen,
  ])
}

import gleeunit
import gleeunit/should
import lambda_calculus_gleam.{
  Dot, LParen, Lambda, RParen, TApp, TLambda, TVar, Var, parse, tokenize,
}

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

pub fn parse_simple_lambda_test() {
  assert Ok(res) =
    tokenize("\\x.x")
    |> parse
  should.equal(res, TLambda("x", TVar("x")))
}

pub fn parse_nested_lambda_test() {
  assert Ok(res) =
    tokenize("(\\x. x \\y. y)")
    |> parse
  let expected = TApp(TLambda("x", TVar("x")), TLambda("y", TVar("y")))
  should.equal(res, expected)
}

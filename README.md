# lambda_calculus_gleam

[![Package Version](https://img.shields.io/hexpm/v/lambda_calculus_gleam)](https://hex.pm/packages/lambda_calculus_gleam)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/lambda_calculus_gleam/)

A Gleam project

## Quick start

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```

A sample repl session.

```sh
> \x. x
\x.x
> (\x. x) \y. y
Error: Failed to parse.
> (\x. x \y. y)
y.y
```

## Installation

If available on Hex this package can be added to your Gleam project:

```sh
gleam add lambda_calculus_gleam
```

and its documentation can be found at <https://hexdocs.pm/lambda_calculus_gleam>.

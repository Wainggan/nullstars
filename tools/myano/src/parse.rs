
use crate::error;
use crate::token::{Token, TT};
use crate::expr::{self, Node};


struct Parser<'a> {
	tokens: &'a Vec<Token>,
	reporter: &'a mut error::Reporter,
	current: usize,
}
impl Parser<'_> {
	fn new<'a>(tokens: &'a Vec<Token>, reporter: &'a mut error::Reporter) -> Parser<'a> {
		Parser {
			current: 0,
			reporter,
			tokens,
		}
	}

	fn at_end(&self) -> bool {
		self.peek().kind == TT::Eof
	}

	fn peek(&self) -> &Token {
		&self.tokens[self.current]
	}
	fn previous(&self) -> &Token {
		if self.current == 0 {
			&self.tokens[self.current]
		} else {
			&self.tokens[self.current - 1]
		}	
	}

	fn advance(&mut self) -> &Token {
		if !self.at_end() {
			self.current += 1;
		}
		self.previous()
	}

	fn check(&self, check: TT) -> bool {
		if self.at_end() {
			false
		} else {
			self.peek().kind == check
		}
	}
	fn compare(&mut self, checks: &[TT]) -> bool {
		for check in checks {
			if self.check(*check) {
				self.advance();
				return true;
			}
		}
		return false;
	}
	fn consume(&mut self, check: TT, message: &str, _pos: usize) -> &Token {
		if self.check(check) {
			return self.advance();
		}
		self.reporter.error(message.to_string());
		return self.peek();
	}

	fn parse_module(&mut self) -> Node {
		let mut stmts = Vec::new();

		while !self.at_end() {
			if self.compare(&[TT::Semicolon]) {}
			else {
				stmts.push(Box::new(self.parse_statement()));
			}
		}

		Node::Module(expr::Module { stmts })
	}

	fn parse_statement(&mut self) -> Node {
		if self.compare(&[TT::Let]) {
			return self.parse_statement_let(true);
		} else if self.compare(&[TT::Mut]) {
			return self.parse_statement_let(false);
		} else {
			return self.parse_expression();
		}
	}

	fn parse_expression(&mut self) -> Node {
		return self.parse_term();
	}

	fn parse_term(&mut self) -> Node {
		let mut expr = self.parse_factor();

		while self.compare(&[TT::Add, TT::Sub]) {
			let op = self.previous().clone();
			let right = self.parse_factor();
			expr = Node::Binary(expr::Binary {
				op, left: Box::new(expr), right: Box::new(right)
			});
		}

		return expr;
	}

	fn parse_factor(&mut self) -> Node {
		let mut expr = self.parse_unary();

		while self.compare(&[TT::Star, TT::Slash]) {
			let op = self.previous().clone();
			let right = self.parse_unary();
			expr = Node::Binary(expr::Binary {
				op, left: Box::new(expr), right: Box::new(right)
			});
		}

		return expr;
	}

	fn parse_unary(&mut self) -> Node {
		if self.compare(&[TT::Sub, TT::Bang]) {
			let op = self.previous().clone();
			let right = self.parse_unary();
			return Node::Unary(expr::Unary {
				op, right: Box::new(right)
			});
		}
		return self.parse_call();
	}

	fn parse_call(&mut self) -> Node {
		let mut expr = self.parse_primary();

		loop {
			if self.compare(&[TT::LParen]) {
				let mut args = Vec::new();
				if !self.check(TT::RParen) {
					loop {
						args.push(Box::new(self.parse_expression()));
						if !self.compare(&[TT::Comma]) {
							break;
						}
					}
				}
				let paren = self.consume(TT::RParen, "expected ')' after function call", 0);
				expr = Node::Call(expr::Call {
					expr: Box::new(expr), args, paren: paren.clone(),
				});
			} else {
				break;
			}
		}

		return expr;
	}

	fn parse_primary(&mut self) -> Node {
		if self.compare(&[TT::Identifier]) {
			let inner = self.previous();
			return Node::Identifer(expr::Identifer { name: inner.clone() });
		}

		if self.compare(&[TT::Integer]) {
			let inner = &self.previous().innr;
			let value = u64::from_str_radix(inner, 10)
				.unwrap_or(0);
			return Node::LitInt(expr::LitInt { value });
		}

		if self.compare(&[TT::Float]) {
			let inner = &self.previous().innr;
			use std::str::FromStr;
			let value = f64::from_str(inner)
				.unwrap_or(0.0);
			return Node::LitFlt(expr::LitFlt { value });
		}

		if self.compare(&[TT::LBracket]) {
			return self.parse_statement_block();
		}

		if self.compare(&[TT::LParen]) {
			let node = self.parse_expression();
			self.consume(TT::RParen, "expected ')'", self.current);
			return Node::Group(expr::Group { value: Box::new(node) });
		}

		self.reporter.error(format!("unexpected token: {}", self.peek()));
		self.advance();
		return Node::None;
	}

	fn parse_statement_block(&mut self) -> Node {
		let mut stmts = Vec::new();

		while !self.at_end() && !self.check(TT::RBracket) {
			if self.compare(&[TT::Semicolon]) {}
			else {
				stmts.push(Box::new(self.parse_statement()));
			}
		}

		self.consume(TT::RBracket, "expected '}'", 0);

		Node::Block(expr::Block { stmts })
	}

	fn parse_statement_let(&mut self, is_const: bool) -> Node {
		let name = self.consume(TT::Identifier, "expected variable identifier", 0).clone();
		// let kind = None;
		let value;
		if self.compare(&[TT::Equal]) {
			value = Some(Box::new(self.parse_expression()));
		} else {
			value = None;
		}

		Node::Let(expr::Let {
			is_const, name, value
		})
	}

}



pub fn parse(reporter: &mut error::Reporter, tokens: &Vec<Token>) -> Node {
	if !reporter.valid() {
		return Node::None;
	}
	let mut parser = Parser::new(tokens, reporter);
	let ast = parser.parse_module();
	ast
}


/*

struct Parser;
impl Parse {
	fn accept(&self, node: impl ast::Expression) -> u64 {
		match node {

		}
	}
}
impl visit::Visitor<u64> for Parser {
	fn visit_module(&mut self, node: &ast::Module) -> u64 {
		0
	}
	fn visit_binary(&mut self, node: &ast::Binary) -> u64 {
		self.accept(node.left);
	}
	fn visit_number(&mut self, node: &ast::Number) -> u64 {
		match node {
			&ast::Number::Int(n) => n,
			&ast::Number::Flt(n) => n as u64,
		}
	}
}

*/


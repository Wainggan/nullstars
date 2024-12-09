
use crate::error::Reporter;
use crate::token::{self, Token};

#[derive(Debug)]
pub enum Node {
	Module(Vec<Node>),
	Binary(Token, Box<Node>, Box<Node>),
	Unary(Token, Box<Node>),
	LitInt(u64),
	LitFlt(f64),
}

pub trait Visitor<T> {
	fn accept(&mut self, node: &Node) -> T;
}


struct Parser<'a> {
	current: usize,
	tokens: &'a Vec<Token>,
}
impl Parser<'_> {
	fn new<'a>(tokens: &'a Vec<Token>) -> Parser<'a> {
		Parser {
			current: 0,
			tokens
		}
	}

	fn at_end(&self) -> bool {
		*self.peek() == Token::Eof
	}

	fn peek(&self) -> &Token {
		&self.tokens[self.current]
	}
	fn previous(&self) -> &Token {
		&self.tokens[self.current - 1]
	}

	fn advance(&mut self) -> &Token {
		if !self.at_end() {
			self.current += 1;
		}
		self.previous()
	}

	fn check(&self, check: Token) -> bool {
		if self.at_end() {
			false
		} else {
			*self.peek() == check
		}
	}

	fn compare(&mut self, check: &[Token]) -> bool {
		for tt in check {
			if self.check(tt.clone()) {
				self.advance();
				return true;
			}
		}
		return false;
	}

	fn parse_module(&mut self) -> Node {
		let mut stmts = Vec::new();

		while !self.at_end() {
			if self.compare(&[Token::Semicolon]) {}
			else {
				stmts.push(self.parse_statement());
			}
		}

		Node::Module(stmts)
	}

	fn parse_statement(&mut self) -> Node {
		return self.parse_expression();
	}

	fn parse_expression(&mut self) -> Node {
		return self.parse_term();
	}

	fn parse_term(&mut self) -> Node {
		let mut expr = self.parse_factor();

		while self.compare(&[Token::Add, Token::Sub]) {
			let op = self.previous().clone();
			let right = self.parse_factor();
			expr = Node::Binary(op, Box::new(expr), Box::new(right));
		}

		return expr;
	}

	fn parse_factor(&mut self) -> Node {
		let mut expr = self.parse_unary();

		while self.compare(&[Token::Star, Token::Slash]) {
			let op = self.previous().clone();
			let right = self.parse_unary();
			expr = Node::Binary(op, Box::new(expr), Box::new(right));
		}

		return expr;
	}

	fn parse_unary(&mut self) -> Node {
		if self.compare(&[Token::Sub, Token::Bang]) {
			let op = self.previous().clone();
			let right = self.parse_unary();
			return Node::Unary(op, Box::new(right));
		}
		return self.parse_primary();
	}

	fn parse_primary(&mut self) -> Node {
		Node::LitInt(10)
	}


}



pub fn parse(reporter: &mut Reporter, tokens: &Vec<Token>) -> Node {
	let mut parser = Parser::new(tokens);

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



use crate::error;
use crate::token;


pub enum Node {
	Module(Vec<Node>),
	Binary(token::Token, Box<Node>, Box<Node>),
	Lit_Int(u64),
	Lit_Flt(f64),
}

pub trait Visitor<T> {
	fn accept(&mut self, node: &Node) -> T;
}

pub struct Evaluate;
impl Evaluate {
	fn visit_module(&mut self, stmts: &Vec<Node>) -> u64 {
		let mut out = 0;
		for stmt in stmts {
			out = self.accept(stmt);
		}
		return out;
	}
	fn visit_binary(&mut self, op: &token::Token, left: &Node, right: &Node) -> u64 {
		self.accept(left) + self.accept(right)
	}
}
impl Visitor<u64> for Evaluate {
	fn accept(&mut self, node: &Node) -> u64 {
		match node {
			Node::Module(stmts) => self.visit_module(stmts),
			Node::Binary(op, left, right) => self.visit_binary(op, left, right),
			Node::Lit_Int(value) => *value,
			Node::Lit_Flt(value) => *value as u64,
		}
	}
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


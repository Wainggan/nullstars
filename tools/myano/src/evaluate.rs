
use crate::token::Token;
use crate::parse::{Node, Visitor};

struct Evaluate;
impl Evaluate {
	fn visit_module(&mut self, stmts: &Vec<Node>) -> i64 {
		let mut out = 0;
		for stmt in stmts {
			out = self.accept(stmt);
		}
		return out;
	}
	fn visit_binary(&mut self, op: &Token, left: &Node, right: &Node) -> i64 {
		self.accept(left) + self.accept(right)
	}
	fn visit_unary(&mut self, op: &Token, right: &Node) -> i64 {
		-self.accept(right)
	}
}
impl Visitor<i64> for Evaluate {
	fn accept(&mut self, node: &Node) -> i64 {
		match node {
			Node::None => 0,
			Node::Group(group) => self.accept(group),
			Node::Module(stmts) => self.visit_module(stmts),
			Node::Binary(op, left, right) => self.visit_binary(op, left, right),
			Node::Unary(op, right) => self.visit_unary(op, right),
			Node::LitInt(value) => *value as i64,
			Node::LitFlt(value) => *value as i64,
		}
	}
}

pub fn test(reporter: &mut crate::error::Reporter, ast: &Node) -> i64 {
	if !reporter.valid() {
		return 0;
	}
	let mut eval = Evaluate;
	eval.accept(ast)
}




use crate::token::{Token, TT};
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
		let left = self.accept(left);
		let right = self.accept(right);
		match op.kind {
			TT::Add => left + right,
			TT::Sub => left - right,
			TT::Star => left * right,
			TT::Slash => left / right,
			TT::EqualEqual => (left == right) as i64,
			_ => panic!("oops")
		}
	}
	fn visit_unary(&mut self, op: &Token, right: &Node) -> i64 {
		let right = self.accept(right);
		match op.kind {
			TT::Sub => -right,
			TT::Bang => !(right != 0) as i64,
			_ => panic!("oops")
		}
	}
}
impl Visitor<i64> for Evaluate {
	fn accept(&mut self, node: &Node) -> i64 {
		match node {
			Node::None => 0,
			Node::Group(group) => self.accept(group),
			Node::Let(_, _, _) => 0,
			Node::Module(stmts) => self.visit_module(stmts),
			Node::Binary(op, left, right) => self.visit_binary(op, left, right),
			Node::Unary(op, right) => self.visit_unary(op, right),
			Node::Identifer(_name) => 0,
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



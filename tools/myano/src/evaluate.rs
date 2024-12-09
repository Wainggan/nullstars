
use parse;

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
			Node::LitInt(value) => *value,
			Node::LitFlt(value) => *value as u64,
		}
	}
}


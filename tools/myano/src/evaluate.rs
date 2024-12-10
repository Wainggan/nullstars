
use crate::token::{Token, TT};
use crate::expr::{self, Visitor};


struct Evaluate;
impl Visitor for Evaluate {
	type Result = i64;

	fn visit_module(&mut self, node: &expr::Module) -> Self::Result {
		let mut out = 0;
		for stmt in &node.stmts {
			out = self.resolve(stmt);
		}
		return out;
	}

	fn visit_let(&mut self, node: &expr::Let) -> Self::Result {
		0
	}

	fn visit_group(&mut self, node: &expr::Group) -> Self::Result {
		self.resolve(&node.value)
	}

	fn visit_binary(&mut self, node: &expr::Binary) -> Self::Result {
		let left = self.resolve(&node.left);
		let right = self.resolve(&node.right);
		match node.op.kind {
			TT::Add => left + right,
			TT::Sub => left - right,
			TT::Star => left * right,
			TT::Slash => left / right,
			TT::EqualEqual => (left == right) as i64,
			_ => panic!("oops")
		}
	}

	fn visit_unary(&mut self, node: &expr::Unary) -> i64 {
		let right = self.resolve(&node.right);
		match node.op.kind {
			TT::Sub => -right,
			TT::Bang => !(right != 0) as i64,
			_ => panic!("oops")
		}
	}

	fn visit_identifier(&mut self, node: &expr::Identifer) -> Self::Result {
		0
	}

	fn visit_lit_int(&mut self, node: &expr::LitInt) -> Self::Result {
		node.value as i64
	}

	fn visit_lit_flt(&mut self, node: &expr::LitFlt) -> Self::Result {
		node.value as i64
	}

}

pub fn test(reporter: &mut crate::error::Reporter, ast: &expr::Node) -> i64 {
	if !reporter.valid() {
		return 0;
	}
	let mut eval = Evaluate;
	eval.resolve(ast)
}



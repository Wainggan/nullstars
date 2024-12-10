
use crate::token::{Token, TT};
use crate::expr::{self, Visitor};


struct Evaluate;
impl Visitor for Evaluate {
	type Result = String;

	fn visit_module(&mut self, node: &expr::Module) -> Self::Result {
		let mut out = String::new();
		for stmt in &node.stmts {
			out += &self.resolve(stmt);
			out += " ";
		}
		return out;
	}

	fn visit_let(&mut self, node: &expr::Let) -> Self::Result {
		format!("let {}", node.name.innr)
	}

	fn visit_group(&mut self, node: &expr::Group) -> Self::Result {
		self.resolve(&node.value)
	}

	fn visit_binary(&mut self, node: &expr::Binary) -> Self::Result {
		let left = self.resolve(&node.left);
		let right = self.resolve(&node.right);
		match node.op.kind {
			TT::Add => format!("{}+{}", left, right),
			TT::Sub => format!("{}-{}", left, right),
			TT::Star => format!("{}*{}", left, right),
			TT::Slash => format!("{}/{}", left, right),
			TT::EqualEqual => format!("{}=={}", left, right),
			_ => panic!("oops")
		}
	}

	fn visit_unary(&mut self, node: &expr::Unary) -> Self::Result {
		let right = self.resolve(&node.right);
		match node.op.kind {
			TT::Sub => format!("-{}", right),
			TT::Bang => format!("!{}", right),
			_ => panic!("oops")
		}
	}

	fn visit_call(&mut self, node: &expr::Call) -> Self::Result {
		format!("{}()", self.resolve(&node.expr))
	}

	fn visit_identifier(&mut self, node: &expr::Identifer) -> Self::Result {
		node.name.innr.clone()
	}

	fn visit_lit_int(&mut self, node: &expr::LitInt) -> Self::Result {
		node.value.to_string()
	}

	fn visit_lit_flt(&mut self, node: &expr::LitFlt) -> Self::Result {
		node.value.to_string()
	}

}

pub fn test(reporter: &mut crate::error::Reporter, ast: &expr::Node) -> String {
	if !reporter.valid() {
		return "".to_string();
	}
	let mut eval = Evaluate;
	eval.resolve(ast)
}



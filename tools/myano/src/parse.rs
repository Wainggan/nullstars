
use std::fmt::Binary;

use crate::error;
use crate::token;


mod ast {
    use crate::token;

	pub struct Module {
		pub stmts: Vec<Box<Expression>>,
	}

	pub enum Expression {
		Binary {
			left: Box<Expression>,
			op: token::Token,
			right: Box<Expression>,
		},
		Literal_Int(u64),
		Literal_Flt(f64),
	}
}

mod visit {
	use super::ast::*;

	pub trait Visitor<T> {
		fn visit_module(&mut self, node: &Module) -> T;
		fn visit_expression(&mut self, node: &Expression) -> T;
	}
}

struct Parser;
impl visit::Visitor<u64> for Parser {
	fn visit_module(&mut self, node: &ast::Module) -> u64 {
		let mut out: u64 = 0;
		for statement in &node.stmts {
			out = self.visit_expression(statement);
		}
		out
	}
	fn visit_expression(&mut self, node: &ast::Expression) -> u64 {
		match node {
			ast::Expression::Binary {left, op, right} => {
				self.visit_expression(left) + self.visit_expression(right)
			},
			ast::Expression::Literal_Flt(n) => *n as u64,
			ast::Expression::Literal_Int(n) => *n as u64,
		}
	}
}



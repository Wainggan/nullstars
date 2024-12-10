
use crate::token::Token;

pub trait Visitor {
	type Result;

	fn resolve(&mut self, node: &Expr) -> Self::Result {
		match node {
			Expr::Module(v) => self.visit_module(v),
			Expr::Let(v) => self.visit_let(v),
			Expr::Group(v) => self.visit_group(v),
			Expr::Binary(v) => self.visit_binary(v),
			Expr::Unary(v) => self.visit_unary(v),
			Expr::Identifer(v) => self.visit_identifier(v),
			Expr::LitInt(v) => self.visit_lit_int(v),
			Expr::LitFlt(v) => self.visit_lit_flt(v),
		}
	}

	fn visit_module(&mut self, node: &Module) -> Self::Result;
	fn visit_let(&mut self, node: &Let) -> Self::Result;
	fn visit_group(&mut self, node: &Group) -> Self::Result;
	fn visit_binary(&mut self, node: &Binary) -> Self::Result;
	fn visit_unary(&mut self, node: &Unary) -> Self::Result;
	fn visit_identifier(&mut self, node: &Identifer) -> Self::Result;
	fn visit_lit_int(&mut self, node: &LitInt) -> Self::Result;
	fn visit_lit_flt(&mut self, node: &LitFlt) -> Self::Result;
}

pub enum Expr {
	Module(Module),
	Let(Let),
	Group(Group),
	Binary(Binary),
	Unary(Unary),
	Identifer(Identifer),
	LitInt(LitInt),
	LitFlt(LitFlt),
}

trait Ast {
	fn accept<V: Visitor>(&self, visitor: &mut V) -> V::Result;
}

macro_rules! ast {
	($a:ident, $b:ident) => {
		impl Ast for $a {
			fn accept<V: Visitor>(&self, visitor: &mut V) -> V::Result {
				visitor.$b(self)
			}
		}
	};
}

pub struct Module {
	pub stmts: Vec<Box<Expr>>
}
ast!(Module, visit_module);

pub struct Let {
	pub is_const: bool,
	pub name: Token,
	pub value: Option<Box<Expr>>
}
ast!(Let, visit_let);

pub struct Group {
	pub value: Box<Expr>
}
ast!(Group, visit_group);

pub struct Binary {
	pub left: Box<Expr>,
	pub op: Token,
	pub right: Box<Expr>,
}
ast!(Binary, visit_binary);

pub struct Unary {
	pub op: Token,
	pub right: Box<Expr>,
}
ast!(Unary, visit_unary);

pub struct Identifer {
	pub name: Token,
}
ast!(Identifer, visit_identifier);

pub struct LitInt {
	pub value: u64,
}
ast!(LitInt, visit_lit_int);

pub struct LitFlt {
	pub value: f64,
}
ast!(LitFlt, visit_lit_flt);

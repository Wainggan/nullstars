
use crate::token::Token;

pub trait Visitor {
	type Result;

	fn resolve(&mut self, node: &Node) -> Self::Result {
		match node {
			Node::None => panic!("oops! :3"),
			Node::Module(v) => self.visit_module(v),
			Node::Let(v) => self.visit_let(v),
			Node::Group(v) => self.visit_group(v),
			Node::Binary(v) => self.visit_binary(v),
			Node::Unary(v) => self.visit_unary(v),
			Node::Identifer(v) => self.visit_identifier(v),
			Node::LitInt(v) => self.visit_lit_int(v),
			Node::LitFlt(v) => self.visit_lit_flt(v),
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

#[derive(Debug)]
pub enum Node {
	None,
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

#[derive(Debug)]
pub struct Module {
	pub stmts: Vec<Box<Node>>
}
ast!(Module, visit_module);

#[derive(Debug)]
pub struct Let {
	pub is_const: bool,
	pub name: Token,
	pub value: Option<Box<Node>>
}
ast!(Let, visit_let);

#[derive(Debug)]
pub struct Group {
	pub value: Box<Node>
}
ast!(Group, visit_group);

#[derive(Debug)]
pub struct Binary {
	pub left: Box<Node>,
	pub op: Token,
	pub right: Box<Node>,
}
ast!(Binary, visit_binary);

#[derive(Debug)]
pub struct Unary {
	pub op: Token,
	pub right: Box<Node>,
}
ast!(Unary, visit_unary);

#[derive(Debug)]
pub struct Identifer {
	pub name: Token,
}
ast!(Identifer, visit_identifier);

#[derive(Debug)]
pub struct LitInt {
	pub value: u64,
}
ast!(LitInt, visit_lit_int);

#[derive(Debug)]
pub struct LitFlt {
	pub value: f64,
}
ast!(LitFlt, visit_lit_flt);

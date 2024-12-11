
use crate::token::Token;

pub trait Visitor {
	type Result;

	fn resolve(&mut self, node: &Node) -> Self::Result {
		match node {
			Node::None => panic!("oops! :3"),
			Node::Module(v) => self.visit_module(v),
			Node::Let(v) => self.visit_let(v),
			Node::If(v) => self.visit_if(v),
			Node::While(v) => self.visit_while(v),
			Node::Block(v) => self.visit_block(v),
			Node::Group(v) => self.visit_group(v),
			Node::Binary(v) => self.visit_binary(v),
			Node::Unary(v) => self.visit_unary(v),
			Node::Call(v) => self.visit_call(v),
			Node::Identifer(v) => self.visit_identifier(v),
			Node::LitInt(v) => self.visit_lit_int(v),
			Node::LitFlt(v) => self.visit_lit_flt(v),
		}
	}

	fn visit_module(&mut self, node: &Module) -> Self::Result;
	fn visit_let(&mut self, node: &Let) -> Self::Result;
	fn visit_if(&mut self, node: &If) -> Self::Result;
	fn visit_while(&mut self, node: &While) -> Self::Result;
	fn visit_block(&mut self, node: &Block) -> Self::Result;
	fn visit_group(&mut self, node: &Group) -> Self::Result;
	fn visit_binary(&mut self, node: &Binary) -> Self::Result;
	fn visit_unary(&mut self, node: &Unary) -> Self::Result;
	fn visit_call(&mut self, node: &Call) -> Self::Result;
	fn visit_identifier(&mut self, node: &Identifer) -> Self::Result;
	fn visit_lit_int(&mut self, node: &LitInt) -> Self::Result;
	fn visit_lit_flt(&mut self, node: &LitFlt) -> Self::Result;
}

#[derive(Debug)]
pub enum Node {
	None,
	Module(Module),
	Let(Let),
	If(If),
	While(While),
	Block(Block),
	Group(Group),
	Binary(Binary),
	Unary(Unary),
	Call(Call),
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
	pub stmts: Vec<Box<Node>>,
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
pub struct If {
	pub token: Token,
	pub condition: Box<Node>,
	pub branch_then: Box<Node>,
	pub branch_else: Option<Box<Node>>,
}
ast!(If, visit_if);

#[derive(Debug)]
pub struct While {
	pub token: Token,
	pub condition: Box<Node>,
	pub branch: Box<Node>,
}
ast!(While, visit_while);

#[derive(Debug)]
pub struct Block {
	pub stmts: Vec<Box<Node>>
}
ast!(Block, visit_block);

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
pub struct Call {
	pub expr: Box<Node>,
	pub args: Vec<Box<Node>>,
	pub paren: Token,
}
ast!(Call, visit_call);

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

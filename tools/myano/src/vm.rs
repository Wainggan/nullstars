
use crate::expr::{self, Visitor};

enum OP {
	Lit = 0x00,

	Add = 0x10,
	Sub = 0x11,

	Nop = 0xff,
}


struct Compiler {
	data: Vec<u8>,
}
impl Compiler {
	fn new() -> Compiler {
		Compiler {
			data: Vec::new(),
		}
	}
	fn compile(&mut self, node: &expr::Node) -> &Vec<u8> {
		self.data.clear();
		self.resolve(node);
		&self.data
	}
}
impl Visitor for Compiler {
	type Result = ();

	fn visit_module(&mut self, node: &expr::Module) -> Self::Result {
		for stmt in &node.stmts {
			self.resolve(stmt);
		}
	}

	fn visit_let(&mut self, node: &expr::Let) -> Self::Result {
		todo!()
	}

	fn visit_group(&mut self, node: &expr::Group) -> Self::Result {
		self.resolve(&node.value);
	}

	fn visit_binary(&mut self, node: &expr::Binary) -> Self::Result {
		self.resolve(&node.left);
		self.resolve(&node.right);
		self.data.push(OP::Add as u8);
	}

	fn visit_unary(&mut self, node: &expr::Unary) -> Self::Result {
		todo!()
	}

	fn visit_call(&mut self, node: &expr::Call) -> Self::Result {
		todo!()
	}

	fn visit_identifier(&mut self, node: &expr::Identifer) -> Self::Result {
		todo!()
	}

	fn visit_lit_int(&mut self, node: &expr::LitInt) -> Self::Result {
		self.data.push(OP::Lit as u8);
		self.data.extend_from_slice(&(node.value as u32).to_le_bytes());
	}

	fn visit_lit_flt(&mut self, node: &expr::LitFlt) -> Self::Result {
		self.data.push(OP::Lit as u8);
		self.data.extend_from_slice(&(node.value as u32).to_le_bytes());
	}
}


struct VM {
	pc: u32,
}
impl VM {
	fn new() -> VM {
		VM {
			pc: 0,
		}
	}

	fn run(&mut self, bin: &Vec<u8>) {
		
	}
}



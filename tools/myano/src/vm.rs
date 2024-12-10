
use std::io::Read;

use crate::expr::{self, Visitor};

mod op {
	pub const NOP: u8 = 0xff;
	pub const ADD: u8 = 0x10;
	pub const LIT: u8 = 0x00;
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
	fn compile(&mut self, node: &expr::Node) -> Vec<u8> {
		self.data.clear();
		self.resolve(node);
		self.data.clone()
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
		self.data.push(op::ADD as u8);
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
		self.data.push(op::LIT as u8);
		self.data.extend_from_slice(&(node.value as u32).to_le_bytes());
	}

	fn visit_lit_flt(&mut self, node: &expr::LitFlt) -> Self::Result {
		self.data.push(op::LIT as u8);
		self.data.extend_from_slice(&(node.value as u32).to_le_bytes());
	}
}


struct VM {
	bin: Vec<u8>,
	pc: usize,
	stack: Vec<u32>,
}
impl VM {
	fn new(bin: Vec<u8>) -> VM {
		VM {
			bin,
			stack: Vec::new(),
			pc: 0,
		}
	}

	fn step(&mut self) -> bool {
		if self.pc >= self.bin.len() {
			return false;
		}

		let op = self.bin[self.pc];
		match op {
			op::LIT => {
				self.pc += 1;
				let value = u32::from_le_bytes(
					self.bin[self.pc..self.pc + 4]
						.try_into()
						.unwrap_or([0, 0, 0, 0])
				);
				self.stack.push(value);
			},
			op::ADD => {
				let b = self.stack.pop().unwrap();
				let a = self.stack.pop().unwrap();
				self.stack.push(a + b);
			},
			op::NOP => {
				panic!("lmfao");
			},
			_ => {
				panic!("skill issue");
			},
		}

		return true;
	}

	fn run(&mut self) {
		while self.step() {
			println!("{} {:?}", self.pc, self.stack);
		}
	}
}



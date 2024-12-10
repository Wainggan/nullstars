
use crate::token;
use crate::expr::{self, Visitor};

mod op {
	pub const NOP: u8 = 0xff;
	
	pub const LIT: u8 = 0x00;
	pub const POP: u8 = 0x01;

	pub const ADD: u8 = 0x10;
	pub const SUB: u8 = 0x11;
	pub const MUL: u8 = 0x12;
	pub const DIV: u8 = 0x13;
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

	fn visit_block(&mut self, node: &expr::Block) -> Self::Result {
		for stmt in &node.stmts {
			self.resolve(stmt);
		}
	}

	fn visit_group(&mut self, node: &expr::Group) -> Self::Result {
		self.resolve(&node.value);
	}

	fn visit_binary(&mut self, node: &expr::Binary) -> Self::Result {
		self.resolve(&node.left);
		self.resolve(&node.right);
		match node.op.kind {
			token::TT::Add => self.data.push(op::ADD),
			token::TT::Sub => self.data.push(op::SUB),
			token::TT::Star => self.data.push(op::MUL),
			token::TT::Slash => self.data.push(op::DIV),
			_ => todo!("{:?}", node.op.kind),
		}
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
		self.data.push(op::LIT);
		self.data.extend_from_slice(&(node.value as u32).to_le_bytes());
	}

	fn visit_lit_flt(&mut self, node: &expr::LitFlt) -> Self::Result {
		self.data.push(op::LIT);
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
		self.pc += 1;
		match op {
			op::LIT => {
				let value = u32::from_le_bytes(
					self.bin[self.pc..self.pc + 4]
						.try_into()
						.unwrap_or([0, 0, 0, 0])
				);
				self.pc += 4;
				self.stack.push(value);
			},
			op::ADD => {
				let b = self.stack.pop().unwrap();
				let a = self.stack.pop().unwrap();
				self.stack.push(a + b);
			},
			op::SUB => {
				let b = self.stack.pop().unwrap();
				let a = self.stack.pop().unwrap();
				self.stack.push(a - b);
			},
			op::MUL => {
				let b = self.stack.pop().unwrap();
				let a = self.stack.pop().unwrap();
				self.stack.push(a * b);
			},
			op::DIV => {
				let b = self.stack.pop().unwrap();
				let a = self.stack.pop().unwrap();
				self.stack.push(a / b);
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
		loop {
			println!("{} {:?}", self.pc, self.stack);
			if !self.step() {
				break;
			}
		}
	}
}

pub fn compile(node: &expr::Node) -> Vec<u8> {
	let mut cc = Compiler::new();
	cc.compile(node)
}

pub fn run(bin: Vec<u8>) {
	let mut vm = VM::new(bin);
	vm.run();
}



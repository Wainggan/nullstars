
use std::borrow::BorrowMut;
use std::iter::Map;

use crate::token;
use crate::expr::{self, Visitor};

mod op {
	pub const NOP: u8 = 0xff;
	pub const EXIT: u8 = 0xfe;
	
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


trait Device {
	fn get(&self, address: usize) -> u8;
	fn set(&mut self, address: usize, value: u8);
}

struct RAM {
	memory: Vec<u8>,
}
impl RAM {
	fn new() -> RAM {
		RAM {
			memory: Vec::new(),
		}
	}
}
impl Device for RAM {
	fn get(&self, address: usize) -> u8 {
		self.memory[address]
	}
	fn set(&mut self, address: usize, value: u8) {
		self.memory[address] = value;
	}
}

struct Region {
	device: Box<dyn Device>,
	start: usize,
	end: usize,
}

struct Mapper {
	regions: Vec<Region>
}
impl Mapper {
	fn new() -> Mapper {
		Mapper {
			regions: Vec::new(),
		}
	}
	fn map(&mut self, device: Box<dyn Device>, start: usize, end: usize) {
		self.regions.push(Region {
			device: device, start, end,
		});
	}
	fn find(&self, address: usize) -> Option<&Region> {
		self.regions.iter()
			.find(|e| e.start <= address && address <= e.end)
	}
	fn find_mut(&mut self, address: usize) -> Option<&mut Region> {
		self.regions.iter_mut()
			.find(|e| e.start <= address && address <= e.end)
	}
	fn get(&self, address: usize) -> u8 {
		let region = self.find(address);
		match region {
			None => panic!(),
			Some(region) =>
				region.device.get(address - region.start)
		}
	}
	fn set(&mut self, address: usize, value: u8) {
		let region = self.find_mut(address);
		match region {
			None => panic!(),
			Some(region) =>
				region.device.set(address - region.start, value)
		}
	}
}


struct VM {
	map: Mapper,
	pc: usize,
	sp: usize,
	stack: Vec<u32>,
}
impl VM {
	fn new(map: Mapper) -> VM {
		VM {
			map,
			stack: Vec::new(),
			pc: 0,
			sp: 0,
		}
	}

	fn get_u8(&self, addr: usize) -> u8 {
		self.map.get(addr)
	}

	fn set_u8(&mut self, addr: usize, value: u8) {
		self.map.set(addr, value);
	}

	fn get_u16(&self, addr: usize) -> u16 {
		let mut bytes = 0u16.to_le_bytes();
		for i in 0..2 {
			bytes[i] = self.map.get(addr + i);
		}
		u16::from_le_bytes(bytes)
	}

	fn set_u16(&mut self, addr: usize, value: u16) {
		let bytes = value.to_le_bytes();
		for i in 0..2 {
			self.map.set(addr + i, bytes[i]);
		}
	}

	fn get_u32(&self, addr: usize) -> u32 {
		let mut bytes = 0u32.to_le_bytes();
		for i in 0..4 {
			bytes[i] = self.map.get(addr + i);
		}
		u32::from_le_bytes(bytes)
	}

	fn set_u32(&mut self, addr: usize, value: u32) {
		let bytes = value.to_le_bytes();
		for i in 0..4 {
			self.map.set(addr + i, bytes[i]);
		}
	}

	fn get_u64(&self, addr: usize) -> u64 {
		let mut bytes = 0u64.to_le_bytes();
		for i in 0..8 {
			bytes[i] = self.map.get(addr + i);
		}
		u64::from_le_bytes(bytes)
	}

	fn set_u64(&mut self, addr: usize, value: u64) {
		let bytes = value.to_le_bytes();
		for i in 0..8 {
			self.map.set(addr + i, bytes[i]);
		}
	}

	fn step(&mut self) -> bool {
		let op = self.map.get(self.pc);
		self.pc += 1;
		match op {
			op::LIT => {
				let value = self.get_u32(self.pc);
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
	let mut mapper = Mapper::new();

	let mut rom = RAM::new();
	for i in 0..bin.len() {
		rom.set(i, bin[i]);
	}

	let mut ram = RAM::new();

	mapper.map(Box::new(rom), 0x0000, 0x0fff);
	mapper.map(Box::new(ram), 0x1000, 0xffff);

	let mut vm = VM::new(mapper);
	vm.run();
}



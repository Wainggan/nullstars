
use super::make;

pub trait Pack {
	fn pack(&self, buffer: &mut Vec<u8>);
	fn pack_new(&self) -> Vec<u8> {
		let mut buffer = Vec::new();
		self.pack(&mut buffer);
		buffer
	}
}

fn push_string(buffer: &mut Vec<u8>, string: &str) {
	buffer.extend_from_slice(string.as_bytes());
	buffer.push(0); // null terminated
}
fn push_u8(buffer: &mut Vec<u8>, number: u8) {
	buffer.push(number);
}
fn push_u32(buffer: &mut Vec<u8>, number: u32) {
	buffer.extend_from_slice(&number.to_le_bytes());
}
fn push_i32(buffer: &mut Vec<u8>, number: i32) {
	buffer.extend_from_slice(&number.to_le_bytes());
}
fn push_f64(buffer: &mut Vec<u8>, number: f64) {
	buffer.extend_from_slice(&number.to_le_bytes());
}

impl Pack for make::Main {
	fn pack(&self, buffer: &mut Vec<u8>) {
		buffer.extend_from_slice(&(self.levels.len() as u32).to_le_bytes());
		for item in &self.levels {
			item.pack(buffer);
		}

		buffer.extend_from_slice(&(self.toc.len() as u32).to_le_bytes());
		for item in &self.toc {
			item.pack(buffer);
		}
	}
}

impl Pack for make::Toc {
	fn pack(&self, buffer: &mut Vec<u8>) {
		push_string(buffer, &self.name);
		push_string(buffer, &self.id);

		push_u32(buffer, self.x);
		push_u32(buffer, self.y);
		push_u32(buffer, self.width);
		push_u32(buffer, self.height);

		push_u8(buffer, self.fields.len() as u8);
		for field in &self.fields {
			field.pack(buffer);
		}
	}
}

impl Pack for make::Room {
	fn pack(&self, buffer: &mut Vec<u8>) {
		self.header.pack(buffer);
		self.content.pack(buffer);
	}
}

impl Pack for make::RoomHeader {
	fn pack(&self, buffer: &mut Vec<u8>) {
		push_string(buffer, &self.name);
		push_string(buffer, &self.id);
		push_u32(buffer, self.x);
		push_u32(buffer, self.y);
		push_u32(buffer, self.width);
		push_u32(buffer, self.height);
	}
}

impl Pack for make::RoomContent {
	fn pack(&self, buffer: &mut Vec<u8>) {
		push_u8(buffer, self.layers.len() as u8);
		for layer in &self.layers {
			layer.pack(buffer);
		}

		push_u8(buffer, self.fields.len() as u8);
		for field in &self.fields {
			field.pack(buffer);
		}
	}
}

impl Pack for make::Layer {
	fn pack(&self, buffer: &mut Vec<u8>) {
		push_string(buffer, &self.name);
		match &self.kind {
			make::LayerKinds::Grid(v) => {
				push_u8(buffer, 0x01);
				push_u32(buffer, v.items.len() as u32);

				for t in &v.items {
					push_u8(buffer, *t);
				}
			},
			make::LayerKinds::Free(v) => {
				push_u8(buffer, 0x02);
				push_u32(buffer, v.items.len() as u32);

				for t in &v.items {
					push_u32(buffer, t.0);
					push_i32(buffer, t.1);
					push_i32(buffer, t.2);
				}
			},
			make::LayerKinds::Entity(v) => {
				push_u8(buffer, 0x03);
				push_u32(buffer, v.items.len() as u32);

				for t in &v.items {
					push_string(buffer, &t.name);
					push_string(buffer, &t.id);
	
					push_u8(buffer, t.tags.len() as u8);
					for tag in &t.tags {
						push_string(buffer, tag);
					}
	
					push_u32(buffer, t.x);
					push_u32(buffer, t.y);
					push_u32(buffer, t.width);
					push_u32(buffer, t.height);
	
					push_u8(buffer, t.fields.len() as u8);
					for field in &t.fields {
						field.pack(buffer);
					}
				}
			}
		}
	}
}

impl Pack for make::Field {
	fn pack(&self, buffer: &mut Vec<u8>) {
		push_string(buffer, &self.name);
		self.value.pack(buffer);
	}
}

impl Pack for make::FieldValue {
	fn pack(&self, buffer: &mut Vec<u8>) {
		match self {
			make::FieldValue::Null => {
				push_u8(buffer, 0x00);
			},
			make::FieldValue::Int(v) => {
				push_u8(buffer, 0x01);
				push_i32(buffer, *v);
			},
			make::FieldValue::Float(v) => {
				push_u8(buffer, 0x02);
				push_f64(buffer, *v);
			},
			make::FieldValue::Bool(v) => {
				push_u8(buffer, 0x03);
				push_u8(buffer, *v as u8);
			},
			make::FieldValue::String(v) => {
				push_u8(buffer, 0x04);
				push_string(buffer, v);
			},
			make::FieldValue::Color(v) => {
				push_u8(buffer, 0x05);
				push_u8(buffer, v.0);
				push_u8(buffer, v.1);
				push_u8(buffer, v.2);
			},
			make::FieldValue::Point(v) => {
				push_u8(buffer, 0x06);
				push_u32(buffer, v.0);
				push_u32(buffer, v.1);
			},
			make::FieldValue::Entity(v) => {
				push_u8(buffer, 0x07);
				push_string(buffer, &v);
			},
			make::FieldValue::Array(v) => {
				push_u8(buffer, 0xff);
				push_u8(buffer, v.len() as u8);
				for kind in v {
					kind.pack(buffer);
				}
			},
		};
	}
}



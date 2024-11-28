
use super::types;

use serde_json;

#[derive(Debug)]
pub struct Main {
	pub levels: Vec<RoomHeader>,
	pub toc: Vec<Toc>,
}


#[derive(Debug)]
pub struct Toc {
	pub name: String,
	pub id: String,
	pub x: u32,
	pub y: u32,
	pub width: u32,
	pub height: u32,
	pub fields: Vec<Field>,
}

pub struct Room {
	pub header: RoomHeader,
	pub content: RoomContent,
}

#[derive(Debug)]
pub struct RoomHeader {
	pub name: String,
	pub id: String,
	pub x: u32,
	pub y: u32,
	pub width: u32,
	pub height: u32,
}

pub struct RoomContent {
	pub layers: Vec<Layer>,
	pub fields: Vec<Field>,
}

pub struct Layer {
	pub name: String,
	pub kind: LayerKinds,
}

pub enum LayerKinds {
	Grid(LayerGrid),
	Free(LayerFree),
	Entity(LayerEntity),
}

pub struct LayerGrid {
	pub items: Vec<u8>
}
pub struct LayerFree {
	pub items: Vec<(u32, i32, i32)>,
}
pub struct LayerEntity {
	pub items: Vec<LayerEntityInstance>,
}
pub struct LayerEntityInstance {
	pub name: String,
	pub id: String,
	pub tags: Vec<String>,
	pub x: u32,
	pub y: u32,
	pub width: u32,
	pub height: u32,
	pub fields: Vec<Field>,
}


#[derive(Debug)]
pub struct Field {
	pub name: String,
	pub value: FieldValue,
}

#[derive(Debug)]
pub enum FieldValue {
	Null,
	Int(i32),
	Float(f64),
	Bool(bool),
	String(String),
	Color((u8, u8, u8)),
	Point((u32, u32)),
	Entity(String),
	Array(Vec<FieldValue>),
}



pub fn make_main(json: &types::LdtkJson) -> Main {

	let mut levels = Vec::new();
	for l in &json.levels {
		levels.push(make_room_header(l));
	}

	let mut toc = Vec::new();
	for object in &json.toc {
		let name = &object.identifier;
		for item in &object.instances_data {
			toc.push(make_toc(item, name));
		}
	}

	Main {
		levels, toc,
	}
}

pub fn make_toc(json: &types::LdtkTocInstanceData, name: &String) -> Toc {
	let name = name.clone();
	let id = json.iids.entity_iid.clone();

	let x = json.world_x as u32;
	let y = json.world_y as u32;
	let width = json.wid_px as u32;
	let height = json.hei_px as u32;

	let keys = json.fields.as_ref().unwrap().as_object().unwrap();

	fn local_make_field(name: &str, item: FieldValue) -> Field {
		Field {
			name: name.to_string(),
			value: item,
		}
	}

	let mut fields = Vec::new();
	match name.as_str() {
		"obj_checkpoint" => {
			fields.push(local_make_field(
				"index", 
				make_field_kind_string(keys.get("index").unwrap())
			));
		},
		"obj_timer_start" => {
			fields.push(local_make_field(
				"name", 
				make_field_kind_string(keys.get("name").unwrap())
			));
			fields.push(local_make_field(
				"time", 
				make_field_kind_float(keys.get("time").unwrap())
			));
			fields.push(local_make_field(
				"dir", 
				make_field_kind_string(keys.get("dir").unwrap())
			));
			fields.push(local_make_field(
				"ref", 
				make_field_kind_entity(keys.get("ref").unwrap())
			));
		},
		_ => {
			()
		}
	}

	Toc {
		name, id, x, y, width, height, fields,
	}
}

pub fn make_room(json: &types::Level) -> Room {

	let header = make_room_header(json);
	let content = make_room_content(json);

	Room {
		header, content,
	}
}

pub fn make_room_header(json: &types::Level) -> RoomHeader {
	let name = json.identifier.clone();
	let id = json.iid.clone();

	let x = json.world_x as u32;
	let y = json.world_y as u32;
	let width = json.px_wid as u32;
	let height = json.px_hei as u32;

	RoomHeader {
		name, id, x, y, width, height
	}
}

pub fn make_room_content(json: &types::Level) -> RoomContent {

	let mut layers = Vec::new();
	for layer in json.layer_instances.as_ref().unwrap() {
		layers.push(make_layer(layer));
	}

	let mut fields = Vec::new();
	for field in &json.field_instances {
		fields.push(make_field(field));
	}

	RoomContent {
		layers, fields,
	}
}

pub fn make_layer(json: &types::LayerInstance) -> Layer {
	let name = json.identifier.clone();
	let kind;

	let insanity;

	if name == "Background" {
		insanity = "AutoLayer"; // ridiculous edge case
	} else {
		insanity = json.layer_instance_type.as_str();
	}

	match insanity {
		"IntGrid" => {
			let mut items = Vec::new();
			for t in &json.int_grid_csv {
				items.push(*t as u8);
			}
			kind = LayerKinds::Grid(LayerGrid {
				items,
			});
		},
		z @ "Tiles" | z @ "AutoLayer" => {
			let mut items = Vec::new();

			let list;
			if z == "Tiles" {
				list = &json.grid_tiles;
			} else {
				list = &json.auto_layer_tiles;
			}

			for t in list {
				let m = t.t as u32;
				let x= t.px[0] as i32;
				let y= t.px[1] as i32;
				items.push((m, x, y));
			}

			kind = LayerKinds::Free(LayerFree {
				items,
			});
		},
		"Entities" => {
			let mut items= Vec::new();

			for e in &json.entity_instances {
				let name = e.identifier.clone();
				let id = e.iid.clone();

				let mut tags = Vec::new();
				for tag in &e.tags {
					tags.push(tag.clone());
				}

				let x = e.world_x.unwrap() as u32;
				let y = e.world_y.unwrap() as u32;
				let width = e.width as u32;
				let height = e.height as u32;

				let mut fields = Vec::new();
				for field in &e.field_instances {
					fields.push(make_field(field));
				}

				items.push(LayerEntityInstance {
					name, id, tags, x, y, width, height, fields,
				});
			}

			kind = LayerKinds::Entity(LayerEntity {
				items,
			})
		},
		_ => todo!(),
	}

	Layer {
		name, kind, 
	}
}

pub fn make_field(json: &types::FieldInstance) -> Field {
	let name = json.identifier.clone();

	let value;
	if let Some(v) = &json.value {
		value = make_field_value(
			&json.field_instance_type, 
			&v
		);
	} else {
		value = FieldValue::Null;
	}
	

	Field {
		name, value,
	}
}

pub fn make_field_value(point: &str, value: &serde_json::Value) -> FieldValue {

	let kind;
	
	if point.starts_with("Array") {
		let point = point
			.trim_start_matches("Array<")
			.trim_end_matches(">");
		
		let mut collect = Vec::new();

		let values = value.as_array().unwrap();
		for value in values {
			collect.push(make_field_value(point, value))
		}

		kind = FieldValue::Array(collect);
	} else if value.is_null() {
		kind = FieldValue::Null;
	} else {
		kind = match point {
			"Int" => make_field_kind_int(value),
			"Float" => make_field_kind_float(value),
			"Bool" => make_field_kind_bool(value),
			"Color" => make_field_kind_color(value),
			"Point" => make_field_kind_point(value),
			"EntityRef" => make_field_kind_entity(value),
			_ => {
				if point.starts_with("String") || point.starts_with("LocalEnum") {
					make_field_kind_string(value)
				} else {
					todo!("{}", point);
				}
			}
		};
	}

	kind
}

pub fn make_field_kind_int(value: &serde_json::Value) -> FieldValue {
	FieldValue::Int(value.as_i64().unwrap_or(0) as i32)
}

pub fn make_field_kind_float(value: &serde_json::Value) -> FieldValue {
	FieldValue::Float(value.as_f64().unwrap_or(0.0) as f64)
}

pub fn make_field_kind_bool(value: &serde_json::Value) -> FieldValue {
	FieldValue::Bool(value.as_bool().unwrap_or(false))
}

pub fn make_field_kind_string(value: &serde_json::Value) -> FieldValue {
	FieldValue::String({
		value.as_str().unwrap_or("").to_string()
	})
}

pub fn make_field_kind_color(value: &serde_json::Value) -> FieldValue {
	FieldValue::Color({
		let make = value.as_str().unwrap_or("#ffffff")
			.trim_start_matches("#");

		let r = make[0..2].parse::<u8>().unwrap_or(0);
		let g = make[2..4].parse::<u8>().unwrap_or(0);
		let b = make[4..6].parse::<u8>().unwrap_or(0);

		(r, g, b)
	})
}

pub fn make_field_kind_point(value: &serde_json::Value) -> FieldValue {
	FieldValue::Point({
		let make = value.as_object().unwrap();
		let x = make.get("cx").unwrap().as_u64().unwrap() as u32;
		let y = make.get("cy").unwrap().as_u64().unwrap() as u32;

		(x, y)
	})
}

pub fn make_field_kind_entity(value: &serde_json::Value) -> FieldValue {
	FieldValue::Entity({
		let make = value.as_object().unwrap();
		let id = make.get("entityIid").unwrap().as_str().unwrap();

		id.to_string()
	})
}



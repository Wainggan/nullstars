
use super::types;

use serde_json;

#[derive(Debug)]
pub struct Main {
	levels: Vec<RoomHeader>,
	toc: Vec<Toc>,
}


#[derive(Debug)]
struct Toc {
	name: String,
	id: String,
	x: u32,
	y: u32,
	width: u32,
	height: u32,
	fields: Vec<Field>,
}

struct Room {
	header: RoomHeader,
	content: RoomContent,
}

#[derive(Debug)]
struct RoomHeader {
	name: String,
	id: String,
	x: u32,
	y: u32,
	width: u32,
	height: u32,
}

struct RoomContent {
	layers: Vec<Layer>,
	fields: Vec<Field>,
}

enum LayerKinds {
	Grid(LayerGrid),
	Free(LayerFree),
	Entity(LayerEntity),
}

struct Layer {
	name: String,
	kind: LayerKinds,
}

struct LayerGrid {
	items: Vec<u8>,
}

struct LayerFree {
	items: Vec<(u32, i32, i32)>,
}

struct LayerEntity {
	name: String,
	id: String,
	tags: Vec<String>,
	x: u32,
	y: u32,
	width: u32,
	height: u32,
	fields: Vec<Field>,
}


#[derive(Debug)]
struct Field {
	name: String,
	value: FieldValue,
}

#[derive(Debug)]
struct FieldValue {
	null: bool,
	kind: FieldKinds,
}

#[derive(Debug)]
enum FieldKinds {
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

	fn local_make_field(name: &str, item: FieldKinds) -> Field {
		Field {
			name: name.to_string(),
			value: FieldValue {
				null: false,
				kind: item,
			},
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

pub fn make_field(json: &types::FieldInstance) -> Field {
	let name = json.identifier.clone();

	let value = make_field_value(
		&json.field_instance_type, 
		&json.value.as_ref().unwrap()
	);

	Field {
		name, value,
	}
}

pub fn make_field_value(point: &str, value: &serde_json::Value) -> FieldValue {

	let null = value.is_null();

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

		kind = FieldKinds::Array(collect);
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

	FieldValue {
		null, kind
	}
}

pub fn make_field_kind_int(value: &serde_json::Value) -> FieldKinds {
	FieldKinds::Int(value.as_i64().unwrap_or(0) as i32)
}

pub fn make_field_kind_float(value: &serde_json::Value) -> FieldKinds {
	FieldKinds::Float(value.as_f64().unwrap_or(0.0) as f64)
}

pub fn make_field_kind_bool(value: &serde_json::Value) -> FieldKinds {
	FieldKinds::Bool(value.as_bool().unwrap_or(false))
}

pub fn make_field_kind_string(value: &serde_json::Value) -> FieldKinds {
	FieldKinds::String({
		value.as_str().unwrap_or("").to_string()
	})
}

pub fn make_field_kind_color(value: &serde_json::Value) -> FieldKinds {
	FieldKinds::Color({
		let make = value.as_str().unwrap_or("#ffffff")
			.trim_start_matches("#");

		let r = make[0..2].parse::<u8>().unwrap_or(0);
		let g = make[2..4].parse::<u8>().unwrap_or(0);
		let b = make[4..6].parse::<u8>().unwrap_or(0);

		(r, g, b)
	})
}

pub fn make_field_kind_point(value: &serde_json::Value) -> FieldKinds {
	FieldKinds::Point({
		let make = value.as_object().unwrap();
		let x = make.get("cx").unwrap().as_u64().unwrap() as u32;
		let y = make.get("cy").unwrap().as_u64().unwrap() as u32;

		(x, y)
	})
}

pub fn make_field_kind_entity(value: &serde_json::Value) -> FieldKinds {
	FieldKinds::Entity({
		let make = value.as_object().unwrap();
		let id = make.get("entityIid").unwrap().as_str().unwrap();

		id.to_string()
	})
}



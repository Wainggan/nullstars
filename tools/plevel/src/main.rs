
use pack::Pack;
use serde_json::Value;
use std::path::PathBuf;
use std::fs;

mod types;
mod make;
mod pack;

fn main() {
	let args: Vec<String> = std::env::args().collect();

	if args.len() < 3 {
		panic!("expected 2 parameters");
	}

	let mut tt_total_json = 0;
	let mut tt_total_bin = 0;
	let tt_time = std::time::Instant::now();

	let file_input = PathBuf::from(&args[1]);
	let file_output = PathBuf::from(&args[2]);

	let json = match fs::read(&file_input) {
		Ok(v) => v,
		Err(e) => panic!("file \"{}\" doesn't exist: {}",
			&file_input.to_str().unwrap_or("<>"), e
		),
	};
	tt_total_json += json.len();
	let json = match std::str::from_utf8(&json) {
		Ok(v) => v,
		Err(e) => panic!("invalid utf8: {}", e),
	};
	let json: types::LdtkJson = match serde_json::from_str(json) {
		Ok(v) => v,
		Err(e) => panic!("invalid json: {}", e),
	};

	let makes = make::make_main(&json);
	println!("{:?}", makes);

	let buffer = makes.pack_new();
	tt_total_bin += buffer.len();

	match std::fs::write(&file_output, buffer) {
		Ok(_) => (),
		Err(e) => panic!("error writing to \"{}\": {}",
			&file_output.to_str().unwrap_or("<>"), e
		),
	};

	let mut refs = Vec::new();
	for level in &json.levels {
		refs.push(&level.identifier);
	}

	for path in refs {
		let mut out_dir = file_output.clone();
		out_dir.pop();
		let out_ext = file_output.extension().unwrap();
		out_dir.push("room");

		let mut in_dir = file_input.clone();
		in_dir.pop();
		in_dir.push("level");
		in_dir.push(format!("{}.ldtkl", path));

		let json = match fs::read(&in_dir) {
			Ok(v) => v,
			Err(e) => panic!("file \"{}\" doesn't exist: {}", &path, e),
		};
		tt_total_json += json.len();
		let json = match std::str::from_utf8(&json) {
			Ok(v) => v,
			Err(e) => panic!("invalid utf8: {}", e),
		};
		let json: types::Level = match serde_json::from_str(json) {
			Ok(v) => v,
			Err(e) => panic!("invalid json: {}", e),
		};

		println!("{}", &path);

		let makes = make::make_room(&json);

		let buffer = makes.pack_new();
		tt_total_bin += buffer.len();

		if !fs::exists(&out_dir).unwrap() {
			fs::create_dir(&out_dir).unwrap()
		}

		out_dir.push(format!("{}.{}", path, out_ext.to_str().unwrap()));

		match std::fs::write(&out_dir, buffer) {
			Ok(_) => 0,
			Err(e) => panic!("error writing to \"{}\": {}",
				&out_dir.to_string_lossy(), e
			),
		};
	}

	println!("complete! in {}ms", tt_time.elapsed().as_millis());
	println!("json {} kb => bin {} kb ;3", tt_total_json / 1024, tt_total_bin / 1024);

}



fn pack_get_toc_length(toc: &Vec<types::LdtkTableOfContentEntry>) -> usize {

	let mut toc_count = 0;
	for item in toc {
		toc_count += item.instances_data.len();
	}

	toc_count
}

fn pack_root(json: &types::LdtkJson) -> Vec<u8> {
	let mut buffer = Vec::<u8>::new();

	for level in &json.levels {
		pack_root_level(level, &mut buffer);
	}

	pack_data_toc_header(&mut buffer, pack_get_toc_length(&json.toc) as u32);

	for object in &json.toc {
		let name = &object.identifier;
		
		for item in &object.instances_data {
			let id = &item.iids.entity_iid;

			let x = item.world_x as u32;
			let y = item.world_y as u32;
			let width = item.wid_px as u32;
			let height = item.hei_px as u32;

			let fields = item.fields.as_ref().unwrap();

			pack_data_toc_item(&mut buffer, name, id, x, y, width, height, fields);
		}
	}

	buffer
}

fn pack_root_level(level: &types::Level, buffer: &mut Vec<u8>) {
	let name = &level.identifier;
	let id = &level.iid;

	let x = level.world_x as u32;
	let y = level.world_y as u32;
	let width = level.px_wid as u32;
	let height = level.px_hei as u32;

	pack_data_level_header(buffer, name, id, x, y, width, height);
}

fn pack_room(level: &types::Level) -> Vec<u8> {
	let mut buffer = Vec::<u8>::new();

	let name = &level.identifier;
	let id = &level.iid;

	let x = level.world_x as u32;
	let y = level.world_y as u32;
	let width = level.px_wid as u32;
	let height = level.px_hei as u32;

	pack_data_level_header(&mut buffer, name, id, x, y, width, height);

	pack_room_layerlist(&mut buffer, level.layer_instances.as_ref().unwrap());

	buffer
}

fn pack_room_layerlist(buffer: &mut Vec<u8>, layers: &Vec<types::LayerInstance>) {

	pack_data_level_layerlist_header(buffer, layers.len() as u8);

	for layer in layers {
		pack_room_layerlist_item(buffer, layer);
	}

}

fn pack_room_layerlist_item(buffer: &mut Vec<u8>, layer: &types::LayerInstance) {

	let name = &layer.identifier;

	match layer.layer_instance_type.as_str() {
		"IntGrid" => {
			pack_data_level_layer_header(buffer, name, 0);

			let grid = &layer.int_grid_csv;
			let size = layer.c_wid * layer.c_hei;

			pack_data_level_layer_grid(
				buffer, size as u32, 
				|i| grid[i as usize] as u8
			);
		},
		z @ "Tiles" | z @ "AutoLayer" => {
			pack_data_level_layer_header(buffer, name, 1);

			let tiles;
			if z == "Tiles" {
				tiles = &layer.grid_tiles;
			} else {
				tiles = &layer.auto_layer_tiles;
			}

			let size = tiles.len();

			pack_data_level_layer_free(
				buffer, size as u32,
				|i| {
					let t = &tiles[i as usize];
					
					let x = t.px[0] as i32;
					let y = t.px[1] as i32;
					let m = t.t as u32;

					(m, x, y)
				}
			);
		},
		_ => todo!(),
	}

}

fn pack_data_level_layer_header(buffer: &mut Vec<u8>, name: &str, kind: u8) {
	buffer.extend_from_slice(name.as_bytes());
	buffer.push(0); // null terminated

	buffer.push(kind);
}

fn pack_data_level_layerlist_header(buffer: &mut Vec<u8>, size: u8) {
	buffer.push(size);
}

fn pack_data_toc_header(buffer: &mut Vec<u8>, size: u32) {
	buffer.extend_from_slice(&size.to_le_bytes());
}

fn pack_data_toc_item(
	buffer: &mut Vec<u8>,
	name: &str, id: &str,
	x: u32, y: u32, width: u32, height: u32,
	fields: &Value
) {
	let fields = fields.as_object().unwrap();

	buffer.extend_from_slice(name.as_bytes());
	buffer.push(0);

	buffer.extend_from_slice(id.as_bytes());
	buffer.push(0);

	buffer.extend_from_slice(&x.to_le_bytes());
	buffer.extend_from_slice(&y.to_le_bytes());
	buffer.extend_from_slice(&width.to_le_bytes());
	buffer.extend_from_slice(&height.to_le_bytes());

	match name {
		"obj_checkpoint" => {
			pack_data_field_string(buffer, fields.get("index").unwrap());
		},
		"obj_timer_start" => {
			pack_data_field_string(buffer, fields.get("name").unwrap());
			pack_data_field_float(buffer, fields.get("time").unwrap());
			pack_data_field_string(buffer, fields.get("dir").unwrap());
			pack_data_field_string(
				buffer, 
				fields.get("ref").unwrap()
					.as_object().unwrap()
					.get("entityIid").unwrap(),
			);
		},
		_ => (),
	}
}

fn pack_data_field_instance(
	buffer: &mut Vec<u8>,
	value: &Value, kind: &str
) {
	if kind.starts_with("Array") {
		let kind = kind
			.trim_start_matches("Array<")
			.trim_end_matches(">");

		let value = value.as_array().unwrap();

		buffer.push(255);
		buffer.push(0);

		buffer.push(value.len() as u8);

		for val in value {
			pack_data_field_value(buffer, val, kind);
		}
	} else {
		pack_data_field_value(buffer, value, kind);
	}
}

fn pack_data_field_value(
	buffer: &mut Vec<u8>,
	value: &Value, kind: &str,
) {
	match kind {
		"Int" => {
			pack_data_field_int(buffer, value);
		},
		"Float" => {
			pack_data_field_float(buffer, value);
		},
		"Bool" => {
			pack_data_field_bool(buffer, value);
		},
		"Color" => {
			pack_data_field_color(buffer, value);
		},
		"Point" => {
			pack_data_field_point(buffer, value);
		}, 
		"EntityRef" => {
			pack_data_field_entity(buffer, value);
		},
		_ => {
			if kind.starts_with("String") || kind.starts_with("LocalEnum") {
				pack_data_field_string(buffer, value);
			} else {
				todo!("{}", kind);
			}
		}
	}
}

fn pack_data_field_int(buffer: &mut Vec<u8>, value: &Value) {
	buffer.push(0);
	buffer.push(value.is_null() as u8);
	
	let make = value.as_i64().unwrap_or(0) as i32;

	buffer.extend_from_slice(&make.to_le_bytes());
}

fn pack_data_field_float(buffer: &mut Vec<u8>, value: &Value) {
	buffer.push(1);
	buffer.push(value.is_null() as u8);
	
	let make = value.as_f64().unwrap_or(0.0);

	buffer.extend_from_slice(&make.to_le_bytes());
}

fn pack_data_field_bool(buffer: &mut Vec<u8>, value: &Value) {
	buffer.push(2);
	buffer.push(value.is_null() as u8);
	
	let make = value.as_bool().unwrap_or(false) as u8;

	buffer.push(make);
}

fn pack_data_field_string(buffer: &mut Vec<u8>, value: &Value) {
	buffer.push(3);
	buffer.push(value.is_null() as u8);

	let make = value.as_str().unwrap_or("");

	buffer.extend_from_slice(make.as_bytes());
	buffer.push(0); // null terminated
}

fn pack_data_field_color(buffer: &mut Vec<u8>, value: &Value) {
	buffer.push(4);
	buffer.push(value.is_null() as u8);

	let make = value.as_str().unwrap_or("#ffffff");
	let make = make.trim_start_matches("#");
	let r = make[0..2].parse::<u8>().unwrap_or(0);
	let g = make[2..4].parse::<u8>().unwrap_or(0);
	let b = make[4..6].parse::<u8>().unwrap_or(0);

	buffer.push(r);
	buffer.push(g);
	buffer.push(b);
}

fn pack_data_field_point(buffer: &mut Vec<u8>, value: &Value) {
	buffer.push(5);
	buffer.push(value.is_null() as u8);

	let make = value.as_object().unwrap();
	let x = make.get("cx").unwrap().as_u64().unwrap() as u32;
	let y = make.get("cy").unwrap().as_u64().unwrap() as u32;
	
	buffer.extend_from_slice(&x.to_le_bytes());
	buffer.extend_from_slice(&y.to_le_bytes());
}

fn pack_data_field_entity(buffer: &mut Vec<u8>, value: &Value) {
	buffer.push(6);
	buffer.push(value.is_null() as u8);

	let make = value.as_object().unwrap();
	let id = make.get("entityIid").unwrap().as_str().unwrap();
	
	buffer.extend_from_slice(id.as_bytes());
	buffer.push(0); // null terminated
}

fn pack_data_level_header(
		buffer: &mut Vec<u8>,
		name: &str, id: &str,
		x: u32, y: u32, width: u32, height: u32,
	) {
	buffer.extend_from_slice(name.as_bytes());
	buffer.push(0); // null terminated

	buffer.extend_from_slice(id.as_bytes());
	buffer.push(0);

	buffer.extend_from_slice(&x.to_le_bytes());
	buffer.extend_from_slice(&y.to_le_bytes());
	buffer.extend_from_slice(&width.to_le_bytes());
	buffer.extend_from_slice(&height.to_le_bytes());
}

fn pack_data_level_layer_grid(buffer: &mut Vec<u8>, size: u32, grab: impl Fn(u32) -> u8) {
	buffer.extend_from_slice(&size.to_le_bytes());
	for t in 0..size {
		buffer.push(grab(t));
	}
}

fn pack_data_level_layer_free(buffer: &mut Vec<u8>, size: u32, grab: impl Fn(u32) -> (u32, i32, i32)) {
	buffer.extend_from_slice(&size.to_le_bytes());
	for t in 0..size {
		let (m, x, y) = grab(t);
		buffer.extend_from_slice(&m.to_le_bytes());
		buffer.extend_from_slice(&x.to_le_bytes());
		buffer.extend_from_slice(&y.to_le_bytes());
	}
}

fn pack_data_level_layer_entity(buffer: &mut Vec<u8>) {}

fn parse_root(json: &Value) -> (Vec<u8>, Vec<&str>) {

	let mut buffer = Vec::<u8>::new();
	let mut refs = Vec::<&str>::new();

	let file = json.as_object().unwrap();
	let levels = file.get("levels").unwrap()
		.as_array().unwrap();

	println!("total levels: {}", levels.len());
	buffer.extend_from_slice(&(levels.len() as u32).to_le_bytes());

	for level in levels {
		let level = level.as_object().unwrap();

		let name = level.get("identifier").unwrap()
				.as_str().unwrap();
		
		let id = level.get("iid").unwrap()
		.as_str().unwrap();

		buffer.extend_from_slice(name.as_bytes());
		buffer.push(0); // null terminated

		buffer.extend_from_slice(id.as_bytes());
		buffer.push(0);

		let x = level.get("worldX").unwrap()
			.as_u64().unwrap();
		let y = level.get("worldY").unwrap()
			.as_u64().unwrap();
		let width = level.get("pxWid").unwrap()
			.as_u64().unwrap();
		let height = level.get("pxHei").unwrap()
			.as_u64().unwrap();

		buffer.extend_from_slice(&(x as u32).to_le_bytes());
		buffer.extend_from_slice(&(y as u32).to_le_bytes());
		buffer.extend_from_slice(&(width as u32).to_le_bytes());
		buffer.extend_from_slice(&(height as u32).to_le_bytes());

		parse_field(level.get("fieldInstances").unwrap(), &mut buffer);

		refs.push(name);

		// buffer.append(&mut parse_room(&room_json));

	}

	let toc = file.get("toc").unwrap().as_array().unwrap();

	let mut toc_count = 0;
	for item in toc {
		let item = item.as_object().unwrap();
		let item= item.get("instancesData").unwrap().as_array().unwrap();
		toc_count += item.len();
	}

	println!("total toc: {}", toc_count);
	buffer.extend_from_slice(&(toc_count as u32).to_le_bytes());

	for item in toc {
		let item = item.as_object().unwrap();

		let kind = item.get("identifier").unwrap().as_str().unwrap();

		for item in item.get("instancesData").unwrap().as_array().unwrap() {
			let item = item.as_object().unwrap();

			let id = item.get("iids").unwrap()
				.as_object().unwrap()
				.get("entityIid").unwrap()
				.as_str().unwrap();

			let x = item.get("worldX").unwrap().as_u64().unwrap() as u32;
			let y = item.get("worldY").unwrap().as_u64().unwrap() as u32;
			let width = item.get("widPx").unwrap().as_u64().unwrap() as u32;
			let height = item.get("heiPx").unwrap().as_u64().unwrap() as u32;

			buffer.extend_from_slice(kind.as_bytes());
			buffer.push(0);

			buffer.extend_from_slice(id.as_bytes());
			buffer.push(0);

			buffer.extend_from_slice(&x.to_le_bytes());
			buffer.extend_from_slice(&y.to_le_bytes());
			buffer.extend_from_slice(&width.to_le_bytes());
			buffer.extend_from_slice(&height.to_le_bytes());

			let fields = item.get("fields").unwrap()
				.as_object().unwrap();

			match kind {
				"obj_checkpoint" => { // obj_checkpoint
					let index = fields.get("index").unwrap().as_str().unwrap();

					buffer.extend_from_slice(index.as_bytes());
					buffer.push(0);
				},
				"obj_timer_start" => { // obj_timer_start
					let name = fields.get("name").unwrap().as_str().unwrap();
					let time = fields.get("time").unwrap().as_f64().unwrap() as f32;
					let dir = fields.get("dir").unwrap().as_str().unwrap();
					let other = fields.get("ref").unwrap()
						.as_object().unwrap()
						.get("entityIid").unwrap()
						.as_str().unwrap();

					buffer.extend_from_slice(name.as_bytes());
					buffer.push(0);

					buffer.extend_from_slice(&time.to_le_bytes());

					buffer.extend_from_slice(dir.as_bytes());
					buffer.push(0);

					buffer.extend_from_slice(other.as_bytes());
					buffer.push(0);
				},
				_ => (),
			}
		}

	}

	(buffer, refs)
}



fn parse_room(json: &Value) -> Vec<u8> {

	let mut buffer = Vec::<u8>::new();

	let json = json.as_object().unwrap();

	let name = json.get("identifier").unwrap().as_str().unwrap();
	let id = json.get("iid").unwrap().as_str().unwrap();

	println!("{}", name);

	let x = json.get("worldX").unwrap().as_u64().unwrap();
	let y = json.get("worldY").unwrap().as_u64().unwrap();
	let width = json.get("pxWid").unwrap().as_u64().unwrap();
	let height = json.get("pxHei").unwrap().as_u64().unwrap();

	buffer.extend_from_slice(name.as_bytes());
	buffer.push(0); // null terminated

	buffer.extend_from_slice(id.as_bytes());
	buffer.push(0); // null terminated

	buffer.extend_from_slice(&(x as u32).to_le_bytes());
	buffer.extend_from_slice(&(y as u32).to_le_bytes());
	buffer.extend_from_slice(&(width as u32).to_le_bytes());
	buffer.extend_from_slice(&(height as u32).to_le_bytes());

	let layers = json.get("layerInstances").unwrap().as_array().unwrap();

	buffer.push(layers.len() as u8);

	for layer in layers {
		parse_layer(layer, &mut buffer);
	}

	buffer
}

fn parse_layer(json: &Value, buffer: &mut Vec<u8>) {

	let json = json.as_object().unwrap();

	let name = json.get("__identifier").unwrap().as_str().unwrap();

	buffer.extend_from_slice(name.as_bytes());
	buffer.push(0); // null terminated

	let layertype = json.get("__type").unwrap().as_str().unwrap();

	match layertype {
		"IntGrid" => {
			buffer.push(0);

			let grid = json.get("intGridCsv").unwrap().as_array().unwrap();

			let width = json.get("__cWid").unwrap().as_u64().unwrap();
			let height = json.get("__cHei").unwrap().as_u64().unwrap();

			let size = width * height;
			buffer.extend_from_slice(&(size as u32).to_le_bytes());

			for t in grid {
				let t = t.as_u64().unwrap();
				buffer.push(t as u8);
			}
		},
		"Entities" => {
			buffer.push(1);

			let entities = json.get("entityInstances").unwrap().as_array().unwrap();
			
			let size = entities.len();
			buffer.extend_from_slice(&(size as u32).to_le_bytes());

			for e in entities {
				let e = e.as_object().unwrap();

				let name = e.get("__identifier").unwrap().as_str().unwrap();
				let id = e.get("iid").unwrap().as_str().unwrap();

				let tags = e.get("__tags").unwrap().as_array().unwrap();
				
				let x = e.get("__worldX").unwrap().as_u64().unwrap();
				let y = e.get("__worldY").unwrap().as_u64().unwrap();
				let width = e.get("width").unwrap().as_u64().unwrap();
				let height = e.get("height").unwrap().as_u64().unwrap();

				buffer.extend_from_slice(name.as_bytes());
				buffer.push(0); // null terminated

				buffer.extend_from_slice(id.as_bytes());
				buffer.push(0); // null terminated

				buffer.push(tags.len() as u8);
				for tag in tags {
					let tag = tag.as_str().unwrap();
					buffer.extend_from_slice(tag.as_bytes());
					buffer.push(0);
				}

				buffer.extend_from_slice(&(x as u32).to_le_bytes());
				buffer.extend_from_slice(&(y as u32).to_le_bytes());
				buffer.extend_from_slice(&(width as u32).to_le_bytes());
				buffer.extend_from_slice(&(height as u32).to_le_bytes());

				parse_field(e.get("fieldInstances").unwrap(), buffer);

			}
			
		},
		"Tiles" => {
			buffer.push(2);

			let tiles = json.get("gridTiles").unwrap().as_array().unwrap();
			
			let size = tiles.len();
			buffer.extend_from_slice(&(size as u32).to_le_bytes());

			println!("tile: {}", size);

			for t in tiles {
				let t = t.as_object().unwrap();

				let px = t.get("px").unwrap().as_array().unwrap();
				let x = px[0].as_i64().unwrap();
				let y = px[1].as_i64().unwrap();
				let m = t.get("t").unwrap().as_u64().unwrap();

				buffer.extend_from_slice(&(m as u32).to_le_bytes());
				buffer.extend_from_slice(&(x as i32).to_le_bytes());
				buffer.extend_from_slice(&(y as i32).to_le_bytes());
			}
		},
		"AutoLayer" => {
			buffer.push(3);

			let tiles = json.get("autoLayerTiles").unwrap().as_array().unwrap();
			
			let size = tiles.len();
			buffer.extend_from_slice(&(size as u32).to_le_bytes());

			println!("auto: {}", size);

			for t in tiles {
				let t = t.as_object().unwrap();

				let px = t.get("px").unwrap().as_array().unwrap();
				let x = px[0].as_i64().unwrap();
				let y = px[1].as_i64().unwrap();
				let m = t.get("t").unwrap().as_u64().unwrap();

				buffer.extend_from_slice(&(m as u32).to_le_bytes());
				buffer.extend_from_slice(&(x as i32).to_le_bytes());
				buffer.extend_from_slice(&(y as i32).to_le_bytes());
			}
		},
		_ => panic!("what the fuck"),
	}


}


fn parse_field(json: &Value, buffer: &mut Vec<u8>) {
	let fields = json.as_array().unwrap();
	buffer.extend_from_slice(&(fields.len() as u8).to_le_bytes());
	for field in fields {
		parse_field_array(field, buffer);
	}
}

fn parse_field_array(json: &Value, buffer: &mut Vec<u8>) {

	let field = json.as_object().unwrap();

	let j_name = field.get("__identifier").unwrap().as_str().unwrap();
	let j_type = field.get("__type").unwrap().as_str().unwrap();
	let j_part = field.get("__value").unwrap();

	buffer.extend_from_slice(j_name.as_bytes());
	buffer.push(0); // null terminated

	if j_type.starts_with("Array") {
		let j_type_in = j_type
			.trim_start_matches("Array<")
			.trim_end_matches(">");

		let j_part = j_part.as_array().unwrap();

		buffer.push(255);
		buffer.push(0);

		let kind = match j_type_in {
			"Int" => 0,
			"Float" => 1,
			"Bool" => 2,
			"String" => 3,
			"Color" => 4,
			"Point" => 5,
			"EntityRef" => 6,
			_ => if j_type_in.starts_with("LocalEnum") {
				3
			} else {
				todo!()
			},
		};
		buffer.push(kind);
		buffer.push(j_part.len() as u8);

		for val in j_part {
			parse_field_instance(val, j_type_in, buffer);
		}
	} else {
		let kind = match j_type {
			"Int" => 0,
			"Float" => 1,
			"Bool" => 2,
			"String" => 3,
			"Color" => 4,
			"Point" => 5,
			"EntityRef" => 6,
			_ => if j_type.starts_with("LocalEnum") {
				3
			} else {
				todo!()
			},
		};
		buffer.push(kind);
		parse_field_instance(j_part, j_type, buffer);
	}


}

fn parse_field_instance(value: &Value, kind: &str, buffer: &mut Vec<u8>) {

	match kind {
		"Int" => {
			buffer.push(if value.is_null() { 1 } else { 0 });
			let make = value.as_i64().unwrap_or(0);
			buffer.extend_from_slice(&(make as i32).to_le_bytes());
		},
		"Float" => {
			buffer.push(if value.is_null() { 1 } else { 0 });
			let make = value.as_f64().unwrap_or(0.0);
			buffer.extend_from_slice(&make.to_le_bytes());
		},
		"Bool" => {
			buffer.push(if value.is_null() { 1 } else { 0 });
			let make = value.as_bool().unwrap_or(false);
			buffer.push(if make { 1 } else { 0 });
		},
		"Color" => {
			buffer.push(if value.is_null() { 1 } else { 0 });
			let make = value.as_str().unwrap_or("#ffffff");
			let make = make.trim_start_matches("#");
			let r = make[0..2].parse::<u8>().unwrap_or(0);
			let g = make[2..4].parse::<u8>().unwrap_or(0);
			let b = make[4..6].parse::<u8>().unwrap_or(0);
			buffer.push(r);
			buffer.push(g);
			buffer.push(b);
		},
		"Point" => {
			buffer.push(if value.is_null() { 1 } else { 0 });
			let make = value.as_object().unwrap();
			let x = make.get("cx").unwrap().as_u64().unwrap() as u32;
			let y = make.get("cy").unwrap().as_u64().unwrap() as u32;
			buffer.extend_from_slice(&x.to_le_bytes());
			buffer.extend_from_slice(&y.to_le_bytes());
		},
		"EntityRef" => {
			buffer.push(if value.is_null() { 1 } else { 0 });
			let make = value.as_object().unwrap();
			let id = make.get("entityIid").unwrap().as_str().unwrap();
			buffer.extend_from_slice(id.as_bytes());
			buffer.push(0); // null terminated
		},
		_ => {
			if kind.starts_with("String") || kind.starts_with("LocalEnum") {
				buffer.push(if value.is_null() { 1 } else { 0 });
				let make = value.as_str().unwrap_or("");
				buffer.extend_from_slice(make.as_bytes());
				buffer.push(0); // null terminated
			} else {
				todo!("{}", kind);
			}
		}
	}

}


/*

for (var i = 0; i < array_length(_file.levels); i++) {
	var _level = new Level();
	
	var _time = get_timer();
	var _file_level = game_json_open(_file.levels[i].externalRelPath);
	show_debug_message("level file: {0}", (get_timer() - _time) / 1000)
	
	_level.init(_file_level, _file.defs);
	
	array_push(levels, _level);
	
	delete _file_level;
}

for (var i_table = 0; i_table < array_length(_file.toc); i_table++) {
	
	var _item = _file.toc[i_table]
	
	for (var i_inst = 0; i_inst < array_length(_item.instancesData); i_inst++) {
		
		var _ent = _item.instancesData[i_inst]
		var _field = {}
		
		var _val = _ent.fields;
		
		switch _item.identifier {
			case nameof(obj_checkpoint):
				_field.index = level_ldtk_field_item(_val.index, "String");
				break;
			case nameof(obj_timer_start):
				_field.name = level_ldtk_field_item(_val.name, "String");
				_field.time = level_ldtk_field_item(_val.time, "Float");
				_field.dir = level_ldtk_field_item(_val.dir, "Enum");
				_field.ref = level_ldtk_field_item(_val.ref, "EntityRef");
				
				_field.image_xscale = floor(_ent.widPx / TILESIZE);
				_field.image_yscale = floor(_ent.heiPx / TILESIZE);
				break;
			case nameof(obj_timer_end):
				_field.image_xscale = floor(_ent.widPx / TILESIZE);
				_field.image_yscale = floor(_ent.heiPx / TILESIZE);
				break;
		}
		
		_field.uid = _ent.iids.entityIid;
		
		var _inst = instance_create_layer(
			_ent.worldX, _ent.worldY,
			"Instances",
			asset_get_index(_item.identifier),
			_field
		);
		
		global.entities[$ _ent.iids.entityIid] = _inst
		global.entities_toc[$ _ent.iids.entityIid] = _inst
		
	}
}

*/


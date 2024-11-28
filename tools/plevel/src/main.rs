
use pack::Pack;
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


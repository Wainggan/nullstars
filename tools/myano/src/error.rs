
pub struct Reporter {
	error: bool,
	list: Vec<Error>,
}

impl Reporter {
	pub fn new() -> Reporter {
		Reporter {
			error: false,
			list: Vec::new(),
		}
	}

	pub fn error(&mut self, message: String) {
		self.error = true;
		self.list.push(Error {
			message,
		});
	}

	pub fn valid(&self) -> bool {
		!self.error
	}

	pub fn print(&self) {
		if self.error {
			for error in &self.list {
				println!("error: {}", error.message);
			}
		} else {
			println!("no errors!! :3")
		}
	}
}

struct Error {
	message: String,
}


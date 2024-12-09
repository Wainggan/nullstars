
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

	pub fn print(&self) {
		for error in &self.list {
			println!("error: {}", error.message);
		}
	}
}

struct Error {
	message: String,
}


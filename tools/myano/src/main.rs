
enum Token<'a> {
	Number(&'a str),
	Add,
}

struct Lexer {
	source: String,
	current: usize,
	start: usize,
}

impl Lexer {
	fn new(src: &str) -> Lexer {
		Lexer {
			source: src.to_string(),
			current: 0,
			start: 0,
		}
	}
	fn advance(&mut self) -> Option<char> {
		if self.current == self.source.len() {
			return None;
		}
		let out = self.source.chars().nth(self.current);
		self.current += 1;
		return out;
	}
	fn next(&mut self) -> Token {
		self.start = self.current;
		Token {}
	}
}



fn main() {

}



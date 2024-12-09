
#[derive(Debug)]
enum Token {
	Eof,
	Number(String),
	Add,
	Sub,
	Star,
	Slash,
}

struct Lexer {
	tokens: Vec<Token>,
	source: String,
	current: usize,
	start: usize,
}

impl Lexer {
	fn new(src: &str) -> Lexer {
		Lexer {
			tokens: Vec::new(),
			source: src.to_string(),
			current: 0,
			start: 0,
		}
	}

	fn at_end(&self) -> bool {
		self.current >= self.source.len()
	}

	fn get(&self, at: usize) -> Option<char> {
		self.source.chars().nth(at)
	}
	fn peek_offset(&self, offset: usize) -> Option<char> {
		if self.at_end() {
			None
		} else {
			self.get(self.current + offset)
		}
	}
	fn peek(&self) -> Option<char> {
		self.peek_offset(0)
	}
	fn advance(&mut self) -> Option<char> {
		if self.current == self.source.len() {
			return None;
		}
		let out = self.get(self.current);
		self.current += 1;
		return out;
	}

	fn compare(&mut self, expected: char) -> bool {
		if self.at_end() {
			return false;
		}
		if self.get(self.current) != Some(expected) {
			return false;
		}
		self.current += 1;
		return true;
	}

	fn is_number(&self, c: Option<char>) -> bool {
		match c {
			None => false,
			Some(c) => c.is_numeric()
		}
	}
	fn is_whitespace(&self, c: Option<char>) -> bool {
		match c {
			None => false,
			Some(c) => c.is_whitespace()
		}
	}

	fn add(&mut self, token: Token) {
		self.tokens.push(token);
	}

	fn consume_whitespace(&mut self) {
		while self.is_whitespace(self.peek()) {
			self.advance();
		}
	}

	fn consume_number(&mut self) -> Token {
		while self.is_number(self.peek()) {
			self.advance();
		}
		if self.peek() == Some('.') &&
		self.peek_offset(1).unwrap_or(' ').is_numeric() {
			self.advance();
			while self.is_number(self.peek()) {
				self.advance();
			}
			Token::Number(self.source[self.start..self.current].to_string())
		} else {
			Token::Number(self.source[self.start..self.current].to_string())
		}
	}

	fn next(&mut self) {
		self.start = self.current;

		let c = match self.advance() {
			None => return,
			Some(c) => c,
		};

		match c {
			'+' => self.add(Token::Add),
			'-' => self.add(Token::Sub),
			'*' => self.add(Token::Star),
			'/' => self.add(Token::Slash),
			_ => {
				if c.is_whitespace() {
					self.consume_whitespace();
					return;
				}
				if c.is_numeric() {
					let token = self.consume_number();
					self.add(token);
					return;
				}
				panic!("oops {}", c);
			}
		}

	}

	fn run(&mut self) {
		while !self.at_end() {
			self.next();
		}
	}
}

fn tokenize(source: &str) -> Vec<Token> {
	let mut lexer = Lexer::new(source);
	lexer.run();
	lexer.tokens
}



fn main() {
	let tokens = tokenize("1 + 1 - 2 + 3.3 --4 -- 3 33 4");
	println!("{:?}", tokens);
}



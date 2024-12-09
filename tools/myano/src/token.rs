
use crate::error;

#[derive(Debug, PartialEq, Clone)]
pub struct Token {
	pub kind: TT,
	pub innr: String,
}

#[derive(Debug, PartialEq, Clone, Copy)]
pub enum TT {
	Eof,

	Semicolon,
	Dot,

	Identifier,
	Integer,
	Float,

	Let,
	
	LParen,
	RParen,

	Add,
	Sub,
	Star,
	Slash,
	
	Equal,
	EqualEqual,
	Lesser,
	Greater,
	LesserEqual,
	GreaterEqual,
	
	Bang,
	BangEqual,
}

impl std::fmt::Display for Token {
	fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
		write!(f,
			"({})",
			match self.kind {
				TT::Eof => "<eof>",

				TT::Semicolon => ";",
				TT::Dot => ".",

				TT::Let => "let",
				
				TT::Add => "+",
				TT::Sub => "-",
				TT::Star => "*",
				TT::Slash => "/",
				
				TT::Equal => "=",
				TT::EqualEqual => "==",
				TT::Lesser => "<",
				TT::Greater => ">",
				TT::LesserEqual => "<=",
				TT::GreaterEqual => ">=",
				
				TT::Bang => "!",
				TT::BangEqual => "!=",
				
				TT::LParen => "'('",
				TT::RParen => "')'",
				
				TT::Identifier => &self.innr,
				TT::Integer => &self.innr,
				TT::Float => &self.innr,
			},
		)
	}
}

pub fn tokenize(reporter: &mut error::Reporter, source: &str) -> Vec<Token> {
	if !reporter.valid() {
		return Vec::new();
	}
	let mut lexer = Lexer::new(source, reporter);
	lexer.run();
	lexer.tokens
}


struct Lexer<'a> {
	tokens: Vec<Token>,
	reporter: &'a mut error::Reporter,
	source: String,
	current: usize,
	start: usize,
}

impl Lexer<'_> {
	fn new<'a>(src: &str, reporter: &'a mut error::Reporter) -> Lexer<'a> {
		Lexer {
			tokens: Vec::new(),
			reporter,
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

	fn is_alpha(&self, c: Option<char>) -> bool {
		match c {
			None => false,
			Some(c) => c == '_' || c.is_alphabetic()
		}
	}
	fn is_number(&self, c: Option<char>) -> bool {
		match c {
			None => false,
			Some(c) => c.is_numeric()
		}
	}
	fn is_alphanumber(&self, c: Option<char>) -> bool {
		self.is_number(c) || self.is_alpha(c)
	}
	fn is_whitespace(&self, c: Option<char>) -> bool {
		match c {
			None => false,
			Some(c) => c.is_whitespace()
		}
	}

	fn make(&self) -> String {
		self.source[self.start..self.current].to_string()
	}
	fn add(&mut self, kind: TT) {
		let make = self.make();
		self.add_from(kind, make);
	}
	fn add_from(&mut self, kind: TT, make: String) {
		self.tokens.push(Token {
			kind,
			innr: make.to_string()
		});
	}

	fn consume_whitespace(&mut self) {
		while self.is_whitespace(self.peek()) {
			self.advance();
		}
	}

	fn consume_number(&mut self) {
		while self.is_number(self.peek()) {
			self.advance();
		}
		if self.peek() == Some('.') {
			self.advance();
			while self.is_number(self.peek()) {
				self.advance();
			}
			self.add(TT::Float);
		} else {
			self.add(TT::Integer);
		}
	}

	fn consume_identifier(&mut self) {
		while self.is_alphanumber(self.peek()) {
			self.advance();
		}
		let make = self.make();
		match make.as_str() {
			"let" => self.add_from(TT::Let, make),
			_ => self.add_from(TT::Identifier, make),
		};
	}

	fn next(&mut self) {
		self.start = self.current;

		let c = match self.advance() {
			None => return,
			Some(c) => c,
		};

		match c {
			';' => self.add(TT::Semicolon),
			'.' => self.add(TT::Dot),

			'+' => self.add(TT::Add),
			'-' => self.add(TT::Sub),
			'*' => self.add(TT::Star),
			'/' => self.add(TT::Slash),

			'!' => if self.compare('=') {
				self.add(TT::BangEqual)
			} else {
				self.add(TT::Bang)
			},
			'=' => if self.compare('=') {
				self.add(TT::EqualEqual)
			} else {
				self.add(TT::Equal)
			},

			'<' => if self.compare('=') {
				self.add(TT::LesserEqual)
			} else {
				self.add(TT::Lesser)
			},
			'>' => if self.compare('=') {
				self.add(TT::GreaterEqual)
			} else {
				self.add(TT::Greater)
			},

			'(' => self.add(TT::LParen),
			')' => self.add(TT::RParen),

			_ => {
				if self.is_whitespace(Some(c)) {
					self.consume_whitespace();
					return;
				}
				if self.is_number(Some(c)) {
					self.consume_number();
					return;
				}
				if self.is_alpha(Some(c)) {
					self.consume_identifier();
					return;
				}
				self.reporter.error(format!("unknown character: {}", c));
			}
		}

	}

	fn run(&mut self) {
		while !self.at_end() {
			self.next();
		}
		self.add(TT::Eof);
	}
}


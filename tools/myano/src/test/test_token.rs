
use crate::error::Reporter;
use crate::token::{tokenize, Token, TT};

macro_rules! token {
	($a:expr) => {
		Token {
			kind: $a,
			innr: "".to_string(),
		}
	};
	($a:expr, $b:literal) => {
		Token {
			kind: $a,
			innr: $b.to_string(),
		}
	}
}

#[test]
fn test_empty() {
	let mut reporter = Reporter::new();
	assert_eq!(
		tokenize(&mut reporter, ""),
		vec![
			token!(TT::Eof),
		]
	);
}

#[test]
fn test_ints() {
	let mut reporter = Reporter::new();
	assert_eq!(
		tokenize(&mut reporter, "0 1 2 3 4 5 6 7 8 9 00 10 99"),
		vec![
			token!(TT::Integer, "0"),
			token!(TT::Integer, "1"),
			token!(TT::Integer, "2"),
			token!(TT::Integer, "3"),
			token!(TT::Integer, "4"),
			token!(TT::Integer, "5"),
			token!(TT::Integer, "6"),
			token!(TT::Integer, "7"),
			token!(TT::Integer, "8"),
			token!(TT::Integer, "9"),
			token!(TT::Integer, "00"),
			token!(TT::Integer, "10"),
			token!(TT::Integer, "99"),
			token!(TT::Eof, "99"), // temp
		]
	);
}

#[test]
fn test_floats() {
	let mut reporter = Reporter::new();
	assert_eq!(
		tokenize(&mut reporter, "1.0 1. 0 . 1"),
		vec![
			token!(TT::Float, "1.0"),
			token!(TT::Float, "1."),
			token!(TT::Integer, "0"),
			token!(TT::Dot, "."),
			token!(TT::Integer, "1"),
			token!(TT::Eof, "1"), // temp
		]
	);
}


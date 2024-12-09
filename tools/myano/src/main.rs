
mod error;
mod token;
mod parse;

#[cfg(test)]
mod test;

fn main() {
	let mut reporter = error::Reporter::new();

	let tokens = token::tokenize(&mut reporter, "(2 - 3) < > == >= <= ! * 2");

	reporter.print();

	println!("{:?}", tokens);
}


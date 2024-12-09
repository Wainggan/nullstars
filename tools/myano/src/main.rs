use parse::Visitor;


mod error;
mod token;
mod parse;

#[cfg(test)]
mod test;

fn main() {
	let mut reporter = error::Reporter::new();

	let tokens = token::tokenize(&mut reporter, "(2 - 3) < > == >= <= ! * 2");

	let ast = parse::parse(&mut reporter, &tokens);

	println!("{:?}", ast);

	reporter.print();

	println!("{:?}", tokens);
}


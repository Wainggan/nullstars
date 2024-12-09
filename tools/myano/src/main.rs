
mod error;
mod token;
mod parse;
mod evaluate;

#[cfg(test)]
mod test;

fn main() {
	let mut reporter = error::Reporter::new();

	let tokens = token::tokenize(&mut reporter, "let a");
	println!("{:?}", tokens);

	let ast = parse::parse(&mut reporter, &tokens);
	println!("{:?}", ast);

	let value = evaluate::test(&mut reporter, &ast);
	println!("{}", value);

	reporter.print();
}


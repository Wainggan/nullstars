use parse::Visitor;


mod error;
mod token;
mod parse;

#[cfg(test)]
mod test;

fn main() {
	let mut reporter = error::Reporter::new();

	let tokens = token::tokenize(&mut reporter, "(2 - 3) < > == >= <= ! * 2");

	let ast = parse::Node::Module(vec![
		parse::Node::Binary(
			token::Token::Add,
			Box::new(parse::Node::Lit_Int(10)),
			Box::new(parse::Node::Lit_Int(10)),
		)
	]);

	let mut eval = parse::Evaluate;
	let out = eval.accept(&ast);

	println!("=> {}", out);

	reporter.print();

	println!("{:?}", tokens);
}


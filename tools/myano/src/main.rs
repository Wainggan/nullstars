
mod token;

#[cfg(test)]
mod test;

fn main() {
	let tokens = token::tokenize("1 + 1 - 2 + 3.3 --4 -- 3 33 4");
	println!("{:?}", tokens);
}



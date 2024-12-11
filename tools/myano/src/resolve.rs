
use crate::expr::{ self, Visitor, Node };

struct Resolve {
}
impl Resolve {
	fn new() -> Resolve {
		Resolve {
		}
	}
}
impl Visitor for Resolve {
    type Result = ();

    fn visit_module(&mut self, node: &expr::Module) -> Self::Result {
		todo!()
    }

    fn visit_let(&mut self, node: &expr::Let) -> Self::Result {
        todo!()
    }

    fn visit_if(&mut self, node: &expr::If) -> Self::Result {
        todo!()
    }

    fn visit_while(&mut self, node: &expr::While) -> Self::Result {
        todo!()
    }

    fn visit_block(&mut self, node: &expr::Block) -> Self::Result {
        todo!()
    }

    fn visit_group(&mut self, node: &expr::Group) -> Self::Result {
        todo!()
    }

    fn visit_assign(&mut self, node: &expr::Assign) -> Self::Result {
        todo!()
    }

    fn visit_binary(&mut self, node: &expr::Binary) -> Self::Result {
        todo!()
    }

    fn visit_unary(&mut self, node: &expr::Unary) -> Self::Result {
        todo!()
    }

    fn visit_call(&mut self, node: &expr::Call) -> Self::Result {
        todo!()
    }

    fn visit_identifier(&mut self, node: &expr::Identifer) -> Self::Result {
        todo!()
    }

    fn visit_lit_int(&mut self, node: &expr::LitInt) -> Self::Result {
        todo!()
    }

    fn visit_lit_flt(&mut self, node: &expr::LitFlt) -> Self::Result {
        todo!()
    }
}


pub fn resolve(reporter: &mut crate::error::Reporter, ast: &expr::Node) {
	if !reporter.valid() {
		return;
	}
	let mut test = Resolve::new();
	test.resolve(ast);
}




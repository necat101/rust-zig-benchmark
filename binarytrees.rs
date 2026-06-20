use std::env;

struct Node {
    left: Option<Box<Node>>,
    right: Option<Box<Node>>,
}

impl Node {
    fn new(depth: usize) -> Self {
        if depth == 0 {
            Node { left: None, right: None }
        } else {
            Node {
                left: Some(Box::new(Node::new(depth - 1))),
                right: Some(Box::new(Node::new(depth - 1))),
            }
        }
    }
    
    fn check(&self) -> i32 {
        match (&self.left, &self.right) {
            (None, None) => 1,
            (Some(l), Some(r)) => 1 + l.check() + r.check(),
            _ => 0,
        }
    }
}

fn main() {
    let n = env::args()
        .nth(1)
        .and_then(|s| s.parse::<usize>().ok())
        .unwrap_or(20);
    
    let min_depth = 4;
    let max_depth = if min_depth + 2 > n { min_depth + 2 } else { n };
    
    let stretch_depth = max_depth + 1;
    let stretch_tree = Node::new(stretch_depth);
    println!("stretch tree of depth {}\t check: {}", 
             stretch_depth, stretch_tree.check());
    
    let long_lived_tree = Node::new(max_depth);
    
    let mut depth = min_depth;
    while depth <= max_depth {
        let iterations = 1 << (max_depth - depth + min_depth);
        let mut check = 0;
        
        for _ in 0..iterations {
            let tree = Node::new(depth);
            check += tree.check();
        }
        
        println!("{}\t trees of depth {}\t check: {}", 
                 iterations, depth, check);
        
        depth += 2;
    }
    
    println!("long lived tree of depth {}\t check: {}", 
             max_depth, long_lived_tree.check());
}
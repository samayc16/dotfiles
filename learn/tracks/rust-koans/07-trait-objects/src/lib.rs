//! Koan 07: trait objects.

/// One step of a text pipeline.
pub trait Transform {
    fn apply(&self, input: &str) -> String;
}

/// Uppercases everything.
pub struct Upper;

/// Repeats the input n times.
pub struct Repeat(pub usize);

/// Replaces every `from` with `to`.
pub struct Replace {
    pub from: String,
    pub to: String,
}

impl Transform for Upper {
    fn apply(&self, input: &str) -> String {
        todo!()
    }
}

impl Transform for Repeat {
    fn apply(&self, input: &str) -> String {
        todo!()
    }
}

impl Transform for Replace {
    fn apply(&self, input: &str) -> String {
        todo!()
    }
}

/// Steps of different concrete types in ONE Vec: that takes `Box<dyn Transform>`.
#[derive(Default)]
pub struct Pipeline {
    steps: Vec<Box<dyn Transform>>,
}

impl Pipeline {
    pub fn new() -> Self {
        Self::default()
    }

    /// Adds a step and hands the pipeline back: `Pipeline::new().then(a).then(b)`.
    pub fn then(self, step: Box<dyn Transform>) -> Self {
        todo!()
    }

    pub fn step_count(&self) -> usize {
        todo!()
    }

    /// Runs every step in order, feeding each one's output to the next.
    pub fn run(&self, input: &str) -> String {
        todo!()
    }
}

/// Builds a step from a spec: "upper", "repeat 3" or "replace a b". The concrete type
/// depends on runtime data, so the function returns a trait object.
pub fn parse_step(spec: &str) -> Option<Box<dyn Transform>> {
    todo!()
}

/// Applies each step to `input` on its own and adds up the output lengths.
/// `&dyn Transform` borrows a trait object: no Box needed when you don't own it.
pub fn total_len(steps: &[&dyn Transform], input: &str) -> usize {
    todo!()
}

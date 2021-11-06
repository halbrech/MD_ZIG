
// Leonnard Jones Potential Argonium:
const EPSILON : f32 = 1.0;
const SIGMA : f32 = 1.0;
pub const A : f32 = 4*EPSILON*SIGMA*SIGMA*SIGMA*SIGMA*SIGMA*SIGMA*SIGMA*SIGMA*SIGMA*SIGMA*SIGMA*SIGMA;
pub const B : f32 = 4*EPSILON*SIGMA*SIGMA*SIGMA*SIGMA*SIGMA*SIGMA;
pub const A_FORCE : f32 = 12*A;
pub const B_FORCE : f32 = 6*B;


pub const BOX_WIDTH : u32 = 50;
pub const BOX_HEIGHT : u32 = 50;
pub const BOX_LENGTH: u32 = 50;
pub const NUM_PARTICLES : u32 = 50;
pub const DELTA_TIME : f32 = 1e-3;
pub const NUM_STEPS : u32 = 10000000;

pub const MASS = 1;
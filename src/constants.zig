
// Leonnard Jones Potential Argonium:
const EPSILON : f64 = 1.0;
const SIGMA : f64 = 1.0;
pub const A : f64 = 4*EPSILON*SIGMA*SIGMA*SIGMA*SIGMA*SIGMA*SIGMA*SIGMA*SIGMA*SIGMA*SIGMA*SIGMA*SIGMA;
pub const B : f64 = 4*EPSILON*SIGMA*SIGMA*SIGMA*SIGMA*SIGMA*SIGMA;
pub const A_FORCE : f64 = 12*A;
pub const B_FORCE : f64 = 6*B;


pub const BOX_WIDTH : u32 = 20;
pub const BOX_HEIGHT : u32 = 20;
pub const BOX_LENGTH: u32 = 20;
pub const NUM_PARTICLES : u32 = 500;
pub const DELTA_TIME : f64 = 5e-3;
pub const NUM_STEPS : u32 = 50000;
pub const SNSH_FREQ : u32 = 10;
pub const PERIODIC_BOUNDARY : bool = true;

pub const MASS = 1;
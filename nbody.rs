use std::f64::consts::PI;

const SOLAR_MASS: f64 = 4.0 * PI * PI;
const DAYS_PER_YEAR: f64 = 365.24;

#[derive(Clone, Copy)]
struct Body {
    x: f64,
    y: f64,
    z: f64,
    vx: f64,
    vy: f64,
    vz: f64,
    mass: f64,
}

impl Body {
    fn new(x: f64, y: f64, z: f64, vx: f64, vy: f64, vz: f64, mass: f64) -> Self {
        Body { x, y, z, vx, vy, vz, mass }
    }
}

fn advance(bodies: &mut [Body], dt: f64) {
    let n = bodies.len();
    for i in 0..n {
        for j in i + 1..n {
            let dx = bodies[i].x - bodies[j].x;
            let dy = bodies[i].y - bodies[j].y;
            let dz = bodies[i].z - bodies[j].z;
            
            let dist_sq = dx * dx + dy * dy + dz * dz;
            let dist = dist_sq.sqrt();
            let mag = dt / (dist_sq * dist);
            
            bodies[i].vx -= dx * bodies[j].mass * mag;
            bodies[i].vy -= dy * bodies[j].mass * mag;
            bodies[i].vz -= dz * bodies[j].mass * mag;
            
            bodies[j].vx += dx * bodies[i].mass * mag;
            bodies[j].vy += dy * bodies[i].mass * mag;
            bodies[j].vz += dz * bodies[i].mass * mag;
        }
    }
    
    for body in bodies.iter_mut() {
        body.x += dt * body.vx;
        body.y += dt * body.vy;
        body.z += dt * body.vz;
    }
}

fn energy(bodies: &[Body]) -> f64 {
    let mut e = 0.0;
    let n = bodies.len();
    
    for i in 0..n {
        let bi = &bodies[i];
        e += 0.5 * bi.mass * (bi.vx * bi.vx + bi.vy * bi.vy + bi.vz * bi.vz);
        
        for j in i + 1..n {
            let bj = &bodies[j];
            let dx = bi.x - bj.x;
            let dy = bi.y - bj.y;
            let dz = bi.z - bj.z;
            let dist = (dx * dx + dy * dy + dz * dz).sqrt();
            e -= bi.mass * bj.mass / dist;
        }
    }
    
    e
}

fn offset_momentum(bodies: &mut [Body]) {
    let (mut px, mut py, mut pz) = (0.0, 0.0, 0.0);
    
    for body in &bodies[0..4] {
        px += body.vx * body.mass;
        py += body.vy * body.mass;
        pz += body.vz * body.mass;
    }
    
    bodies[4].vx = -px / SOLAR_MASS;
    bodies[4].vy = -py / SOLAR_MASS;
    bodies[4].vz = -pz / SOLAR_MASS;
}

fn main() {
    let n = std::env::args()
        .nth(1)
        .and_then(|s| s.parse::<usize>().ok())
        .unwrap_or(1000000);
    
    let mut bodies = [
        // Sun
        Body::new(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, SOLAR_MASS),
        // Jupiter
        Body::new(
            4.841431442464721,
            -1.1603200440274284,
            -0.10362204447112311,
            0.0016600764578451321,
            0.007699011184197091,
            -0.00006904600108300421,
            0.0009547919384243274,
        ),
        // Saturn
        Body::new(
            8.343366718244578,
            4.124798564124305,
            -0.40352341711432277,
            -0.0027674251075562036,
            0.004998528012349172,
            0.000023041729564993395,
            0.0002858859806661308,
        ),
        // Uranus
        Body::new(
            12.894369562139131,
            -15.1111514016986,
            -0.22330757889265573,
            0.002964243688581652,
            0.0023784717395940443,
            -0.0000296589569679825,
            0.00004366244043351492,
        ),
        // Neptune
        Body::new(
            15.379697114850916,
            -25.91931460998798,
            0.17925877295037118,
            0.002680677724903865,
            0.0016282417029464133,
            -0.00009515922545186363,
            0.00005151389020466227,
        ),
    ];
    
    offset_momentum(&mut bodies);
    
    println!("{:.9}", energy(&bodies));
    
    let dt = 0.01;
    for _ in 0..n {
        advance(&mut bodies, dt);
    }
    
    println!("{:.9}", energy(&bodies));
}
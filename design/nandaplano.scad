function naca_half_thickness(x,t) =
    5*t*(0.2969*sqrt(x)
    - 0.1260*x
    - 0.3516*pow(x,2)
    + 0.2843*pow(x,3)
    - 0.1015*pow(x,4));

function naca_top_coordinates(t,n) =
    [ for (x=[0:1/(n-1):1]) [x, naca_half_thickness(x,t)]];

function naca_bottom_coordinates(t,n) =
    [ for (x=[1:-1/(n-1):0]) [x, - naca_half_thickness(x,t)]];

function naca_coordinates(t,n,symetrical) =
    symetrical
        ? concat(naca_top_coordinates(t,n), naca_bottom_coordinates(t,n))
        : naca_top_coordinates(t,n);

function find_max(x,y,arr) =
    len(arr) == 0
        ? x
        : len(arr) == 1
            ? (y < arr[0][1] ? arr[0][0] : x)
            : y < arr[0][1]
                ? find_max(arr[0][0], arr[0][1], [for (i=[1:len(arr)-1]) arr[i]])
                : find_max(x, y, [for (i=[1:len(arr)-1]) arr[i]]);

module naca_airfoil(chord,t,n,symetrical) {
    points = naca_coordinates(t,n,symetrical);
    max_x = find_max(0, 0, points);
    scale([chord,chord,1])
        translate([-max_x,0,0])
            polygon(points);
}

module naca_wing(span, chord, t, n, symetrical=true, center=false, scale=1) {
    linear_extrude(
        height = span,
        center = center,
        scale = scale,
        twist = 0
    ) {
        naca_airfoil(chord, t, n, symetrical);
    }
}

module wing() {
    rotate([90, 0, 0]) {
        naca_wing(span=35, chord=20, t=0.12, n=500, center=false, symetrical=false);
        translate([0, 0, 35])
            naca_wing(
                span=15,
                chord=20,
                t=0.12,
                n=500,
                symetrical=false,
                scale=[0.75, 0.75]
            );
    }
}

module fuselage() {
    translate([0, 0, 0])
        cube([30, 5, 5], center=true);
    translate([30, 0, 0])
        rotate([0, 90, 0])
            cylinder(h=30, r=2.54/4, center=true);
}

module horizontal_stabilizer() {
    translate([45, 0, 0])
        rotate([90, 0, 0])
            naca_wing(span=20, chord=10, t=0.06, n=500, center=true);
}

wing();
mirror([0,1,0])
    wing();
fuselage();
horizontal_stabilizer();

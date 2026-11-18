function ecef = kepler2ecef(Oe, G, Me, a, Mo, dt, e, tol, w, Oo, dO, io)
% SUBSATELLITE  Computes the subsatellite point (latitude and longitude) on Earth
%
%   [long, lat] = SUBSATELLITE(...) calculates the geodetic coordinates of the
%   point on Earth's surface directly below the satellite (subsatellite point)
%   using its orbital elements and elapsed time.
%
%   Inputs:
%       Oe  - Earth's rotation rate [rad/s]
%       G   - Gravitational constant [m^3/kg/s^2]
%       Me  - Earth's mass [kg]
%       a   - Semi-major axis of satellite orbit [m]
%       Mo  - Mean anomaly at reference epoch [rad]
%       dt  - Time elapsed since reference epoch [s]
%       e   - Orbital eccentricity (dimensionless)
%       tol - Tolerance for solving Kepler's equation
%       w   - Argument of perigee [rad]
%       Oo  - RAAN at reference epoch [rad]
%       dO  - RAAN drift rate [rad/s]
%       io  - Orbital inclination [rad]
%
%   Outputs:
%       long - Longitude of subsatellite point [deg]
%       lat  - Latitude of subsatellite point [deg]

arguments (Input)
    Oe double
    G double
    Me double
    a double
    Mo double
    dt double
    e double
    tol double
    w double
    Oo double
    dO double
    io double
end

arguments (Output)
    ecef (1, 3) double
end

% ------------------ ORBITAL CALCULATIONS ------------------

% 1) Compute mean anomaly at current time
M = mean_anomaly(G, Me, a, Mo, dt);

% 2) Solve Kepler's equation to get eccentric anomaly
E = eccentric(e, tol, M);

% 3) Convert eccentric anomaly to true anomaly
v = true_anomaly(e, E);

% 4) Compute satellite coordinates in orbital plane
[xp, yp] = orbitcoords(v, w, a, e, E);

% 5) Convert orbital-plane coordinates to Earth-Centered Earth-Fixed (ECEF)
ecef = satecef(Oe, Oo, dO, dt, io, xp, yp);


% Optional debug printing
if ismember("fd", who("global"))
    global fd;
    fprintf(fd, "ecef = %f, %f, %f\n", ecef);
end

end
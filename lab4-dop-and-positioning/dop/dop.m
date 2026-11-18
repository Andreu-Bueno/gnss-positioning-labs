function [gd, pd, hd, vd, tdop] = dop(Oe, G, Me, tol, esec, lla_user, NS, Eph)
%DOP Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    Oe               double
    G                double
    Me               double
    tol              double
    esec             double
    lla_user (1, 3)  double
    NS               double
    Eph      (:, 13) double
end

arguments (Output)
    gd   (1, 1) double
    pd   (1, 1) double
    hd   (1, 1) double
    vd   (1, 1) double
    tdop (1, 1) double
end

% 1. Convert lla user's coordinates to ECEF
xyz_user = lla2ecef(lla_user);

% 2. Buld matrix H
n = 0; % Visible sat. counter
prn = zeros(1, NS);
azimuth = zeros(1, NS);
elevation = zeros(1, NS);
H = [];

for i = 1:NS
    % 2.0 Orbital parameters

    id = Eph(i, 1);           % PRN                       (Column 1)
    e  = Eph(i, 3);           % Exentricity               (Column 3)
    toa = Eph(i, 4);          % Time of Applicability     (Column 4)
    io = Eph(i, 5);           % Inclination               (Column 5)
    dO = Eph(i, 6);           % Rate of Right Ascension   (Column 6)
    a = Eph(i, 7)^2;          % Semi-major axis           (Column 7 | Eph(i,7) is sqrt_a)
    Oo = Eph(i, 8)-Oe*toa;    % Acendant node's longitude (Columna 8)
    w  = Eph(i, 9);           % Argument of perigee       (Columna 9)
    Mo = Eph(i, 10);          % Mean anomaly              (Columna 10)
    
    dt = esec - toa;
    
    % 2.1 Sat.'s ECEF coordinates
    xyz_sat = kepler2ecef(Oe, G, Me, a, Mo, dt, e, tol, w, Oo, dO, io);

    % 2.2 Pointer vector (rho): Sat_ECEF - User_ECEF
    rho_ecef = xyz_sat - xyz_user;

    % 2.3 Translate the vector to NED coordinates (North-East-Down)
    rho_ned = ecef2ned(rho_ecef, lla_user(1), lla_user(2));

    % 2.4 Convert NED to spherical (distance, elevation, azimuth)
    [~, az, el] = ned2spherical(rho_ned);

    % 2.5 Filter to visible sat. (elevation > 10°)
    if el > 10 
        n = n + 1;
        prn(n) = id;
        azimuth(n) = az;
        elevation(n) = el;
        
        % Unit vector LoS
        u_ned = rho_ned / norm(rho_ned);

        % Add row to H
        H = [H; -u_ned(1), -u_ned(2), -u_ned(3), 1];
    end
end

if ismember("fd1", who("global"))
    global fd1;
    fprintf(fd1, "\nVisible satellites for esec = %6d:\n", floor(esec));  
    for (j = 1:n)
        fprintf(fd1, "prn = %d, azimuth = %f, elevation = %f\n", prn(j), azimuth(j), elevation(j));
    end
end

% 3. Check enough satellites
if size(H,1) < 4
    gd = NaN; pd = NaN; hd = NaN; vd = NaN; tdop = NaN;
    return;
end

% 4. Compute DOPs
Q = (H' * H) \ eye(4);

[gd, pd, hd, vd, tdop] = q2dop(Q);

end
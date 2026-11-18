function [gr, H] = reference(Oe, G, Me, tol, esec, refecef, NS, Eph, satlist)
% REFERENCE Compute geometric ranges and system matrix at reference position
%   Inputs:
%       Oe      - Earth rotation angular velocity [rad/s]
%       G       - Gravitational constant
%       Me      - Earth Mass
%       tol     - tolerance for convergence
%       esec    - elapsed time [s] after week epoch
%       refecef - (1 x 3) reference position ecef coords (X, Y, Z)
%       NS      - Number of satellites
%       Eph     - Ephemeris data matrix
%       satlist - (N x 1) IDs of the visible satellites given by receiver
%   Outputs:
%       gr      - (N x 1) Geometric ranges to visible satellites [m]
%       H       - (N x 4) System design matrix in ECEF


arguments (Input)
    Oe               double
    G                double
    Me               double
    tol              double
    esec             double
    refecef  (1, 3)  double
    NS               double
    Eph      (:, 13) double
    satlist  (1, :)  double
end

arguments (Output)
    gr (:, 1) double
    H  (:, 4) double
end

num_sats = length(satlist);

% Pre-allocate exact size to matrices for faster execution
H = zeros(num_sats, 4);
gr = zeros(num_sats, 1);

% Iterate through satlist, NOT over NS. This ensures the same order as 'pr'
for k = 1:num_sats
    id = satlist(k);
    
    % Find which row in Eph corresponds to this satellite
    % (Assuming PRN is in column 1)
    idx = find(Eph(:, 1) == id, 1);
    
    % 2.0 Orbital parameters extracted from the correct row (idx)
    e  = Eph(idx, 3);           
    toa = Eph(idx, 4);          
    io = Eph(idx, 5);           
    dO = Eph(idx, 6);           
    a = Eph(idx, 7)^2;          
    Oo = Eph(idx, 8)-Oe*toa;    
    w  = Eph(idx, 9);           
    Mo = Eph(idx, 10);          
    
    dt = esec - toa;
    
    % 2.1 Sat.'s ECEF coordinates
    xyz_sat = kepler2ecef(Oe, G, Me, a, Mo, dt, e, tol, w, Oo, dO, io);
    
    % 2.2 Pointer vector: Sat_ECEF - User_ECEF
    rho_ecef = xyz_sat - refecef;
    
    % 2.3 Compute Geometric Range (gri)
    dist = norm(rho_ecef);
    
    % Save the distance at the same index 'k'
    gr(k) = dist;
    
    % 2.4 Build the row of the H matrix in ECEF coordinates
    ux = rho_ecef(1) / dist;
    uy = rho_ecef(2) / dist;
    uz = rho_ecef(3) / dist;
    
    % Save the row in the matrix H
    H(k, :) = [ux, uy, uz, 1];
end

if ismember("fd1", who("global"))
    global fd1;
    fprintf(fd1, "\nH matrix:\n");
    for (j = 1:num_sats)
        fprintf(fd1, "%f %f %f %f\n", H(j,:));
    end
end
end
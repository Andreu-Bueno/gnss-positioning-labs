function ecef = satecef(Oe, Oo, dO, dt, io, xp, yp)
% SATECEF  Converts satellite orbital coordinates to Earth-Centered Earth-Fixed (ECEF).
%
%   ecef = SATECEF(Oe, Oo, dO, dt, io, xp, yp) computes the ECEF position
%   of a satellite from its orbital-plane coordinates (xp, yp) and orbital
%   elements.
%
%   Inputs:
%       Oe  - Earth's rotation rate [rad/s]
%       Oo  - RAAN (Right Ascension of Ascending Node) at reference epoch [rad]
%       dO  - Rate of change of RAAN [rad/s]
%       dt  - Time since reference epoch [s]
%       io  - Orbital inclination [rad]
%       xp  - Satellite x-coordinate in orbital plane [m]
%       yp  - Satellite y-coordinate in orbital plane [m]
%
%   Output:
%       ecef - 1x3 vector of satellite coordinates in ECEF frame [x, y, z] [m]

arguments (Input)
    Oe double      % Earth rotation rate
    Oo double      % RAAN at reference epoch
    dO double      % RAAN drift rate
    dt double      % Time elapsed since reference
    io double      % Orbital inclination
    xp double      % Satellite x in orbital plane
    yp double      % Satellite y in orbital plane
end

arguments (Output)
    ecef (1, 3) double
end

% 1) Correct RAAN due to nodal drift over time dt
O_corr = Oo + dO * dt;

% 2) Compute current longitude of ascending node including Earth rotation
%    (ECEF rotates with the Earth, so we subtract Oe*dt)
O = O_corr - Oe * dt;

% 3) Transform orbital-plane coordinates (xp, yp) to ECEF coordinates
x = xp*cos(O) - yp*cos(io)*sin(O);
y = xp*sin(O) + yp*cos(io)*cos(O);
z = yp*sin(io);

% Assemble output
ecef = [x, y, z];

% Optional debug printing
if ismember("fd", who("global"))
    global fd;
    fprintf(fd, "O = %f, x = %f, y = %f, z = %f\n", mod(O,2*pi), x, y, z);
end

end
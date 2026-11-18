function [xp, yp] = orbitcoords(v, w, a, e, E)
%ORBITCOORDS Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    v double
    w double
    a double
    e double
    E double
end

arguments (Output)
    xp double
    yp double
end

% Radius of the elipse
r = a*(1-e*cos(E));

% Position in the orbital plane
xp = r * cos(v + w);
yp = r * sin(v + w);

% Debug printing
if ismember("fd", who("global"))
    global fd;
    fprintf(fd, "r = %f, xp = %f, yp = %f\n", r, xp, yp);
end

end
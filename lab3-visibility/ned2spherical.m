function [r, az, elev] = ned2spherical(ned)
%NED2SPHERICAL Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    ned
end

arguments (Output)
    r double
    az double
    elev double
end

N = ned(1); E = ned(2); D = ned(3);

r = sqrt(N^2 + E^2 + D^2); % Distancia
elev = asin(-D / r) * 180/pi; % Elevación en grados
az = atan2(E, N) * 180/pi; % Azimut en grados (usar atan2 para evitar ambigüedad)

if az < 0, az = az + 360; end % Normalizar azimut a 

if ismember("fd", who("global"))
    global fd;
    fprintf(fd, "r = %f, az = %f, elev = %f\n", r, az, elev);
end

end
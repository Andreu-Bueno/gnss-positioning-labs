function ecef = lla2ecef(lla)
%LLA2ECEF Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    lla (1, 3) double
end

arguments (Output)
    ecef (1, 3) double
end

a = 6378137; % WGS84
e2 = 0.00669437999014;
phi = lla(1); lambda = lla(2); h = lla(3);

N = a / sqrt(1 - e2 * sin(phi)^2);
x = (N + h) * cos(phi) * cos(lambda);
y = (N + h) * cos(phi) * sin(lambda);
z = (N * (1 - e2) + h) * sin(phi);
ecef = [x, y, z];

if ismember("fd", who("global"))
    global fd;
    fprintf(fd, "ecef(x,y,z) = %f, %f, %f\n", ecef);
end

end
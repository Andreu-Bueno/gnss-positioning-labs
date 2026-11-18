

clear all
close all
clc


G = 6.67384e-11; % Gravitational constant
Me = 5.972e+24; % Earth Mass
mu = G*Me;
Oe = 7.2921151467e-5; % Earth rotation angular velocity (rad/s)
tol = 1.e-8; % tolerance for convergence
global fd;
fd = fopen("main3.dat", "w");
plotworld();


% IRIDIUM 106             
% 1 41917U 17003A   26070.21025577  .00000110  00000+0  32067-4 0  9990
% 2 41917  86.3976 129.5265 0002083 106.4390 253.7035 14.34216919479161

id = 106; % sat. identifier
toa = 070.21025577; % ToA [days within current year]
io = deg2rad(86.3976); % orbit inclination (deg)
raan = deg2rad(129.5265); % RA of AN (deg)
e = 0.0002083; % orbit eccentricity
w = deg2rad(106.4390); % argument of the perigee (deg)
Mo = deg2rad(253.7035); % Mean anomaly at ToA [deg]
n = 14.34216919479161; % mean motion [rev/day]

n = (n*2*pi)/86400; % mean motion [rad/s]
a = (mu/(n^2))^(1/3);
dO = 0;

DD = 11; MM = 03; YYYY = 2026; 
hh = 15; mm = 58; ss = 44;

% [dt, GASTdegToA] = time2toa(toa, DD, MM, YYYY, hh, mm, ss);
[dt, GASTdegToA] = time2toa(toa, DD, MM, YYYY, hh, mm, ss);

Oo = raan - deg2rad(GASTdegToA);

% ===== your code goes here ====
fprintf(fd, "io = %f, a = %f, w = %f, Mo = %f, Oo = %f\n\n", io, a, mod(w, 2 * pi), mod(Mo, 2 * pi), mod(Oo, 2 * pi));

[long, lat] = subsatellite(Oe, G, Me, a, Mo, dt, e, tol, w, Oo, dO, io);

% ===== your code goes here ====
plot(long, lat, Marker='o', MarkerEdgeColor='r', MarkerFaceColor='cyan', MarkerSize=12)
text(long + 2, lat + 1, sprintf('%d', id), 'Color', 'black');

% ===== your code goes here ====
T = (2*pi) / n; % Orbital period
for t = 0:30:T
    dt_new = dt + t;

    [long, lat] = subsatellite(Oe, G, Me, a, Mo, dt_new, e, tol, w, Oo, dO, io);

    plot(long, lat, '.', 'Color', 'r', 'MarkerSize', 12);
end

fclose(fd);
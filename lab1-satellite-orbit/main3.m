clear all
close all
clc

G = 6.67384e-11; % Gravitational constant
Me = 5.972e+24; % Earth Mass
Oe = 7.2921151467e-5; % Earth rotation angular velocity (rad/s)
tol = 1.e-8; % tolerance for convergence
global fd;
fd = fopen("main3.dat", "w");
plotworld();
DD = 02;
MM = 03;
YYYY = 2026; % Current year
hh = 20; % Current hour
mm = 45; % Current minute
ss = 07; % Current second

esec = gpstime(DD, MM, YYYY, hh, mm, ss);

% ******** Week 360 almanac for PRN-03 ********
% ID:                         03
% Health:                     000
% Eccentricity:               0.6484031677E-002
% Time of Applicability(s):  319488.0000
% Orbital Inclination(rad):   0.9932789255
% Rate of Right Ascen(r/s):  -0.7611745631E-008
% SQRT(A)  (m 1/2):           5153.582520
% Right Ascen at Week(rad):  -0.2160343044E+001
% Argument of Perigee(rad):   1.202132732
% Mean Anom(rad):            -0.1523747383E+001
% Af0(s):                     0.5512237549E-003
% Af1(s/s):                  -0.1091393642E-010
% week:                        360

id = 3; % sat. identifier
e = 0.6484031677e-002; % orbit eccentricity
toa = 319488.0000; % Time of Applicability [seconds within current week]
io = 0.9932789255; % orbit inclination [rad]
dO = -0.7611745631e-008; % derivative of right ascension of AN [rad/s]
a = 5153.582520^2; % orbit semi-major axis [m]
Lo = -0.2160343044e+001; % longitude of AN at week epoch [rad] (uncorrected)
w = 1.202132732; % argument of perigee [rad]
Mo = -0.1523747383e+001; % Mean Anomaly at ToA [rad]

% ===== your code goes here ====
dt = esec - toa;
Oo = Lo - Oe * toa;
M = mean_anomaly(G, Me, a, Mo, dt);
E = eccentric(e, tol, M);
check= E - e*sin(E);
disp([M check])
v = true_anomaly(e, E);
[xp, yp] = orbitcoords(v, w, a , e, E);
ecef = satecef(Oe, Oo, dO, dt, io, xp, yp);


fprintf(fd, "Oo = %f, esec = %f, dt = %f\n\n", mod(Oo, 2 * pi), esec, dt);
% ===== your code goes here ====
[long, lat] = subsatellite(Oe, G, Me, a, Mo, dt, e, tol, w, Oo, dO, io);

plot(long, lat, 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b')
text(long + 2, lat + 1, sprintf('%d', id));
% ===== your code goes here ====
for k = 1:288   % 24 hours / 5 min steps
    
    dt_loop = dt + k*300;   % 300 seconds = 5 minutes
    
    [long, lat] = subsatellite(Oe, G, Me, a, Mo, dt_loop, e, tol, w, Oo, dO, io);
    
    plot(long, lat, 'r.')
    
end

fclose(fd);
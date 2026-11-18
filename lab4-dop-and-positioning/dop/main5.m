clear all;
close all;
clc;

% Constants físiques
G = 6.67384e-11;    % Constant gravitacional
Me = 5.972e+24;     % Massa de la Terra
Oe = 7.2921151467e-5;    % Velocitat angular de rotació terrestre (rad/s)
tol = 1.e-8;        % Tolerància per a la convergència

global fd1;
fd1 = fopen("main5.dat", "w");

DD = 29; MM = 03; YYYY = 2026;
hh = 15; mm = 00; ss = 00;

% Obtenir dades d'efemèrides (Almanac)
% [~, esec, NS, Eph] = almanac();
[~, esec, NS, Eph] = almanac(DD, MM, YYYY, hh, mm, ss);

% 1. Users position (EETAC)
% Coordinates EETAC: lat = 41.275, lon = 1.985, alt = 4
lla_user = [41.275 * pi/180, 1.985 * pi/180, 4]; % lat, lon en rad

% 2. Time loop to compute DoP for the next 6 hours (steps of 10 minutes or 1 minute)
steps = 60; % 10 min = 600 s | 1 min = 60 s
stop = 21600; % end of loop. In this case we are asked to use 6h = 21600 s

tm = []; gdop = []; pdop = []; hdop = []; vdop = []; tdop = [];

k = 1;

for t = 0:steps:stop
    % Current time
    esec_t = esec + t;

    % Call function dop
    [gd, pd, hd, vd, td] = dop(Oe, G, Me, tol, esec_t, lla_user, NS, Eph);

    % Save time in min
    tm(k) = t/60;

    % Save results
    gdop(k) = gd;
    pdop(k) = pd;
    hdop(k) = hd;
    vdop(k) = vd;
    tdop(k) = td;
    
    % Increment vector index
    k = k + 1;
end

% --- Plotting ---
figure('Color', [0.95 0.95 0.95]); % Light gray background like your image
h(1) = plot(tm, gdop, 'DisplayName', 'GDOP'); hold on;
h(2) = plot(tm, pdop, 'DisplayName', 'PDOP');
h(3) = plot(tm, hdop, 'DisplayName', 'HDOP', 'Color', 'r');
h(4) = plot(tm, vdop, 'DisplayName', 'VDOP');
h(5) = plot(tm, tdop, 'DisplayName', 'TDOP');

% Save original colors
for i = 1:5
    h(i).UserData = h(i).Color;
end

grid on;
xlabel('Time (min)');
ylabel('DOP Value');
title(sprintf('Satellite Dilution of Precision (%.1f h)', stop/3600));

xbounds = [0, stop/60];
xlim(xbounds);
set(gca, 'XTick', 0:60:xbounds(2));

lgd = legend('Location', 'northeast');
lgd.ItemHitFcn = @(src,event) toggleVisibility(event);
fclose(fd1);

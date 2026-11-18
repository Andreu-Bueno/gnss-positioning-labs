clear all
close all
clc

G = 6.67384e-11; % Gravitational constant
Me = 5.972e+24; % Earth Mass
Oe = 7.2921151467e-5; % Earth rotation angular velocity (rad/s)
tol = 1.e-8; % tolerance for convergence
global fd;
fd = fopen("main2.dat", "w");
plotworld();

colors = {
[0 0.45 0.74]   % azul
[0.85 0.33 0.1] % naranja
[0.49 0.18 0.56]% morado
[0.85 0.6 0] % naranja dorado
[0.47 0.67 0.19]% verde oscuro
};

DD = 11; MM = 03; YYYY = 2026; 
hh = 15; mm = 42; ss = 07;
% [baseweek, esec, NS, Eph] = almanac(DD, MM, YYYY, hh, mm, ss);
[baseweek, esec, NS, Eph] = almanac();


for s   = 1:NS
    id  = Eph(s, 1);      % sat. identifier
    e   = Eph(s, 3);      % orbit eccentricity
    toa = Eph(s, 4);      % Time of Applicability [seconds within current week]
    io  = Eph(s, 5);      % orbit inclination [rad]
    dO  = Eph(s, 6);      % derivative of right ascension of AN [rad/s]
    a   = Eph(s, 7)^2;    % orbit semi-major axis [m]
    Lo  = Eph(s, 8);      % longitude of AN at week epoch [rad] (uncorrected)
    w   = Eph(s, 9);      % argument of perigee [rad]
    Mo  = Eph(s, 10);     % Mean Anomaly at ToA [rad]
    
    idx_col = mod(s-1, length(colors)) + 1;
    current_color = colors{idx_col};

    % ===== your code goes here ====
    dt = (esec - toa);
    Oo = Lo - Oe * toa;
    
    fprintf(fd, "Oo = %f, esec = %f, dt = %f\n\n", mod(Oo, 2 * pi), esec, dt);
    % ===== your code goes here ====
    [long, lat] = subsatellite(Oe, G, Me, a, Mo, dt, e, tol, w, Oo, dO, io);
    long = mod(long + 180, 360) - 180;

    plot(long, lat, 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b')
    % ===== your code goes here ====
    lat_hist = zeros(1, 12);
    long_hist = zeros(1, 12);

    for k = 1:12   % 1 hour / 5 min steps
        
        dt_loop = (dt) + k*300;   % 300 seconds = 5 minutes
        
        [long_k, lat_k] = subsatellite(Oe, G, Me, a, Mo, dt_loop, e, tol, w, Oo, dO, io);
        long_k = mod(long_k + 180, 360) - 180;

        plot(long_k, lat_k, '.', 'Color', 'k', 'MarkerSize', 10);
        plot(long_k, lat_k, '.', 'Color', current_color, 'MarkerSize', 6);

        long_hist(k) = long_k;
        lat_hist(k) = lat_k;
        
    end

    last_long = long_hist(end);
    last_lat = lat_hist(end);
    
    plot(last_long, last_lat, 'o', 'Color', 'black', 'MarkerSize', 8, 'LineWidth', 2);
    plot(last_long, last_lat, 'o', 'Color', current_color, 'MarkerSize', 8, 'LineWidth', 1.3);
    plot(last_long, last_lat, '.', 'Color', current_color, 'MarkerSize', 6);
    
    % Colocar el ID justo en el centro o al lado del círculo
    text(long_hist(1) + 2, lat_hist(1) + 2, sprintf('%d', id), ...
        'Color', 'black', ...
        'FontSize', 10, ...
        'FontWeight', 'bold');
end

fclose(fd);
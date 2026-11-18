clear all;
close all;
clc;

% Constants físiques
G = 6.67384e-11;    % Constant gravitacional
Me = 5.972e+24;     % Massa de la Terra
Oe = 7.2921151467e-5;    % Velocitat angular de rotació terrestre (rad/s)
tol = 1.e-8;        % Tolerància per a la convergència

global fd;
fd = fopen("main4.dat", "w");

DD = 17; MM = 03; YYYY = 2026;
hh = 16; mm = 00; ss = 00;
use_now = false;


% Obtenir dades d'efemèrides (Almanac)
% [~, esec, NS, Eph] = almanac();
[~, esec, NS, Eph] = almanac(DD, MM, YYYY, hh, mm, ss);

% 1. Posició de l'usuari (EETAC) i conversió a ECEF
% Coordenades EETAC: lat = 41.275, lon = 1.985, alt = 4
lla_user = [41.275 * pi/180, 1.985 * pi/180, 4]; % lat, lon en rad
xyz_user = lla2ecef(lla_user); % Corregit el nom de la funció

n = 0; % Comptador de satèl·lits visibles
prn = zeros(1, NS);
azimuth = zeros(1, NS);
elevation = zeros(1, NS);

% Bucle per a CADA satèl·lit
for i = 1:NS
   % 2.0 Extracció de paràmetres orbitals [4]
   id = Eph(i, 1);           % PRN (Columna 1)
   e  = Eph(i, 3);           % Excentricitat (Columna 3)
   toa = Eph(i, 4);          % Time of Applicability (Columna 4)
   io = Eph(i, 5);           % Inclinació (Columna 5)
   dO = Eph(i, 6);           % Rate of Right Ascension (Columna 6)
   a = Eph(i, 7)^2;          % Semieix major (Eph(i,7) és sqrt_a)
   Oo = Eph(i, 8)-Oe*toa;    % Longitud del node ascendent (Columna 8)
   w  = Eph(i, 9);           % Argument del perigeu (Columna 9)
   Mo = Eph(i, 10);          % Anomalía mitjana (Columna 10)
   
   dt = esec - toa; % Temps transcorregut des de ToA
   
   % 2.1 Impressió de depuració al fitxer .dat [4]
   fprintf(fd, "\nid = %d, Oo = %f, esec = %f, dt = %f\n", id, mod(Oo, 2 * pi), esec, dt);
   
   % 2.2 Coordenades ECEF del satèl·lit
   xyz_sat = kepler2ecef(Oe, G, Me, a, Mo, dt, e, tol, w, Oo, dO, io);
  
   % 2.3 Vector de punteria (rho): Sat_ECEF - User_ECEF
   rho_ecef = xyz_sat - xyz_user;
  
   % 3. Transformar vector a coordenades NED
   rho_ned = ecef2ned(rho_ecef, lla_user(1), lla_user(2));
  
   % 4. Convertir NED a esfèriques (distància, elevació, azimut)
   [d, az, el] = ned2spherical(rho_ned);
  
   % 5. Filtrar satèl·lits visibles (elevació > 10º) [8]
   if el > 10 % Corregit l'error de sintaxi [1]
       n = n + 1;
       prn(n) = id;
       azimuth(n) = az;
       elevation(n) = el;
   end
end

% 6. Representació polar dels satèl·lits en LoS

if use_now
    t = datetime('now','TimeZone','UTC');
else
    t = datetime(YYYY, MM, DD, hh, mm, ss, 'TimeZone', 'UTC');
end

title_str = sprintf("GPS from EETAC (%s UTC)", char(t, 'dd-MMM-yyyy HH:mm:ss'));
viewsat(azimuth, elevation, prn, 10, 90, title_str);


% Guardar resultats finals al fitxer de depuració
fprintf(fd, "\nVisible satellites:\n");
for j = 1:n
   fprintf(fd, "prn = %d, azimuth = %f, elevation = %f\n", prn(j), azimuth(j), elevation(j));
end

fclose(fd);

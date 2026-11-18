clear all;
close all;
clc;

% Constants
G = 6.67384e-11; % Gravitational constant
Me = 5.972e+24; % Earth Mass
Oe = 7.2921151467e-5; % Earth rotation angular velocity (rad/s)
tol = 1.e-8; % tolerance for convergence
colorarray = 'rgbcmyk';

global fd1;
fd1 = fopen("main6.dat", "w");

DD = 24; MM = 9; YYYY = 2025;
hh = 22; mm = 19; ss = 40;

% Visible satellites and pseudoranges:
% 5 23401804.933939
% 6 23784384.070499
% 11 23965903.097440
% 12 23077844.562381
% 13 20153779.975126
% 14 24603086.660039
% 15 21717538.794846
% 17 22153452.172878
% 19 20866470.646722
% 21 24000672.523419
% 22 23042415.679961
% 24 24619944.920636
% 30 23915809.542841

% Create vectors "satlist" and "pr" 
satlist = [5, 6, 11, 12, 13, 14, 15, 17, 19, 21, 22, 24, 30];
pr = [
    23401804.933939; % G05
    23784384.070499; % G06
    23965903.097440; % G11
    23077844.562381; % G12
    20153779.975126; % G13
    24603086.660039; % G14
    21717538.794846; % G15
    22153452.172878; % G17
    20866470.646722; % G19
    24000672.523419; % G21
    23042415.679961; % G22
    24619944.920636; % G24
    23915809.542841  % G30
];

% Get ephemeris
[~, esec, NS, Eph] = almanac(DD, MM, YYYY, hh, mm, ss);

% Set first reference LLA position to EETAC
reflat = 41.275; reflong = 1.985; refalt = 4;
% Convert to radians for lla2xyz, but keep ref in degrees for plotting
lla_rad = [reflat * pi/180, reflong * pi/180, refalt]; 

% Use lla2xyz.m to compute the first refecef (1x3) vector
refecef = lla2ecef(lla_rad);

% Initialize loop variables
niter = 0;
computedlla = [];
displacement_mag = inf; % Set to infinity to enter the loop

% Loop to solve the navigation system of equations by successive iterations
while displacement_mag > 10 && niter < 50
    niter = niter + 1;
    
    % Call reference.m (Make sure your reference.m accepts satlist as 9th argument)
    [gr, H] = reference(Oe, G, Me, tol, esec, refecef, NS, Eph, satlist);
    
    % 1. Compute the residual vector (Delta Rho)
    % difference between computed geometric range and measured pseudorange
    delta_rho = gr - pr;
    
    % 2. Solve system using Least Squares (Pseudoinverse)
    % delta_rho = H * delta_u  =>  delta_u = pinv(H) * delta_rho
    delta_u = pinv(H) * delta_rho;
    
    % 3. Extract purely spatial displacement (first 3 components: dx, dy, dz)
    % delta_u is 4x1 (dx, dy, dz, dt). We transpose to 1x3 to match refecef
    displacement = delta_u(1:3)'; 
    
    % 4. Add the obtained displacement to "refecef"
    refecef = refecef + displacement;
    
    % 5. Check magnitude for loop condition
    displacement_mag = norm(displacement);
    
    % 6. Convert new refecef to LLA and save in matrix (in degrees!)
    lla_new = ecef2lla(refecef);
    computedlla(niter, 1) = lla_new(1); % Lat in deg
    computedlla(niter, 2) = lla_new(2); % Lon in deg
    computedlla(niter, 3) = lla_new(3); % Alt in meters
end

% End of loop
fprintf(fd1, "\nNumber of iterations = %d\n", niter);
fprintf(1, "\nNumber of iterations = %d\n", niter);
fprintf(fd1, "Computed LLA = %f %f %f\n", computedlla(niter, 1), computedlla(niter, 2), computedlla(niter, 3));
fprintf(1, "Computed LLA = %f %f %f\n", computedlla(niter, 1), computedlla(niter, 2), computedlla(niter, 3));


% Plotting section
plotworld();
hold on;
plot(reflong, reflat, 'or', 'MarkerSize', 5, 'LineWidth', 1.2); % Plot initial guess (EETAC)
plot(reflong, reflat, '.r', 'MarkerSize', 3, 'LineWidth', 1.2);

for j = 1:size(computedlla, 1)
    color = mod(j - 1, 7) + 1;
    plot(computedlla(j,2), computedlla(j,1), sprintf('o%s', colorarray(color)), 'MarkerSize', 5, 'LineWidth', 1.2);
    plot(computedlla(j,2), computedlla(j,1), sprintf('.%s', colorarray(color)), 'MarkerSize', 3, 'LineWidth', 1.2);
    text(computedlla(j,2) + 2, computedlla(j,1) + 1, sprintf('%d', j), 'Color', colorarray(color));
    pause(2) % Added a 1 second pause so you can actually see the animation
end

fclose(fd1);
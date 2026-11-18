function E = eccentric(e, tol, M)
% ECCENTRIC  Solves Kepler's equation for the eccentric anomaly.
%
%   E = ECCENTRIC(e, tol, M) computes the eccentric anomaly E (in radians)
%   from the mean anomaly M using Newton-Raphson iteration.
%
%   Kepler's Equation:
%       M = E - e*sin(E)
%
%   Inputs:
%       e   - Orbital eccentricity (dimensionless)
%       tol - Convergence tolerance for the iteration
%       M   - Mean anomaly (rad)
%
%   Output:
%       E   - Eccentric anomaly (rad)

arguments (Input)
    e double      % Orbital eccentricity
    tol double    % Convergence tolerance
    M double      % Mean anomaly (rad)
end

arguments (Output)
    E double      % Eccentric anomaly (rad)
end

% Initial guess: use mean anomaly (good approximation for small e)
E = M;

error = 1;  % Initialize error to enter the loop

% Newton-Raphson iteration
while error > tol
    
    % Kepler equation rewritten as f(E) = 0
    f = E - e * sin(E) - M;
    
    % Derivative of f(E)
    fp = 1 - e * cos(E);

    % Newton update step
    E_new = E - f / fp;

    % Compute difference between iterations
    error = abs(E_new - E);

    % Update value
    E = E_new;
end

% Optional debug printing to file (if global file descriptor exists)
if ismember("fd", who("global"))
    global fd;
    fprintf(fd, "E = %f\n", mod(E, 2*pi));  % Print normalized angle
end

end
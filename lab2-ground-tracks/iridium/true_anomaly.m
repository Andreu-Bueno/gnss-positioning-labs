function v = true_anomaly(e, E)
% TRUE_ANOMALY  Computes the true anomaly from the eccentric anomaly.
%
%   v = TRUE_ANOMALY(e, E) calculates the true anomaly (v) in radians
%   from the eccentric anomaly (E) and orbital eccentricity (e).
%
%   The transformation is based on the relations:
%
%       sin(v) = (sqrt(1 - e^2) * sin(E)) / (1 - e*cos(E))
%       cos(v) = (cos(E) - e) / (1 - e*cos(E))
%
%   The function uses atan2 to ensure the correct quadrant of v.
%
%   Inputs:
%       e - Orbital eccentricity (dimensionless)
%       E - Eccentric anomaly (rad)
%
%   Output:
%       v - True anomaly (rad)

arguments (Input)
    e double      % Orbital eccentricity
    E double      % Eccentric anomaly (rad)
end

arguments (Output)
    v double      % True anomaly (rad)
end

% Compute sine of true anomaly
sin_v = (sqrt(1 - e^2) * sin(E)) / (1 - e*cos(E));

% Compute cosine of true anomaly
cos_v = (cos(E) - e) / (1 - e*cos(E));

% Compute true anomaly using atan2 for correct angle quadrant
v = atan2(sin_v, cos_v);

% Optional debug printing to file (if global file descriptor exists)
if ismember("fd", who("global"))
    global fd;
    fprintf(fd, "v = %f\n", mod(v, 2*pi));  % Print normalized angle
end

end
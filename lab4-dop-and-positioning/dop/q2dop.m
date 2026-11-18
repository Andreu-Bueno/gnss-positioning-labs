function [gdop, pdop, hdop, vdop, tdop] = q2dop(Q)
% Q2DOP Compute Dilution of Precision (DOP) factors
%   Input:  Q (4x4) - Covariance matrix computed as (H'*(R\H))\eye(4)
%   Output: Scalar values representing satellite geometry quality
arguments (Input)
    Q (4, 4) double {mustBeNumeric}
end

arguments (Output)
    gdop (1, 1) double
    pdop (1, 1) double
    hdop (1, 1) double
    vdop (1, 1) double
    tdop (1, 1) double
end

% 1. Extract diagonal elements for easier calculation
% In standard GNSS processing: Q11=X, Q22=Y, Q33=Z, Q44=dt
q11 = Q(1,1);
q22 = Q(2,2);
q33 = Q(3,3);
q44 = Q(4,4);


% 2. Calculation of the different DOPs
% GDOP (Geometric): Square root of the trace (3D Position + Time)
gdop = sqrt(q11 + q22 + q33 + q44);

% PDOP (Positioning): Square root of the 3D position components
pdop = sqrt(q11 + q22 + q33);

% TDOP (Time): Square root of the time component
tdop = sqrt(q44);

% HDOP (Horizontal): Square root of X and Y components 
% Note: Usually requires Q to be in local coordinates (North/East) - Because
% of translated coordinates
hdop = sqrt(q11 + q22);

% VDOP (Vertical): Square root of the Z component
% Note: Usually requires Q to be in local coordinates (Up/Down) - Because
% of translated coordinates
vdop = sqrt(q33);

if ismember("fd1", who("global"))
    global fd1;
    fprintf(fd1, "gdop = %f, pdop = %f, hdop = %f, vdop = %f, tdop = %f\n", ...
            gdop, pdop, hdop, vdop, tdop);
end

end
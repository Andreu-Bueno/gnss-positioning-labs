% Convert from cartesian ECEF coordinates to LLA coordinates in datum WGS84
% ecef = (1x3) vector containing the current ecef coordinates of sat.
% lla = (1x3) vector containing the current (lat[deg], long[deg], alt[m]) coordinates of sat.

function lla = eceftolla(ecef)
    % 1. Extract inputs
    x = ecef(1);
    y = ecef(2);
    z = ecef(3);

    % 2. WGS-84 Datum constants
    a = 6378137;
    e2 = 0.00669437999014; % This represents e^2

    % 3. Derive missing ellipsoid parameters based on given relations
    % e = c/a  =>  c^2 = e^2 * a^2
    c2 = e2 * (a^2);
   
    % a^2 = b^2 + c^2  =>  b^2 = a^2 - c^2
    b2 = (a^2) - c2;
    b = sqrt(b2);
   
    % e'^2 = c^2 / b^2
    ep2 = c2 / b2;

    % 4. Algorithm execution
    r = sqrt((x^2) + (y^2));
    E2 = (a^2) - b2;
    F = 54 * b2 * (z^2);
   
    G = (r^2) + (1 - e2) * (z^2) - (e2 * E2);
   
    % Note: e^4 is simply the square of e^2
    C = ((e2^2) * F * (r^2)) / (G^3);
   
    s = nthroot((1 + C + sqrt((C^2) + 2*C)), 3);
   
    P = F / (3 * ((s + (1/s) + 1)^2) * (G^2));
   
    Q = sqrt(1 + 2 * (e2^2) * P);
   
    r0 = -((P * e2 * r) / (1 + Q)) + sqrt(0.5 * (a^2) * (1 + (1/Q)) - (P * (1 - e2) * (z^2)) / (Q * (1 + Q)) - 0.5 * P * (r^2));
   
    U = sqrt((z^2) + (r - (r0 * e2))^2);
   
    V = sqrt((z^2) * (1 - e2) + (r - (r0 * e2))^2);
   
    z0 = (b2 * z) / (a * V);
   
    h = U * (1 - (b2 / (a * V)));
   
    phi = atan2((z + ep2 * z0), r);
    landa = atan2(y, x);

    % 5. Convert radians to degrees and format output
    lat = rad2deg(phi);    % or phi * 180 / pi
    long = rad2deg(landa); % or landa * 180 / pi
    alt = h;
   
    lla = [lat, long, alt];

    % 6. Debugging info (exactly as requested in the prototype)
    if ismember("fd", who("global"))
        global fd;
        fprintf(fd, "lat = %f, long = %f, alt = %f\n", long, lat, alt);
        % Note: I kept the original fprintf variables in the order specified by your prompt.
    end
end
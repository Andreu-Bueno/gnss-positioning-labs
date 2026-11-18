function ned = ecef2ned(ecef, phi, lambda)
%ECEF2NED Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    ecef (1, 3) double 
    phi double 
    lambda double
end

arguments (Output)
    ned (1, 3) double
end

R = [-sin(phi)*cos(lambda), -sin(phi)*sin(lambda), cos(phi);
     -sin(lambda),           cos(lambda),          0;
     -cos(phi)*cos(lambda), -cos(phi)*sin(lambda), -sin(phi)];

ned = (R * ecef')'; % Multiplicación matricial (3x3 * 3x1)

if ismember("fd", who("global"))
    global fd;
    fprintf(fd, "ned = %f, %f, %f\n", ned);
end

end
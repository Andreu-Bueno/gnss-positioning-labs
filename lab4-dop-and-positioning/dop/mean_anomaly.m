function M = mean_anomaly(G, Me, a, Mo,dt)
%MEAN_ANOMALY Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    G
    Me
    a
    Mo
    dt
end

arguments (Output)
    M
end

% Mean agular velocity [rad/s]:
n = sqrt((G*Me)/a^3);


% Mean anomaly at time t:
M = Mo + n * dt;


if ismember("fd", who("global"))
    global fd;
    fprintf(fd, "dt = %f, M = %f\n", dt, mod(M, 2 * pi));
end

end
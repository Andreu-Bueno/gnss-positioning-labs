function Q = qmat(H, ulat, ulong)
%QMAT Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    H      (:, 4) double
    ulat   (1, 1) double
    ulong  (1, 1) double
end

arguments (Output)
    Q (4, 4) double
end

% 1. Obtain the translation matrix ECEF -> NED (3x3)
R3 = [-sin(ulat)*cos(ulong), -sin(ulat)*sin(ulong), cos(ulat);
      -sin(ulong),           cos(ulong),           0;
      -cos(ulat)*cos(ulong), -cos(ulat)*sin(ulong), -sin(ulat)];

% 2. Expand to 4x4 (adding time)
R = eye(4);
R(1:3,1:3) = R3;

% 3. Computation of Q
Q = (H' * (R \ H)) \ eye(4);


if ismember("fd1", who("global"))
global fd1;
fprintf(fd1, "Q matrix:\n");
fprintf(fd1, "%f, %f, %f, %f\n", Q(1,:));
fprintf(fd1, "%f, %f, %f, %f\n", Q(2,:));
fprintf(fd1, "%f, %f, %f, %f\n", Q(3,:));
fprintf(fd1, "%f, %f, %f, %f\n", Q(4,:));

end


end
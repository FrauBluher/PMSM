function [ sector ] = findSector(V1, V2, V3)
%UNTITLED2 Returns what SVaM sector you're in.

sector1 = 0;

%this isn't quite right I don't think...  Double check...

if V1 >= 0
    sector1 = 1;
end

if V2 >= 0
    sector1 = sector1 + 2;
end

if V3 >= 0
    sector1 = sector1 + 4;
end

sector = sector1;

end


function [sector] = FOC_SVPWM(Vq, Vd, pos)

Va = (Vd * cos(pos) - Vq * sin(pos));
Vb = (Vd * sin(pos) + Vq * cos(pos));

V1 = Vb;
V2 = (-Vb + sqrt(3) * Va)./ 2;
V3 = (-Vb - sqrt(3) * Va)./ 2;

sector = findSector(Va, Vb);

end
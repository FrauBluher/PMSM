%%
% This file is designed to help the user understand how sinusoidal signals
% actually translate to force vectors in a brushless motor.
%%

clear all;
close all;
clc;

pos = linspace(0, 2*pi, 1000);
Vq = 0;
Vd = 1;

Va = (Vd * cos(pos) - Vq * sin(pos));
Vb = (Vd * sin(pos) + Vq * cos(pos));

plot(Va);
hold on;
plot(Vb, 'r');
legend('Va','Vb');
title('Inverse Park Transform Output');

V1 = Vb;
V2 = (-Vb + sqrt(3) * Va)./ 2;
V3 = (-Vb - sqrt(3) * Va)./ 2;

figure;
hold on;
plot(V1, 'r');
plot(V2, 'g');
plot(V3, 'b');
legend('V1','V2','V3');
title('Inverse Clark Transform Output');

%%SPACE VECTOR MODULATION%%
slmin = 0;
slmax = 2*pi;
hsl = uicontrol('Style','slider','Min',slmin,'Max',slmax,...
                'SliderStep',[1 1]./(slmax-slmin),'Value',1,...
                'Position',[0 0 200 20]);
set(hsl,'Callback',@(hObject,eventdata) plot(round(get(hObject,'Value'))) )

%InvClarkOut InverseClarke(InvParkOut pP)
%{
%	InvClarkOut returnVal;
%	returnVal.Vr1 = pP.Vb;
%	returnVal.Vr2 = (-pP.Vb / 2 + (SQRT_3_2 * pP.Va));
%	returnVal.Vr3 = (-pP.Vb / 2 - (SQRT_3_2 * pP.Va));
%	return(returnVal);
%}

%InvParkOut InversePark(float Vd, float Vq, float position)
%{
%	InvParkOut returnVal;
%	returnVal.Va = Vd * cosf(theta) - Vq * sinf(position);
%	returnVal.Vb = Vd * sinf(theta) + Vq * cosf(position);
%	return(returnVal);
%}
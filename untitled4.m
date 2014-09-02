close all;
plot([wowdata(:,1)+100 wowdata(:,2)+500 wowdata(:,3)+1000 wowdata(:,4)*2000/6 wowdata(:,5)+500 wowdata(:,6)+500]);
legend('a','b','c','sector','Va','Vb');

v1 = 0:0.01:pi/3+0.01;
cosine = cos(v1); %c1
sine = sin(v1); %s1

figure
%%%%%%%%%%%%%%%%sector1%%%%%%%%%%%%%%%%%%%%
A = 1/2 - 3/8 * (cosine - sqrt(3)*sine);
plot(v1,A)
hold on
B = .5 + 3/8 * cosine + sqrt(3)/8 * sine;
plot(v1,B,'g')
C = .5 - 3/8 * cosine - sqrt(3)/8 * sine;
plot(v1,C, 'r')


%%%%%%%%%%%%%%%%sector 2%%%%%%%%%%%%%%%%5
v2 = pi/3:0.001:2*pi/3;
s2 = sin(v2);
c2 = cos(v2);

A = 1/2 + sqrt(3)/4 * s2;
B = 1/2 + 3/4* c2;
C = 1/2 - sqrt(3)/4 * s2;
plot(v2,A, 'b')
plot(v2,B, 'g')
plot(v2,C, 'r')


%%%%%%%Sector 3%%%%%%%%%%%%%%%%%%%%%%%%%
v3 = 2*pi/3:0.001:pi;
c3 = cos(v3);
s3 = sin(v3);


A = .5 - (3/8 * c3 - sqrt(3)/8 * s3);
B = .5 + 3/8 * c3 - sqrt(3)/8 * s3;

C = 1/2 - 3/8* (c3 + sqrt(3)*s3);
plot(v3,A,'b')
plot(v3,B,'g')
plot(v3,C,'r')

%%%%%%%%%%%%%%%%%%sector4%%%%%%%%%%%%%%%%%%%%%%%%%
v4 = pi:0.001:4*pi/3;
s4 = sin(v4);
c4 = cos(v4);

A = 1/2 - 3/8 * (c4 - sqrt(3)*s4);
B = .5 + 3/8 * c4 + sqrt(3)/8 * s4;
C = .5 - 3/8 * c4 - sqrt(3)/8 * s4;


plot(v4,A, 'b')
plot(v4,B, 'g')
plot(v4,C, 'r')

%%%%%%%%%%%%%%%sector 5 %%%%%%%%%%%%%%%%%%%%%%%%%%%


v4 = 4*pi/3:0.001:5*pi/3;
s4 = sin(v4);
c4 = cos(v4);

A = 1/2 + sqrt(3)/4 * s4;
B = 1/2 + 3/4* c4;
C = 1/2 - sqrt(3)/4 * s4;
plot(v4,A, 'b')
plot(v4,B, 'g')
plot(v4,C, 'r')


%%%%%%%Sector 6%%%%%%%%%%%%%%%%%%%%%%%%%
v6 = 5*pi/3:0.001:2*pi;
c6 = cos(v6);
s6 = sin(v6);


A = .5 - (3/8 * c6 - sqrt(3)/8 * s6);
B = .5 + 3/8 * c6 - sqrt(3)/8 * s6;

C = 1/2 - 3/8* (c6 + sqrt(3)*s6);
plot(v6,A,'b')
plot(v6,B,'g')
plot(v6,C,'r')


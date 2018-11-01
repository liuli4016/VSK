function [a,b,c,d]=linefit3D(point)

x=point(:,1);
y=point(:,2);
z=point(:,3);
A=[z,ones(size(z))];

b1=x;
q1=inv(A'*A)*A'*b1;
b2=y;
q2=inv(A'*A)*A'*b2;

a=q1(1);
b=q1(2);
c=q2(1);
d=q2(2);

function [coordinate,inside] = NewtonMethod(start_point, boundary_pos, num_boundary, xmin, ymin, zmin, xmax, ymax, zmax, RPF_x, RPF_y, RPF_z, RPForder, th)

coordinate=[0,0,0];
inside=0;
P=start_point';
[rx, ry, rz]=computeRPF(start_point, boundary_pos, num_boundary, RPForder); 
time=0;

% sum_old=rx*rx+ry*ry+rz*rz;
% sum_new=sum_old;
% rate=sum_new/sum_old;

while rx*rx+ry*ry+rz*rz>th
% while rate>th
    
    time=time+1;
    F=[rx, ry, rz]';
    
    xx=floor(P(1)+0.5);
    yy=floor(P(2)+0.5);
    zz=floor(P(3)+0.5);
    
    if xx+1>size(RPF_x,1)
        xx=size(RPF_x,1)-1;
    end
    
    if yy+1>size(RPF_x,2)
        yy=size(RPF_x,2)-1;
    end
    
    if zz+1>size(RPF_x,3)
        zz=size(RPF_x,3)-1;
    end
    
    
    dRXdx = (RPF_x(xx+1, yy, zz)-rx) / (xx+1-P(1));
    dRXdy = (RPF_x(xx, yy+1, zz)-rx) / (yy+1-P(2));
    dRXdz = (RPF_x(xx, yy, zz+1)-rx) / (zz+1-P(3));
    
    dRYdx = (RPF_y(xx+1, yy, zz)-ry) / (xx+1-P(1));
    dRYdy = (RPF_y(xx, yy+1, zz)-ry) / (yy+1-P(2));
    dRYdz = (RPF_y(xx, yy, zz+1)-ry) / (zz+1-P(3));
    
    dRZdx = (RPF_z(xx+1, yy, zz)-rz) / (xx+1-P(1));
    dRZdy = (RPF_z(xx, yy+1, zz)-rz) / (yy+1-P(2));
    dRZdz = (RPF_z(xx, yy, zz+1)-rz) / (zz+1-P(3));
    
    J=[dRXdx dRXdy dRXdz
       dRYdx dRYdy dRYdz
       dRZdx dRZdy dRZdz];
   
    dP=-F./(J*P);
   
    P=P+dP;
    
    if xmin>P(1) || ymin>P(2) || zmin>P(3) || P(1)>xmax || P(2)>ymax || P(3)>zmax
        inside=0;
        break
    end
    
    [rx, ry, rz]=computeRPF(P', boundary_pos, num_boundary, RPForder); 
%     
%     sum_new=rx*rx+ry*ry+rz*rz;
%     rate=sum_new/sum_old;   
%     
    if time>30
        break
    end
    
end

if rx*rx+ry*ry+rz*rz<=th
% if rate<=th
    inside=1;
    coordinate=P';
end


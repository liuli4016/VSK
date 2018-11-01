function [attracting, repelling, saddle1, saddle2, attr_num, saddle1_num, saddle2_num, pathline1, pathline2a, pathline2b] = Critical_Classify(voxel, critical_position, boundary_pos, num_boundary, RPF_x, RPF_y, RPF_z, RPF_order, count)

attracting=[];
repelling=[];
saddle1=[];
saddle2=[];
attr_num=0;
rep_num=0;
saddle1_num=0;
saddle2_num=0;

pathline1=[];
pathline2a=[];
pathline2b=[];

for i=1:count

    xx=floor(critical_position(i,1)+0.5);
    yy=floor(critical_position(i,2)+0.5);
    zz=floor(critical_position(i,3)+0.5);
    
    if xx+1>size(voxel,1)
        xx=size(voxel,1)-1;
    end
    if yy+1>size(voxel,2)
        yy=size(voxel,2)-1;
    end
    if zz+1>size(voxel,3)
        zz=size(voxel,3)-1;
    end    
    
    [rx, ry, rz]=computeRPF(critical_position(i,:), boundary_pos, num_boundary, RPF_order); 
    
    dRXdx = (RPF_x(xx+1, yy, zz)-rx) / (xx+1-critical_position(i,1));
    dRXdy=  (RPF_x(xx, yy+1, zz)-rx) / (yy+1-critical_position(i,2));
    dRXdz=  (RPF_x(xx, yy, zz+1)-rx) / (zz+1-critical_position(i,3));
    
    dRYdx = (RPF_y(xx+1, yy, zz)-ry) / (xx+1-critical_position(i,1));
    dRYdy=  (RPF_y(xx, yy+1, zz)-ry) / (yy+1-critical_position(i,2));
    dRYdz=  (RPF_y(xx, yy, zz+1)-ry) / (zz+1-critical_position(i,3));
    
    dRZdx = (RPF_z(xx+1, yy, zz)-rz) / (xx+1-critical_position(i,1));
    dRZdy=  (RPF_z(xx, yy+1, zz)-rz) / (yy+1-critical_position(i,2));
    dRZdz=  (RPF_z(xx, yy, zz+1)-rz) / (zz+1-critical_position(i,3));
    
    
    J=[dRXdx dRXdy dRXdz
       dRYdx dRYdy dRYdz
       dRZdx dRZdy dRZdz];
   
    lamda=eig(J);
    [V,D]=eig(J);
    
    if lamda(1)<0 && lamda(2)<0 && lamda(3)<0
        attr_num = attr_num + 1;
        attracting(attr_num,1)=critical_position(i,1);
        attracting(attr_num,2)=critical_position(i,2);
        attracting(attr_num,3)=critical_position(i,3);
    end
    
    if lamda(1)>0 && lamda(2)>0 && lamda(3)>0
        rep_num = rep_num + 1;
        repelling(rep_num,1)=critical_position(i,1);
        repelling(rep_num,2)=critical_position(i,2);
        repelling(rep_num,3)=critical_position(i,3);
    end
    
    if real(lamda(2))<0 && real(lamda(3))<0 && real(lamda(1))>0
        saddle1_num = saddle1_num + 1;
        saddle1(saddle1_num,1)=critical_position(i,1);
        saddle1(saddle1_num,2)=critical_position(i,2);
        saddle1(saddle1_num,3)=critical_position(i,3);
        pathline1(saddle1_num,:)=V(:,1);
    end
    
    if real(lamda(1))<0 && real(lamda(3))<0 && real(lamda(2))>0
        saddle1_num = saddle1_num + 1;
        saddle1(saddle1_num,1)=critical_position(i,1);
        saddle1(saddle1_num,2)=critical_position(i,2);
        saddle1(saddle1_num,3)=critical_position(i,3);
        pathline1(saddle1_num,:)=V(:,2);
    end
    
    if real(lamda(1))<0 && real(lamda(2))<0 && real(lamda(3))>0
        saddle1_num = saddle1_num + 1;
        saddle1(saddle1_num,1)=critical_position(i,1);
        saddle1(saddle1_num,2)=critical_position(i,2);
        saddle1(saddle1_num,3)=critical_position(i,3);
        pathline1(saddle1_num,:)=V(:,3);
    end
        
    if real(lamda(1))<0 && real(lamda(2))>0 && real(lamda(3))>0
        saddle2_num = saddle2_num + 1;
        saddle2(saddle2_num,1)=critical_position(i,1);
        saddle2(saddle2_num,2)=critical_position(i,2);
        saddle2(saddle2_num,3)=critical_position(i,3);
        pathline2a(saddle2_num,:)=V(:,2);
        pathline2b(saddle2_num,:)=V(:,3);
    end
    
    if real(lamda(2))<0 && real(lamda(1))>0 && real(lamda(3))>0
        saddle2_num = saddle2_num + 1;
        saddle2(saddle2_num,1)=critical_position(i,1);
        saddle2(saddle2_num,2)=critical_position(i,2);
        saddle2(saddle2_num,3)=critical_position(i,3);
        pathline2a(saddle2_num,:)=V(:,1);
        pathline2b(saddle2_num,:)=V(:,3);
    end
    
    if real(lamda(3))<0 && real(lamda(1))>0 && real(lamda(2))>0
        saddle2_num = saddle2_num + 1;
        saddle2(saddle2_num,1)=critical_position(i,1);
        saddle2(saddle2_num,2)=critical_position(i,2);
        saddle2(saddle2_num,3)=critical_position(i,3);
        pathline2a(saddle2_num,:)=V(:,1);
        pathline2b(saddle2_num,:)=V(:,2);
    end
    
end
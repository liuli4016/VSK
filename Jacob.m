function [attracting, repelling, saddle1, saddle2, attr_num, rep_num, saddle1_num, saddle2_num, pathline1, pathline2a, pathline2b] = Jacob(RPF_x, RPF_y, RPF_z, num_skeleton, skeleton_pos)

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

for i=1:num_skeleton(1)
    
    dRXdx=( RPF_x(skeleton_pos(i,1)+1, skeleton_pos(i,2), skeleton_pos(i,3)) - RPF_x(skeleton_pos(i,1)-1, skeleton_pos(i,2), skeleton_pos(i,3)) )/2;
    dRXdy=( RPF_x(skeleton_pos(i,1), skeleton_pos(i,2)+1, skeleton_pos(i,3)) - RPF_x(skeleton_pos(i,1), skeleton_pos(i,2)-1, skeleton_pos(i,3)) )/2;
    dRXdz=( RPF_x(skeleton_pos(i,1), skeleton_pos(i,2), skeleton_pos(i,3)+1) - RPF_x(skeleton_pos(i,1), skeleton_pos(i,2), skeleton_pos(i,3))-1 )/2;
    dRYdx=( RPF_y(skeleton_pos(i,1)+1, skeleton_pos(i,2), skeleton_pos(i,3)) - RPF_y(skeleton_pos(i,1)-1, skeleton_pos(i,2), skeleton_pos(i,3)) )/2;
    dRYdy=( RPF_y(skeleton_pos(i,1), skeleton_pos(i,2)+1, skeleton_pos(i,3)) - RPF_y(skeleton_pos(i,1), skeleton_pos(i,2)-1, skeleton_pos(i,3)) )/2;
    dRYdz=( RPF_y(skeleton_pos(i,1), skeleton_pos(i,2), skeleton_pos(i,3)+1) - RPF_y(skeleton_pos(i,1), skeleton_pos(i,2), skeleton_pos(i,3))-1 )/2;
    dRZdx=( RPF_z(skeleton_pos(i,1)+1, skeleton_pos(i,2), skeleton_pos(i,3)) - RPF_z(skeleton_pos(i,1)-1, skeleton_pos(i,2), skeleton_pos(i,3)) )/2;
    dRZdy=( RPF_z(skeleton_pos(i,1), skeleton_pos(i,2)+1, skeleton_pos(i,3)) - RPF_z(skeleton_pos(i,1), skeleton_pos(i,2)-1, skeleton_pos(i,3)) )/2;
    dRZdz=( RPF_z(skeleton_pos(i,1), skeleton_pos(i,2), skeleton_pos(i,3)+1) - RPF_z(skeleton_pos(i,1), skeleton_pos(i,2), skeleton_pos(i,3))-1 )/2;
    
    M=[dRXdx dRXdy dRXdz
       dRYdx dRYdy dRYdz
       dRZdx dRZdy dRZdz];
   
    lamda=eig(M);
    [V,D]=eig(M);
    
    if lamda(1)<0 && lamda(2)<0 && lamda(3)<0
        attr_num=attr_num+1;
        attracting(attr_num,1)=skeleton_pos(i,1);
        attracting(attr_num,2)=skeleton_pos(i,2);
        attracting(attr_num,3)=skeleton_pos(i,3);
    end
    
    if lamda(1)>0 && lamda(2)>0 && lamda(3)>0
        rep_num=rep_num+1;
        repelling(rep_num,1)=skeleton_pos(i,1);
        repelling(rep_num,2)=skeleton_pos(i,2);
        repelling(rep_num,3)=skeleton_pos(i,3);
    end
    
    if real(lamda(2))<0 && real(lamda(3))<0 && real(lamda(1))>0
        saddle1_num=saddle1_num+1;
        saddle1(saddle1_num,1)=skeleton_pos(i,1);
        saddle1(saddle1_num,2)=skeleton_pos(i,2);
        saddle1(saddle1_num,3)=skeleton_pos(i,3);
        pathline1(saddle1_num,:)=V(:,1);
    end
    
    if real(lamda(1))<0 && real(lamda(3))<0 && real(lamda(2))>0
        saddle1_num=saddle1_num+1;
        saddle1(saddle1_num,1)=skeleton_pos(i,1);
        saddle1(saddle1_num,2)=skeleton_pos(i,2);
        saddle1(saddle1_num,3)=skeleton_pos(i,3);
        pathline1(saddle1_num,:)=V(:,2);
    end
    
    if real(lamda(1))<0 && real(lamda(2))<0 && real(lamda(3))>0
        saddle1_num=saddle1_num+1;
        saddle1(saddle1_num,1)=skeleton_pos(i,1);
        saddle1(saddle1_num,2)=skeleton_pos(i,2);
        saddle1(saddle1_num,3)=skeleton_pos(i,3);
        pathline1(saddle1_num,:)=V(:,3);
    end
        
    if real(lamda(1))<0 && real(lamda(2))>0 && real(lamda(3))>0
        saddle2_num=saddle2_num+1;
        saddle2(saddle2_num,1)=skeleton_pos(i,1);
        saddle2(saddle2_num,2)=skeleton_pos(i,2);
        saddle2(saddle2_num,3)=skeleton_pos(i,3);
        pathline2a(saddle2_num,:)=V(:,2);
        pathline2b(saddle2_num,:)=V(:,3);
    end
    
    if real(lamda(2))<0 && real(lamda(1))>0 && real(lamda(3))>0
        saddle2_num=saddle2_num+1;
        saddle2(saddle2_num,1)=skeleton_pos(i,1);
        saddle2(saddle2_num,2)=skeleton_pos(i,2);
        saddle2(saddle2_num,3)=skeleton_pos(i,3);
        pathline2a(saddle2_num,:)=V(:,1);
        pathline2b(saddle2_num,:)=V(:,3);
    end
    
    if real(lamda(3))<0 && real(lamda(1))>0 && real(lamda(2))>0
        saddle2_num=saddle2_num+1;
        saddle2(saddle2_num,1)=skeleton_pos(i,1);
        saddle2(saddle2_num,2)=skeleton_pos(i,2);
        saddle2(saddle2_num,3)=skeleton_pos(i,3);
        pathline2a(saddle2_num,:)=V(:,1);
        pathline2b(saddle2_num,:)=V(:,2);
    end
    
end
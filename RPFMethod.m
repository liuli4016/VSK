function RPFMethod(voxel, show, rows, cols, slices, XX, YY, ZZ, AZ, EL, rev)

foldername='Skeleton_results';

[object_pos, boundary_pos, object, boundary] = segmentation(voxel, rows, cols, slices);
num_object=size(object_pos);
num_boundary=size(boundary_pos);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RPF computation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RPF_order = input('Please set the order of the potential field: ([]:default=6) ');

if isempty(RPF_order)
    RPF_order=6;
end

RPF_x=zeros(size(voxel));
RPF_y=zeros(size(voxel));
RPF_z=zeros(size(voxel));

for i=1:num_object(1)
    
    obj_pos=object_pos(i,:);
    [rx, ry, rz]=computeRPF(obj_pos, boundary_pos, num_boundary, RPF_order);  
    RPF_x(object_pos(i,1), object_pos(i,2), object_pos(i,3)) = rx;
    RPF_y(object_pos(i,1), object_pos(i,2), object_pos(i,3)) = ry;
    RPF_z(object_pos(i,1), object_pos(i,2), object_pos(i,3)) = rz;
    
end

DisMatrix = ComputeDisMatrix(voxel, boundary_pos, object_pos, num_boundary, num_object);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% critical points computation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

skeleton=zeros(size(voxel));
count=0;
critical_position=[];

NewtonTH = input('Please set the convergence critirial of Newton iterative searching method: ([]:default=1e-3) ');
if isempty(NewtonTH)
    NewtonTH=1e-3;
end

dth = input('Please set the minimum distance between the object boundary to the critical points: ([]:default=1) ');

if isempty(dth)
    dth=1;
end

for i=2:(rows-1)
    for j=2:(cols-1)
        for k=2:(slices-1)
          
        if  object(i,j,k)==1 
            
            [permit,critical] = ComputeCritical(RPF_x, RPF_y, RPF_z, boundary_pos, num_boundary, i, j, k, RPF_order, NewtonTH);
            
            if permit==1 && DisMatrix(floor(critical(1)+0.5), floor(critical(2)+0.5), floor(critical(3)+0.5))>=dth 
                count=count+1;
                critical_position(count,1)=critical(1);
                critical_position(count,2)=critical(2);
                critical_position(count,3)=critical(3);
                skeleton(floor(critical(1)+0.5),floor(critical(2)+0.5),floor(critical(3)+0.5))=255;
            end
            
        end
        
        end
    end
end

s=reshape(skeleton,prod(size(skeleton)),1);
[skeleton_x,skeleton_y,skeleton_z]=ind2sub(size(skeleton),find(s==255));
skeleton_pos=[skeleton_x,skeleton_y,skeleton_z];

show3D(XX,YY,ZZ,show,0.5,6,AZ,EL,0.1);
hold on
for i=1:size(skeleton_pos,1)
    plot3(skeleton_pos(i,2), skeleton_pos(i,1), skeleton_pos(i,3), 'r.');
    hold on
end
hold off
view(AZ,EL); 
axis tight
grid on 
if rev==1
    set(gca, 'ZDir','reverse');
end
title('critical points');
str='critical points';
filename = fullfile(foldername, [str '.' 'fig']);  
saveas(gcf, filename);
filename = fullfile(foldername, [str '.' 'jpg']);  
print(gcf, '-djpeg', filename); 

disp(' ');
prune = input('Do you want to filter your critical points?  ([]=yes, other = no) ','s');

if isempty(prune)
    
    skeleton2=skeleton;
    
    for i=1:3:(rows-2)
        for j=1:3:(cols-2)
            for k=1:3:(slices-2)
                box=skeleton(i:i+2, j:j+2, k:k+2);
                b=sum(sum(sum(box)));
                tt=DisMatrix(i:i+2, j:j+2, k:k+2);
                t=reshape(tt,1,27);
                [R,I]=max(t);
                
                if b>=3*255
                    [ii,jj,kk]=ind2sub(size(tt),I);
                    skeleton2(i:i+2, j:j+2, k:k+2)=0;
                    skeleton2(ii+i-1, jj+j-1, kk+k-1)=255;
                end
            end
        end
    end

    s=reshape(skeleton2,prod(size(skeleton2)),1);
    [skeleton_x,skeleton_y,skeleton_z]=ind2sub(size(skeleton2),find(s==255));
    skeleton_pos=[skeleton_x,skeleton_y,skeleton_z];
    critical_position2=[];
    count=0;
    for i=1:size(critical_position,1)
        xx=floor(critical_position(i,1)+0.5);
        yy=floor(critical_position(i,2)+0.5);
        zz=floor(critical_position(i,3)+0.5);
        
        if(skeleton2(xx,yy,zz)==255)
            count=count+1;
            critical_position2(count,1)=critical_position(i,1);
            critical_position2(count,2)=critical_position(i,2);
            critical_position2(count,3)=critical_position(i,3);
        end
    end
    critical_position=critical_position2;
    skeleton=skeleton2;
end;


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% critical points classification %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[attracting, repelling, saddle1, saddle2, attr_num, saddle1_num, saddle2_num, pathline1, pathline2a, pathline2b] = Critical_Classify(voxel, critical_position, boundary_pos, num_boundary, RPF_x, RPF_y, RPF_z, RPF_order, count);

show3D(XX,YY,ZZ,show,0.5,7,AZ,EL,0.1);
hold on

if saddle1_num>0
    s1=floor(saddle1 + 0.5*ones(saddle1_num,3));
    plot3(s1(:,2), s1(:,1), s1(:,3), 'r.', 'MarkerSize',12);
    hold on
end

if saddle2_num>0
    s2=floor(saddle2 + 0.5*ones(saddle2_num,3));
    plot3(s2(:,2), s2(:,1), s2(:,3), 'r.', 'MarkerSize',12);
    hold on
end

if attr_num>0
    a=floor(attracting + 0.5*ones(attr_num,3));
    plot3(a(:,2), a(:,1), a(:,3), 'b.', 'MarkerSize',12);
    hold on
end

hold off
view(AZ,EL); 
axis tight
title('critical points after classification');
if rev==1
    set(gca, 'ZDir','reverse');
end
str='critical points after classification';
filename = fullfile(foldername, [str '.' 'fig']);  
saveas(gcf, filename);
filename = fullfile(foldername, [str '.' 'jpg']);  
print(gcf, '-djpeg', filename); 

% if isempty(prune)
%     figure (7)
%     img4=imread('Skeleton_results\fig4.jpg');
%     img5=imread('Skeleton_results\fig5.jpg');
%     subplot(121);
%     image(img4);
%     title('critical points before pruning');
%     subplot(122);
%     image(img5);  
%     title('critical points after pruning');
% end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  connection begin %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[XXX1, YYY1, ZZZ1, XXX2a, YYY2a, ZZZ2a, XXX2b, YYY2b, ZZZ2b, full_skeleton] = Field_Trace(voxel, object, boundary_pos, num_boundary, saddle1, saddle2, attr_num, saddle1_num, saddle2_num, pathline1, pathline2a, pathline2b, RPF_order);

figure (8)
p5 = patch(isosurface(XX,YY,ZZ,show,0.5));
isonormals(XX,YY,ZZ,show,p5);
set(p5,'FaceColor','c','EdgeColor','none')
 
view(AZ,EL); 
daspect([1 1 1]);
axis tight
camlight; 
lighting phong;
alpha(0.1);

hold on

if saddle1_num>0
    s1=floor(saddle1 + 0.5*ones(saddle1_num,3));
    plot3(s1(:,2), s1(:,1), s1(:,3), 'r.', 'MarkerSize',10);
    hold on
end

if saddle2_num>0
    s2=floor(saddle2 + 0.5*ones(saddle2_num,3));
    plot3(s2(:,2), s2(:,1), s2(:,3), 'r.', 'MarkerSize',10);
    hold on
end

if attr_num>0
    a=floor(attracting + 0.5*ones(attr_num,3));
    plot3(a(:,2), a(:,1), a(:,3), 'b.', 'MarkerSize',10);
    hold on
end

if size(XXX1,1)>0 && size(YYY1,1)>0 && size(ZZZ1,1)>0
    for i=1:size(XXX1,2)
        plot3(YYY1(:,i), XXX1(:,i), ZZZ1(:,i), 'r');
        hold on
    end
end

if size(XXX2a,1)>0 && size(YYY2a,1)>0 && size(ZZZ2a,1)>0
    for i=1:size(XXX2a,2)
        plot3(YYY2a(:,i), XXX2a(:,i), ZZZ2a(:,i), 'r');
        hold on
    end
end

if size(XXX2b,1)>0 && size(YYY2b,1)>0 && size(ZZZ2b,1)>0
    for i=1:size(XXX2b,2)
        plot3(YYY2b(:,i), XXX2b(:,i), ZZZ2b(:,i), 'r');
        hold on
    end
end

hold off
title('skeleton of the data');
view(AZ,EL); 
axis tight
grid on

if rev==1
    set(gca, 'ZDir','reverse');
end
str='skeleton of the data';
filename = fullfile(foldername, [str '.' 'fig']);  
saveas(gcf, filename);
filename = fullfile(foldername, [str '.' 'jpg']);  
print(gcf, '-djpeg', filename);    

skeleton_X=[XXX1,XXX2a,XXX2b];
skeleton_Y=[YYY1,YYY2a,YYY2b];
skeleton_Z=[ZZZ1,ZZZ2a,ZZZ2b];
skeleton_X=skeleton_X';
skeleton_Y=skeleton_Y';
skeleton_Z=skeleton_Z';

s=struct('Name','data','X',skeleton_X,'Y',skeleton_Y,'Z',skeleton_Z,'AZ',AZ,'EL',EL,'Reverse',rev);
save('Skeleton_results\skeleton', '-struct', 's');

disp(' ');
disp('All work has been finished!');
disp(' ');

%%
% fitting = input('Do you want to fitting a line for the skeleton? ([]=no, other = yes) ','s');
% 
% if isempty(fitting)==0
%     b=reshape(full_skeleton,prod(size(full_skeleton)),1);
%     [indx,indy,indz]=ind2sub(size(full_skeleton),find(b==1));
%     skeleton_pos=[indx,indy,indz];
%     
%     count=size(indx,1);
%     count1=0;
%     count2=0;
%     
%     for i=1:count
%         if skeleton_pos(i,2)>(size(voxel,2)+1)/2
%             count1=count1+1;
%             sk1(count1,:)=skeleton_pos(i,:);
%         else
%             count2=count2+1;
%             sk2(count2,:)=skeleton_pos(i,:);
%         end
%     end
% 
%     [a1,b1,c1,d1]=linefit3D(sk1);
%     [a2,b2,c2,d2]=linefit3D(sk2);
%     
%     x1 = a1*sk1(:,3) + b1;
%     y1 = c1*sk1(:,3) + d1;
%     z1 = sk1(:,3);
%     
%     x2 = a2*sk2(:,3) + b2;
%     y2 = c2*sk2(:,3) + d2;
%     z2 = sk2(:,3);
%     
%     show3D(XX,YY,ZZ,show,0.5,8,AZ,EL, 0.1);
%     hold on
%     
%     plot3(y1,x1,z1,'r');
%     hold on
%     plot3(y2,x2,z2,'r');
%     title('main direction of the skeleton');
%     hold off
%     view(AZ,EL); 
%     axis tight
%     grid on 
%     if rev==1
%         set(gca, 'ZDir','reverse');
%     end
%     print(gcf, '-djpeg', 'result1\fig7');   
%     
% end

function DistMethod(voxel, show, rows, cols, slices, XX, YY, ZZ, AZ, EL, rev)

foldername='Skeleton_results';

%%
[object_pos, boundary_pos, object, boundary] = segmentation(voxel, rows, cols, slices);
num_object=size(object_pos);
num_boundary=size(boundary_pos);

%%
DisMatrix = ComputeDisMatrix(voxel, boundary_pos, object_pos, num_boundary, num_object);

th = input('Please set a distance value threshold to the selected skeleton points.([]=default: 1): ');

if isempty(th)
    th = 1;
end

disp('Please choose a method to find the skeleton points from the following:');
disp(' ');
disp('******************************************************');
disp('1     filtering with 6-adjacent neighbors');
disp('2     filtering with 18-adjacent neighbors');
disp('3     filtering with 26-adjacent neighbors');
disp('4     filtering with 124-adjacent neighbors');
disp('5     filtering with 342-adjacent neighbors');
disp('6     exposure computation');
disp('******************************************************');
disp(' ');

method = input('Please choose a method (1~4): ');

switch method
    case 1,
        [num_ridge, ridge, ridge_pos] = Findpoints_filter6(voxel, DisMatrix, rows, cols, slices, th);
    case 2,
        [num_ridge, ridge, ridge_pos] = Findpoints_filter18(voxel, DisMatrix, rows, cols, slices, th);
    case 3,
        [num_ridge, ridge, ridge_pos] = Findpoints_filter26(voxel, DisMatrix, rows, cols, slices, th);
    case 4,
        [num_ridge, ridge, ridge_pos] = Findpoints_filter124(voxel, DisMatrix, rows, cols, slices, th);
    case 5,
        [num_ridge, ridge, ridge_pos] = Findpoints_filter342(voxel, DisMatrix, rows, cols, slices, th);
    case 6,
        [num_ridge, ridge, ridge_pos] = Findpoints_exposure(voxel, DisMatrix, rows, cols, slices);    
end

show3D(XX,YY,ZZ,show,0.5,6,AZ,EL,0.1);
hold on
point_x=ridge_pos(1:num_ridge(1),2);
point_y=ridge_pos(1:num_ridge(1),1);
point_z=ridge_pos(1:num_ridge(1),3);

plot3(point_x, point_y, point_z, 'r*');
hold off
title('data with skeleton points');
view(AZ,EL); 
axis tight
grid on 

if rev==1
    set(gca, 'ZDir','reverse');
end
str='skeleton points';
filename = fullfile(foldername, [str '.' 'fig']);  
saveas(gcf, filename);
filename = fullfile(foldername, [str '.' 'jpg']);  
print(gcf, '-djpeg', filename); 

%%
T=connection(voxel, num_ridge, ridge_pos, rows, cols, slices);
[m,n]=size(T);

show3D(XX,YY,ZZ,show,0.5,7,AZ,EL,0.1);
hold on

for i=1:m
    for j=i:n
       
        if T(i,j)==1
            start_x=ridge_pos(i,2);
            start_y=ridge_pos(i,1);
            start_z=ridge_pos(i,3);
            end_x=ridge_pos(j,2);
            end_y=ridge_pos(j,1);
            end_z=ridge_pos(j,3);
            
            plot3([start_x,end_x],[start_y,end_y],[start_z,end_z], '-rs','LineWidth',2, 'MarkerEdgeColor','k', 'MarkerFaceColor','y',  'MarkerSize',3);
            hold on
        end       
        
    end
end

hold off
title('skeleton of the data');
view(AZ, EL); 
axis tight
% grid on 
if rev==1
    set(gca, 'ZDir','reverse');
end
str='skeleton of the data';
filename = fullfile(foldername, [str '.' 'fig']);  
saveas(gcf, filename);
filename = fullfile(foldername, [str '.' 'jpg']);  
print(gcf, '-djpeg', filename); 

% index=0;  
% for i=1:m
%     for j=i:n
%         if T(i,j)==1
%             index=index+1;
%             start_x=ridge_pos(i,1);
%             start_y=ridge_pos(i,2);
%             start_z=ridge_pos(i,3);
%             end_x=ridge_pos(j,1);
%             end_y=ridge_pos(j,2);
%             end_z=ridge_pos(j,3);
%             
%             [CoorX, CoorY, CoorZ]=ExtractPoints(start_x,start_y,start_z,end_x,end_y,end_z,50);
%             nu=size(CoorX,2);
%             C1=[CoorX,CoorX(nu)*ones(1,50-nu)];
%             C2=[CoorY,CoorY(nu)*ones(1,50-nu)];
%             C3=[CoorZ,CoorZ(nu)*ones(1,50-nu)];
%                 
%             skeleton_X(index,:)=C1;
%             skeleton_Y(index,:)=C2;
%             skeleton_Z(index,:)=C3;
%         end
%     end
% end


connect_num=sum(sum(T))/2;
[sk_X,sk_Y,sk_Z]=GetSkel(T,ridge_pos,connect_num,rows,cols,slices,50);
skel_X=reshape(sk_X, [50, connect_num]);
skel_Y=reshape(sk_Y, [50, connect_num]);
skel_Z=reshape(sk_Z, [50, connect_num]);
skeleton_X=skel_X';
skeleton_Y=skel_Y';
skeleton_Z=skel_Z';

s=struct('Name','data','X',skeleton_X,'Y',skeleton_Y,'Z',skeleton_Z,'AZ',AZ,'EL',EL,'Reverse',rev);
save('Skeleton_results\skeleton', '-struct', 's');
disp(' ');
disp('All work has been finished!');
disp(' ');


%%
% fitting = input('Do you want to fitting a line for the skeleton? ([]=no, other = yes) ','s');
% 
% if isempty(fitting)==0
%     count1=0;
%     count2=0;
%     
%     for i=1:num_ridge(1)
%         if ridge_pos(i,2)>(size(voxel,2)+1)/2
%             count1=count1+1;
%             rig1(count1,:)=ridge_pos(i,:);
%         else
%             count2=count2+1;
%             rig2(count2,:)=ridge_pos(i,:);
%         end
%     end
% 
%     [a1,b1,c1,d1]=linefit3D(rig1);
%     [a2,b2,c2,d2]=linefit3D(rig2);
% 
%     x1 = a1*rig1(:,3) + b1;
%     y1 = c1*rig1(:,3) + d1;
%     z1 = rig1(:,3);
% 
%     x2 = a2*rig2(:,3) + b2;
%     y2 = c2*rig2(:,3) + d2;
%     z2 = rig2(:,3);
% 
%     show3D(XX,YY,ZZ,show,0.5,6,AZ, EL, 0.05);
%     hold on
% 
%     plot3(y1,x1,z1,'k',rig1(:,2),rig1(:,1),rig1(:,3),'r*');
%     hold on
%     plot3(y2,x2,z2,'k',rig2(:,2),rig2(:,1),rig2(:,3),'r*');
%     title('main direction of the skeleton');
%     hold off
%     view(AZ, EL); 
%     axis tight
%     %grid on 
%     if rev==1
%         set(gca, 'ZDir','reverse');
%     end
%     print(gcf, '-djpeg', 'result1\fig6');   
%     
% end



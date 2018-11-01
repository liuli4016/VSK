function ThinningMethod(voxel, show, rows, cols, slices, XX, YY, ZZ, AZ, EL, rev)

foldername='Skeleton_results';

updown=zeros(size(voxel));
leftright=zeros(size(voxel));
frontrear=zeros(size(voxel));

for i=1:rows
    temp1=voxel(i,:,:);
    img=reshape(temp1,[cols slices]);
    skeleton1=bwmorph(img,'skel',Inf);
    leftright(i,:,:)=skeleton1;
end

for j=1:cols
    temp2=voxel(:,j,:);
    img=reshape(temp2,[rows slices]);
    skeleton2=bwmorph(img,'skel',Inf);
    frontrear(:,j,:)=skeleton2;
end

for k=1:slices
    temp3=voxel(:,:,k);
    img=reshape(temp3,[rows cols]);
    skeleton3=bwmorph(img,'skel',Inf);
    updown(:,:,k)=skeleton3;
end

%%
full_skeleton = updown & frontrear & leftright;

b=reshape(full_skeleton,prod(size(full_skeleton)),1);
[indx1,indy1,indz1]=ind2sub(size(full_skeleton),find(b==1));
skeleton_pos=[indx1,indy1,indz1];
num_skeleton=size(skeleton_pos);

T=connection(voxel, num_skeleton, skeleton_pos, rows, cols, slices);
[m,n]=size(T);

show3D(XX,YY,ZZ,show,0.5,6,AZ,EL,0.1);
hold on

for i=1:m
    for j=i:n
       
        if T(i,j)==1
            start_x=skeleton_pos(i,2);
            start_y=skeleton_pos(i,1);
            start_z=skeleton_pos(i,3);
            end_x=skeleton_pos(j,2);
            end_y=skeleton_pos(j,1);
            end_z=skeleton_pos(j,3);
            
            plot3([start_x,end_x],[start_y,end_y],[start_z,end_z], '-r','LineWidth',2);
            hold on
        end       
        
    end
end

hold off
title('skeleton of the data');
view(AZ,EL); 
axis tight
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
%             start_x=skeleton_pos(i,1);
%             start_y=skeleton_pos(i,2);
%             start_z=skeleton_pos(i,3);
%             end_x=skeleton_pos(j,1);
%             end_y=skeleton_pos(j,2);
%             end_z=skeleton_pos(j,3);
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
[sk_X,sk_Y,sk_Z]=GetSkel(T,skeleton_pos,connect_num,rows,cols,slices,50);
skel_X=reshape(sk_X, [50, connect_num]);
skel_Y=reshape(sk_Y, [50, connect_num]);
skel_Z=reshape(sk_Z, [50, connect_num]);
skeleton_X=skel_X';
skeleton_Y=skel_Y';
skeleton_Z=skel_Z';

s=struct('Name','data','X',skeleton_X,'Y',skeleton_Y,'Z',skeleton_Z,'AZ',AZ,'EL',EL,'Reverse',rev);
save('Skeleton_results\skeleton', '-struct', 's');

%%
pr = input('Do you want to prune the skeleton of the data?  ([] = yes, other = no) ','s');

if isempty(pr)
    [endpoint,X1,X2]=find_endpoint_3D(full_skeleton);
    skeleton = full_skeleton - X2;
    
    sk=skeleton;
    
    for i=2:(rows-1)
        for j=2:(cols-1)
            for k=2:(slices-1)
                tt=sk(i-1:i+1, j-1:j+1, k-1:k+1);
                t=reshape(tt,1,27);         
                
                if sum(t)==1 && sk(i,j,k)==1
                    skeleton(i,j,k)=0;
                end
            end
        end
    end

    b=reshape(skeleton,prod(size(skeleton)),1);
    [indx1,indy1,indz1]=ind2sub(size(skeleton),find(b==1));
    skeleton_pos=[indx1,indy1,indz1];
    num_skeleton=size(skeleton_pos);

    T=connection(voxel, num_skeleton, skeleton_pos, rows, cols, slices);
    [m,n]=size(T);

    show3D(XX,YY,ZZ,show,0.5,7,AZ,EL,0.1);
    hold on

    for i=1:m
        for j=i:n
            
            if T(i,j)==1
                start_x=skeleton_pos(i,2);
                start_y=skeleton_pos(i,1);
                start_z=skeleton_pos(i,3);
                end_x=skeleton_pos(j,2);
                end_y=skeleton_pos(j,1);
                end_z=skeleton_pos(j,3);
            
                plot3([start_x,end_x],[start_y,end_y],[start_z,end_z], '-r','LineWidth',2);
                hold on
            end       
        
        end
    end

    hold off
    title('skeleton of the data after pruning');
    view(AZ,EL); 
    axis tight
    if rev==1
        set(gca, 'ZDir','reverse');
    end
    str='skeleton of the data after pruning';
    filename = fullfile(foldername, [str '.' 'fig']);  
    saveas(gcf, filename);
    filename = fullfile(foldername, [str '.' 'jpg']);  
    print(gcf, '-djpeg', filename);         
end

disp(' ');
disp('All work has been finished!');
disp(' ');


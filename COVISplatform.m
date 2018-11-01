clear all
close all
clc

disp(' ');
disp('***************************************************************');
disp('****** Welcome to COVIS Plume Data Processing Platform! *******');
disp('***************************************************************');

%%

AZ=170;
EL=15;

[FileName,PathName] = uigetfile('*.mat', 'Select all the mat-files', 'MultiSelect', 'on');  
cc=size(FileName,2);

fprintf('\nYou chose %d COVIS data sets.\n\n',cc);

tic

for ii = 1:cc    
    filepath{1,ii} = fullfile(PathName, FileName{ii});
end

Foldername=strcat('COVIS_results_', date);
mkdir(Foldername);

if(~exist(Foldername,'dir'))
    mkdir(Foldername);
end

for data_num=1:cc
    close all
    fprintf('Begin to process %dth data...\n',data_num);
    load(filepath{1,data_num})
    
    xmin=covis.grid.bounds.xmin;
    ymin=covis.grid.bounds.ymin;
    zmin=covis.grid.bounds.zmin;
    xmax=covis.grid.bounds.xmax;
    ymax=covis.grid.bounds.ymax;
    zmax=covis.grid.bounds.zmax;
    
    scale=4;
    
    Name = covis.grid.name;
    month{data_num}=Name(26:27);
    day{data_num}=Name(28:29);
    hour{data_num}=Name(31:32);
    Month=str2num(month{data_num});
    Day=str2num(day{data_num});
    Hour=str2num(hour{data_num});
    datevalue(data_num)=date2number(Month,Day,Hour);
    
    NameGroup{data_num}=Name;
    Name(strfind(Name,'_'))='-';
    foldername=fullfile(Foldername, Name);
    mkdir(foldername);
    
    [h, covis] = my_covis_imaging_plot(covis, 'covis_image_plot.json', 1);   
    title(Name);
    filename = fullfile(foldername, [Name '.' 'fig']);  
    saveas(gcf, filename);
    filename = fullfile(foldername, [Name '.' 'jpg']); 
    print(gcf, '-djpeg', filename);

    
    data = covis.grid.v;
    [rows, cols, slices] = size(data);
    data(isnan(data))=0; 
    th=9*1e-9;
    th1=2*th;

%     [XX,YY,ZZ] = meshgrid(1:cols, 1:rows, 1:slices);
    XX=covis.grid.x;
    YY=covis.grid.y;
    ZZ=covis.grid.z;
    voxel=zeros(size(data));    
    voxel(data>th)=1;
    voxel_src=voxel;
    show=zeros(size(data));
    show(data>th1)=1;
    
    voxel_dilated=imdilate(voxel, ones(7,7,7));
    voxel_eroded=imerode(voxel_dilated, ones(7,7,7));
    v=voxel_eroded;
    voxel=v;
    
    [object_pos, boundary_pos, object, boundary] = segmentation(voxel, rows, cols, slices);
    num_object=size(object_pos);
    num_boundary=size(boundary_pos);
    
    %%
    DisMatrix = ComputeDisMatrix(voxel, boundary_pos, object_pos, num_boundary, num_object);
    %[num_ridge, ridge, ridge_pos] = Findpoints_filter26(data, DisMatrix, rows, cols, slices, 6);
    
    ridge=filter26(voxel, DisMatrix, rows, cols, slices, 9, 2);
    ridge=reshape(ridge,[rows, cols, slices]);  
    b=reshape(ridge,prod(size(ridge)),1);
    [indx3,indy3,indz3]=ind2sub(size(ridge),find(b==255));
    ridge_pos=[indx3,indy3,indz3];
    num_ridge=size(ridge_pos);


    show3D(XX,YY,ZZ,show,0.5,2,AZ,EL, 0.1);
    hold on
%     point_x=ridge_pos(1:num_ridge(1),2);
%     point_y=ridge_pos(1:num_ridge(1),1);
%     point_z=ridge_pos(1:num_ridge(1),3);
    point_x=(ridge_pos(1:num_ridge(1),2)-ones(size(num_ridge(1),1)))./scale+xmin*ones(size(num_ridge(1),1));
    point_y=(ridge_pos(1:num_ridge(1),1)-ones(size(num_ridge(1),1)))./scale+ymin*ones(size(num_ridge(1),1));
    point_z=(ridge_pos(1:num_ridge(1),3)-ones(size(num_ridge(1),1)))./scale+zmin*ones(size(num_ridge(1),1));

            
    plot3(point_x, point_y, point_z, 'r*');
    str=strcat('Skeleton Point_', Name);
    str(strfind(str,'_'))='-';
    title(str);
    filename = fullfile(foldername, [str '.' 'fig']);  
    saveas(gcf, filename);
    filename = fullfile(foldername, [str '.' 'jpg']);  
    print(gcf, '-djpeg', filename);
    
    
    %%
    T=connection(voxel, num_ridge, ridge_pos, rows, cols, slices);
    [m,n]=size(T);
    [h, covis] = my_covis_imaging_plot(covis, 'covis_image_plot.json', 3);
    hold on

    con=zeros(size(ridge_pos,1));
    for i=1:m
        for j=i:n
            if T(i,j)==1               
                con(i)=1;
                con(j)=1;
                start_x=ridge_pos(i,2);
                start_y=ridge_pos(i,1);
                start_z=ridge_pos(i,3);
                end_x=ridge_pos(j,2);
                end_y=ridge_pos(j,1);
                end_z=ridge_pos(j,3);
                
                start_x=round( (start_x-1)/scale+xmin );
                start_y=round( (start_y-1)/scale+ymin );
                start_z=round( (start_z-1)/scale+zmin );
                end_x=round( (end_x-1)/scale+xmin );
                end_y=round( (end_y-1)/scale+ymin );
                end_z=round( (end_z-1)/scale+zmin );
            
                plot3([start_x,end_x],[start_y,end_y],[start_z,end_z], '-rs','LineWidth',1, 'MarkerEdgeColor','k', 'MarkerFaceColor','y',  'MarkerSize',3);
                hold on
            end
        end
    end
    hold off
    
    
    str=strcat('Skeleton_', Name);
    str(strfind(str,'_'))='-';
    title(str);
    filename = fullfile(foldername, [str '.' 'fig']);  
    saveas(gcf, filename);
    filename = fullfile(foldername, [str '.' 'jpg']); 
    print(gcf, '-djpeg', filename);   

    connect_num=sum(sum(T))/2;
    [sk_X,sk_Y,sk_Z]=GetSkel(T,ridge_pos,connect_num,rows,cols,slices,50);
    skel_X=reshape(sk_X, [50, connect_num]);
    skel_Y=reshape(sk_Y, [50, connect_num]);
    skel_Z=reshape(sk_Z, [50, connect_num]);
    skelet_X=skel_X';
    skelet_Y=skel_Y';
    skelet_Z=skel_Z';
    skeleton_X = (skelet_X-ones(size(skelet_X)))./scale + ymin*ones(size(skelet_X));
    skeleton_Y = (skelet_Y-ones(size(skelet_Y)))./scale + xmin*ones(size(skelet_Y));
    skeleton_Z = (skelet_Z-ones(size(skelet_Z)))./scale + zmin*ones(size(skelet_Z));
    
    str=strcat('Skeleton Positions_', Name);
    str(strfind(str,'_'))='-'; 
    filename = fullfile(foldername, [str '.' 'mat']);   
    s=struct('Name',Name,'X',skeleton_X,'Y',skeleton_Y,'Z',skeleton_Z,'AZ',AZ,'EL',EL,'Reverse',0);
    save(filename, '-struct', 's');
    
    count1=0;
    count2=0;
    rig1=[];
    rig2=[];   
    x1=[];
    x2=[];
    y1=[];
    y2=[];
    z1=[];
    z2=[];
    for i=1:num_ridge(1)
        if ridge_pos(i,2)>(cols+1)/2 && con(i)==1
            count1=count1+1;
            rig1(count1,:)=ridge_pos(i,:);
        end
        if ridge_pos(i,2)<=(cols+1)/2 && con(i)==1
            count2=count2+1;
            rig2(count2,:)=ridge_pos(i,:);
        end
    end
    
    show3D(XX,YY,ZZ,show,0.5,4,AZ,EL, 0.05);
    hold on
    
    if count1>=2
        [a1,b1,c1,d1]=linefit3D(rig1);
        x1 = a1*rig1(:,3) + b1;
        y1 = c1*rig1(:,3) + d1;
        z1 = rig1(:,3);
        x1 = (x1-ones(size(x1)))./scale + ymin*ones(size(x1));
        y1 = (y1-ones(size(y1)))./scale + xmin*ones(size(y1));
        z1 = (z1-ones(size(z1)))./scale + zmin*ones(size(z1));
        rig1(:,1) = (rig1(:,1)-ones(size(rig1(:,1))))./scale + ymin*ones(size(rig1(:,1)));
        rig1(:,2) = (rig1(:,2)-ones(size(rig1(:,2))))./scale + xmin*ones(size(rig1(:,2)));
        rig1(:,3) = (rig1(:,3)-ones(size(rig1(:,3))))./scale + zmin*ones(size(rig1(:,3)));
        plot3(y1,x1,z1,'k',rig1(:,2),rig1(:,1),rig1(:,3),'r*');
        hold on
    end
    
    if count2>=2
        [a2,b2,c2,d2]=linefit3D(rig2);
        x2 = a2*rig2(:,3) + b2;
        y2 = c2*rig2(:,3) + d2;
        z2 = rig2(:,3);    
        x2 = (x2-ones(size(x2)))./scale + ymin*ones(size(x2));
        y2 = (y2-ones(size(y2)))./scale + xmin*ones(size(y2));
        z2 = (z2-ones(size(z2)))./scale + zmin*ones(size(z2));   
        rig2(:,1) = (rig2(:,1)-ones(size(rig2(:,1))))./scale + ymin*ones(size(rig2(:,1)));
        rig2(:,2) = (rig2(:,2)-ones(size(rig2(:,2))))./scale + xmin*ones(size(rig2(:,2)));
        rig2(:,3) = (rig2(:,3)-ones(size(rig2(:,3))))./scale + zmin*ones(size(rig2(:,3)));
        plot3(y2,x2,z2,'k',rig2(:,2),rig2(:,1),rig2(:,3),'r*');
        hold on
    end
    hold off
    view(AZ,EL); 
    axis tight
    grid on 
    
    str=strcat('Main Direction_', Name);
    str(strfind(str,'_'))='-';
    title(str);
    filename = fullfile(foldername, [str '.' 'fig']);
    saveas(gcf, filename);
    filename = fullfile(foldername, [str '.' 'jpg']);
    print(gcf, '-djpeg', filename);

    [h, covis] = my_covis_imaging_plot(covis, 'covis_image_plot.json', 5);
    hold on

    if count1>=2
        plot3(y1,x1,z1,'k','linewidth', 1.5);
        hold on
    end
    if count2>=2
        plot3(y2,x2,z2,'k','linewidth', 1.5);
        hold on
    end
    hold off
    
    str=strcat('Final Result_', Name);
    str(strfind(str,'_'))='-'; 
    title(str);
    filename = fullfile(foldername, [str '.' 'fig']);
    saveas(gcf, filename);
    filename = fullfile(foldername, [str '.' 'jpg']);
    print(gcf, '-djpeg', filename);   
   
    if count1>=2
        [TH,R,Z] = cart2pol(a1,c1,1);
        if TH>=0 && TH<pi/2
            angle_horizontal1(data_num) = (pi/2-TH)*180/pi;
        elseif TH>=pi/2 && TH<pi
            angle_horizontal1(data_num) = (2*pi+pi/2-TH)*180/pi;
        elseif TH>=-pi && TH<-pi/2
            angle_horizontal1(data_num) = (pi/2-TH)*180/pi;
        elseif TH>=-pi/2 && TH<0
            angle_horizontal1(data_num) = (pi/2-TH)*180/pi;
        end
        angle_vertical1(data_num)= acos(1/sqrt(a1*a1+c1*c1+1))*180/pi;
    else
        angle_horizontal1(data_num) = 0;
        angle_vertical1(data_num) = 0;
    end
         
    if count2>=2
        [TH,R,Z] = cart2pol(a2,c2,1);
        if TH>=0 && TH<pi/2
            angle_horizontal2(data_num) = (pi/2-TH)*180/pi;
        elseif TH>=pi/2 && TH<pi
            angle_horizontal2(data_num) = (2*pi+pi/2-TH)*180/pi;
        elseif TH>=-pi && TH<-pi/2
            angle_horizontal2(data_num) = (pi/2-TH)*180/pi;
        elseif TH>=-pi/2 && TH<0
            angle_horizontal2(data_num) = (pi/2-TH)*180/pi;
        end
        angle_vertical2(data_num) = acos(1/sqrt(a2*a2+c2*c2+1))*180/pi;
    else
        angle_horizontal2(data_num) = 0;
        angle_vertical2(data_num) = 0;
    end
    
end

for i=1:cc
    Mean_Horizontal1=mean(angle_horizontal1);
    Mean_Horizontal2=mean(angle_horizontal2);
    Mean_Vertical1=mean(angle_vertical1);
    Mean_Vertical2=mean(angle_vertical2);
    Std_Horizontal1=std(angle_horizontal1);
    Std_Horizontal2=std(angle_horizontal2);
    Std_Vertical1=std(angle_vertical1);
    Std_Vertical2=std(angle_vertical2);  
end

time=toc;

%%
disp(' ');
disp('Data Processing is completed!');
disp(' ');
fprintf('Elapsed time is %f seconds.\n',time);

Start=find(min(datevalue));
End=find(max(datevalue));
figure('Name','Bending Angle of small Plume','NumberTitle','off')
subplot(211);
for i=1:cc
    plot(datevalue(i), angle_horizontal1(i), 'r*');
    hold on
end
hold off
m1=min(datevalue);
m2=max(datevalue);
axis([m1-str2num(hour{Start}) m2 0 400]);
h=((m1-str2num(hour{Start})): 24 : m2);
set(gca, 'XTick', h);
for i=1:size(h,2)
    stringx{i}=number2date(h(i));
end
set(gca,'XTickLabel',stringx);
xlabel('Date');
ylabel('Degree');
title('Bending angle with respect to Positive Y-axis');

subplot(212);
for i=1:cc
    plot(datevalue(i), angle_vertical1(i), 'b*');
    hold on
end
hold off
axis([m1-str2num(hour{Start}) m2 0 90]);
set(gca, 'XTick', h);
set(gca,'XTickLabel',stringx);
xlabel('Date');
ylabel('Degree');
title('Bending angle with respect to Z=0 plane');

str=strcat('Bending_small plume_', datestr(now,30));
filename = fullfile(Foldername, [str '.' 'jpg']);   
print(gcf, '-djpeg', filename);
 
figure('Name','Bending Angle of Big Plume','NumberTitle','off')
subplot(211);
for i=1:cc
    plot(datevalue(i), angle_horizontal2(i), 'r*');
    hold on
end
hold off
axis([m1-str2num(hour{Start}) m2 0 400]);
set(gca, 'XTick', h);
set(gca,'XTickLabel',stringx);
xlabel('Date');
ylabel('Degree');
title('Bending angle with respect to Positive Y-axis');
subplot(212);
for i=1:cc
    plot(datevalue(i), angle_vertical2(i), 'b*');
    hold on
end
hold off
axis([m1-str2num(hour{Start}) m2 0 90]);
set(gca, 'XTick', h);
set(gca,'XTickLabel',stringx);
xlabel('Date');
ylabel('Degree');
title('Bending angle with respect to Z=0 plane');

str=strcat('Bending_big plume_', datestr(now,30));
filename = fullfile(Foldername, [str '.' 'jpg']);   
print(gcf, '-djpeg', filename);

str=strcat('proecssing report_', datestr(now,30));
filename = fullfile(Foldername, [str '.' 'txt']); 
fid = fopen(filename,'wt+');
fprintf(fid,'\nDate: %s.\n\n',datestr(now,31));
fprintf(fid,'Elapsed time: %f seconds.\n\n',time);
fprintf(fid,'Data number: %d.\n\n\n\n',cc);
fprintf(fid,'\t\t\t\t\t\t\t\t\t%s\t','vertical_big');
fprintf(fid,'\t%s\t','horizontal_big');
fprintf(fid,'\t%s\t','vertical_small');
fprintf(fid,'\t%s\n\n','horizontal_small');

for i = 1:cc
    fprintf(fid,'%d: %s\t\t',i,NameGroup{i}); 
    fprintf(fid,'%f\t\t',angle_vertical2(i));
    fprintf(fid,'%f\t\t',angle_horizontal2(i));
    fprintf(fid,'%f\t\t',angle_vertical1(i));
    fprintf(fid,'%f\n',angle_horizontal1(i));
end

fprintf(fid,'\n\t\t\t\t%s\t\t\t\t\t','mean');
fprintf(fid,'%f\t\t',Mean_Vertical2);
fprintf(fid,'%f\t\t',Mean_Horizontal2);
fprintf(fid,'%f\t\t',Mean_Vertical1);
fprintf(fid,'%f\n',Mean_Horizontal1);
fprintf(fid,'\t\t\t\t%s\t\t\t\t\t','std');
fprintf(fid,'%f\t\t',Std_Vertical2);
fprintf(fid,'%f\t\t',Std_Horizontal2);
fprintf(fid,'%f\t\t',Std_Vertical1);
fprintf(fid,'%f\n',Std_Horizontal1);

fclose(fid);



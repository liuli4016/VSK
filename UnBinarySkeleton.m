function UnBinarySkeleton(data)

foldername='Skeleton_results';

if(~exist(foldername,'dir'))
    mkdir(foldername);
end

[rows, cols, slices] = size(data);
data(isnan(data))=0; 
voxel=zeros(size(data));
his = input('Do you want to show the histogram of the data?  ([]=no, other = yes) ','s');
if isempty(his)==0
    figure
    hist(data);   
end

disp(' ');
th = input('Please set a threshold to the data ([]=default: (minimum value + maximum value)/2 )');
large = input('Is the value of object voxel larger than that of background voxel?  ([] = yes, other = no) ','s');

if isempty(th)
    th = ( min(min(min(data))) + max(max(max(data))) )/2 ;
end
if isempty(large)
    voxel(data>th)=1;  
else
    voxel(data<th)=1;
end

AZ = input('Please input the horizontal rotation angle w.r.t origin: ([]:default=305): ');
if isempty(AZ)
    AZ=305;
end

EL = input('Please input the vertical rotation angle w.r.t origin: ([]:default=15): ');
if isempty(EL)
    EL=15;
end

[XX,YY,ZZ] = meshgrid(1:cols, 1:rows, 1:slices);
show3D(XX,YY,ZZ,voxel,0.5,3,AZ,EL,1);
title('original data');

disp(' ');
reverse = input('Do you want to reverse the data view?  ([]=no, other = yes) ','s');

if isempty(reverse)
    rev=0;   
else
    set(gca, 'ZDir','reverse');
    disp('The data view has been reversed!');
    rev=1;
end
str='original data';
filename = fullfile(foldername, [str '.' 'fig']);  
saveas(gcf, filename);
filename = fullfile(foldername, [str '.' 'jpg']);  
print(gcf, '-djpeg', filename);

show=voxel;

decision = input('Do you want to use morphological operation to fill with the black hollows of the data?  ([]=yes, other = no) ','s');

if isempty(decision)
    str_size = input('Please input the size of the structure element (default: 7): ');
    
    if isempty(str_size)
        str_size=7;
        voxel_dilated=imdilate(voxel, ones(str_size,str_size,str_size));
        voxel_eroded=imerode(voxel_dilated, ones(str_size,str_size,str_size));
        v=voxel_eroded;
        voxel=v;
        show3D(XX,YY,ZZ,voxel,0.5,4,AZ,EL, 1);
        title('Morphological processed data');
        if rev==1
            set(gca, 'ZDir','reverse');
        end
        str='Morphological processed data';
        filename = fullfile(foldername, [str '.' 'fig']);  
        saveas(gcf, filename);
        filename = fullfile(foldername, [str '.' 'jpg']);  
        print(gcf, '-djpeg', filename);
    else
        voxel_dilated=imdilate(voxel, ones(str_size,str_size,str_size));
        voxel_eroded=imerode(voxel_dilated, ones(str_size,str_size,str_size));
        v=voxel_eroded;
        voxel=v;
        show3D(XX,YY,ZZ,voxel,0.5,4,AZ,EL, 1);
        title('Morphological processed data');
        if rev==1
            set(gca, 'ZDir','reverse');
        end
        str='Morphological processed data';
        filename = fullfile(foldername, [str '.' 'fig']);  
        saveas(gcf, filename);
        filename = fullfile(foldername, [str '.' 'jpg']);  
        print(gcf, '-djpeg', filename);
    end
    
end

%%
decision = input('Do you want to use 3D filter to filter your data?  ([]=yes, other = no) ','s');

if isempty(decision)
    disp('Please choose a type of the filter from the following:');
    disp(' ');
    disp('******************************************************');
    disp('average     averaging filter');
    disp('ellipsoid   ellipsoidal averaging filter');
    disp('gaussian    Gaussian lowpass filter');
    disp('laplacian   Laplacian operator');
    disp('log         Log of Gaussian filter');
    disp('******************************************************');
    disp(' ');
    filter_type = input('Please choose the type of the filter: ','s');
    filter_size = input('Please set a size to your filter (usually 3~9): ');
    filter=fspecial3(filter_type, filter_size);
    voxel2=imfilter(voxel, filter);
    voxel=voxel2;
    voxel((voxel>0))=1;
    show3D(XX,YY,ZZ,voxel,0.5,5,AZ,EL, 1);    
    title('Filtered data');
    if rev==1
        set(gca, 'ZDir','reverse');
    end
    str='Filtered data';
    filename = fullfile(foldername, [str '.' 'fig']);  
    saveas(gcf, filename);
    filename = fullfile(foldername, [str '.' 'jpg']);  
    print(gcf, '-djpeg', filename);    
end

%%
disp(' ');
disp('Please choose a method to compute the skeleton:');
disp(' ');
disp('******************************************************');
disp('1     Distance Matrix Method');
disp('2     Repulsive Potential Field Method');
disp('3     Thinning Method');
disp('******************************************************');
disp(' ');

method = input('Please choose a method (1~3): ');

switch method
    case 1,
        disp('You have chosen Distance Matrix Method.');
        DistMethod(voxel, show, rows, cols, slices, XX, YY, ZZ, AZ, EL, rev);
    case 2,
        disp('You have chosen Repulsive Potential Field Method.');
        RPFMethod(voxel, show, rows, cols, slices, XX, YY, ZZ, AZ, EL, rev);
    case 3,
        disp('You have chosen Thinning Method.');
        ThinningMethod(voxel, show, rows, cols, slices, XX, YY, ZZ, AZ, EL, rev);
end


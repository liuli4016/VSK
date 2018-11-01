clear all
%close all
clc

disp(' ');
disp('******************************************************');
disp('****** Welcome to use Volume Skeleton toolbox! *******');
disp('******************************************************');

disp(' ');
disp('Please open your volume data.');
disp(' ');

[FileName,PathName] = uigetfile('*.mat', '*.vol', 'Select data file');
filepath = fullfile(PathName, FileName);

%str=[PathName, FileName];

while isempty(filepath)
    [FileName,PathName] = uigetfile('*.mat', '*.vol', 'Select data file');
    %str=[PathName, FileName];
    filepath = fullfile(PathName, FileName);
end

if isequal(FileName,0)   
    disp('User selected Cancel')
else
    disp(['User selected: ', fullfile(PathName, FileName)])
end

[TYPE, OPENCMD, LOADCMD, DESCR] = finfo(filepath);

if strcmp(TYPE, 'mat')==1
    load([PathName FileName]);
    data = covis.grid.v;

    disp(' ');
    disp('Data loading is completed!');
    disp(' ');
        
    Max = max(max(max(data)));
    Min = min(min(min(data)));
    Min2 = data(find(data>0,1));
    
    if Min2 == Max
        BinarySkeleton(data);
    else
        UnBinarySkeleton(data);
    end
end


if strcmp(TYPE, 'vol')==1 || strcmp(TYPE, 'img')==1 || strcmp(TYPE, 'unknown')==1
    fid=fopen([PathName FileName]);
    disp(' ');
    disp('Data loading is completed!');
    disp(' ');
    disp(' ');
    disp('******************************************************');
    disp('1     uint8');
    disp('2     uint16');
    disp('3     uint32');
    disp('4     double');
    disp('******************************************************');
    disp(' ');

    datatype = input('Please choose a the datatype of your data (1~4): ');

    switch datatype
        case 1,
            src=fread(fid);
        case 2,
            src=fread(fid,'uint16');
        case 3,
            src=fread(fid,'uint32');
        case 4,
            src=fread(fid,'double');
    end

    disp(' ');
    rows = input('Please input the rows of the data: ');
    cols = input('Please input the columns of the data: ');
    slices = input('Please input the slices of the data: ');
    data=reshape(src, [rows cols slices]);
    disp(' ');
    disp('Data loading is completed!');
    disp(' ');
    
    Max = max(max(max(data)));
    Min = min(min(min(data)));
    Min2 = data(find(data>0,1));
    
    if Min2 == Max
        BinarySkeleton(data);
    else
        UnBinarySkeleton(data);
    end
    
end



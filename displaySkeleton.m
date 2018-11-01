clear all
clc

[FileName,PathName] = uigetfile('*.mat', 'Select skeleton file');
filepath = fullfile(PathName, FileName);

while isempty(filepath)
    [FileName,PathName] = uigetfile('*.mat', 'Select skeleton file');
    filepath = fullfile(PathName, FileName);
end

load(filepath);

figure
for i=1:size(X,1)
    h=plot3(Y(i,:), X(i,:), Z(i,:), 'b');
    set(h,'LineWidth',2);
    hold on
end

hold off
axis tight
axis equal
view(AZ,EL);
grid on

str=strcat('Skeleton_', Name);
str(strfind(str,'_'))='-';
title(str);

if Reverse==1
    set(gca, 'ZDir','reverse');
end

disp('Skeleton is displayed!');
disp(' ');
%function vsk

% VSK(mode)
% Runs the Volume Skeleton Toolbox.


clear all
close all
clc

cell_list = {};
fig_number = 1;

title_figure = 'Volume Skeleton Toolbox. (Vizlab, Rutgers University)';

cell_list{1,1} = {'Compute Volume Skeleton','main;'};
cell_list{2,1} = {'COVIS Data Processing','COVISplatform2;'};
cell_list{3,1} = {'View Volume Data','displayData;'};
cell_list{4,1} = {'View Volume Skeleton','displaySkeleton;'};
cell_list{5,1} = {'Exit',['disp(''Bye. To run again, type vsk.''); close(' num2str(fig_number) ');']};

show_window(cell_list,fig_number,title_figure,400,30,10,'clean',15);

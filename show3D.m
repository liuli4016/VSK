function show3D(X,Y,Z,data,th,fig_number,AZ,EL,a)

figure (fig_number)

p0 = patch(isosurface(X,Y,Z,data,th));
isonormals(X,Y,Z,data,p0);

if fig_number==1
    set(p0,'FaceColor','c','EdgeColor','none');
end

if fig_number==2
    set(p0,'FaceColor','c','EdgeColor','none');
end

if fig_number==3
    set(p0,'FaceColor','c','EdgeColor','none');
end

if fig_number==4
    set(p0,'FaceColor',[0,0.5,1],'EdgeColor','none');
end

if fig_number==5
    set(p0,'FaceColor','m','EdgeColor','none');
end

if fig_number>5
    set(p0,'FaceColor','c','EdgeColor','none');
end
 
view(AZ,EL); 
daspect;
daspect([1 1 1]);
axis tight
camlight; 
%lighting gouraud;
lighting phong
alpha(a);
% if a==1
    grid on
% else
%     box on
% end
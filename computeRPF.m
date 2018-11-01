function [rx, ry, rz]=computeRPF(obj_pos, boundary_pos, num_boundary, order) 

temp = boundary_pos - repmat(obj_pos, num_boundary(1), 1);
x=temp(:,1);
y=temp(:,2);
z=temp(:,3);
distance = sqrt(x.^2 + y.^2 + z.^2);
r_n=power(distance, order);

rx = sum(-x./r_n);
ry = sum(-y./r_n);
rz = sum(-z./r_n);




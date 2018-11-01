function DisMatrix = ComputeDisMatrix(data, boundary_pos, object_pos, num_boundary, num_object);

[rows, cols, slices]=size(data);
object_num=num_object(1);
boundary_num=num_boundary(1);
Dist=ComputeDist(boundary_pos, object_pos, object_num, boundary_num, rows, cols, slices);
DisMatrix=reshape(Dist,[rows cols slices]);




function T=connection(voxel, num_ridge, ridge_pos, rows, cols, slices)
      
ridge_num=num_ridge(1);
Dist=connect(voxel,ridge_pos,ridge_num,rows, cols, slices);
Dist(Dist==100000)=inf;
Dist=reshape(Dist,[ridge_num ridge_num]);
[T, cost] = MinimumSpanningTree2(Dist);

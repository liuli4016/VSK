function [object_pos, boundary_pos, object, boundary] = segmentation(voxel,rows, cols, slices);

object=voxel;
boundary=segment(voxel,rows, cols, slices);
boundary=reshape(boundary,[rows, cols, slices]);

b=reshape(boundary,prod(size(boundary)),1);
[indx1,indy1,indz1]=ind2sub(size(boundary),find(b==1));
object_pos=[indx1,indy1,indz1];

[indx2,indy2,indz2]=ind2sub(size(boundary),find(b==255));
boundary_pos=[indx2,indy2,indz2];

boundary(boundary==1)=0;

object(boundary==255)=0;




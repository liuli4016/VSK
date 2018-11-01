function [num_ridge, ridge, ridge_pos] = Findpoints_exposure(voxel, DisMatrix, rows, cols, slices)

Eth = input('Please set a threshold to exposure value of the selected skeleton points (generally 0.8~2) ([]=default: 1.2): ');

if isempty(Eth)
    Eth = 1.2;
end

Neighbor6=5*ones(3,3,3);
Neighbor18=5*ones(3,3,3);
Neighbor26=5*ones(3,3,3);
ridge=zeros(size(voxel));
Exposure=zeros(size(voxel));

for i=2:(rows-1)
    for j=2:(cols-1)
        for k=2:(slices-1)
            
            for a=-1:1
                for b=-1:1
                    for c=-1:1
                        
                        Neighbor6(a+2,b+2,c+2) = sqrt(DisMatrix(i,j,k)) + 1 - sqrt(DisMatrix(i+a,j+b,k+c));
                        Neighbor18(a+2,b+2,c+2) = sqrt(DisMatrix(i,j,k)) + sqrt(2) - sqrt(DisMatrix(i+a,j+b,k+c));
                        Neighbor26(a+2,b+2,c+2) = sqrt(DisMatrix(i,j,k)) + sqrt(3) - sqrt(DisMatrix(i+a,j+b,k+c));
                        
                        if a==0&&b==0&&c==0
                           Neighbor6(a+2,b+2,c+2)=500;
                           Neighbor18(a+2,b+2,c+2)=500;
                           Neighbor26(a+2,b+2,c+2)=500;
                        end
                        
                        if abs(a)==1&&abs(b)==1
                           Neighbor6(a+2,b+2,c+2)=500;
                        end
                        
                        if abs(a)==1&&abs(c)==1
                           Neighbor6(a+2,b+2,c+2)=500;
                        end
                        
                        if abs(b)==1&&abs(c)==1
                           Neighbor6(a+2,b+2,c+2)=500;
                        end
                        
                        if abs(a)==1&&abs(b)==1&&abs(c)==1
                           Neighbor18(a+2,b+2,c+2)=500;
                        end
                           
                    end
                end
            end
            
            E26=min(min(min(Neighbor26)));
            E18=min(min(min(Neighbor18)));
            E6=min(min(min(Neighbor6)));     
            E=min(E6,min(E18,E26));
           
            Exposure(i,j,k)=E;
            
            if E>Eth 
                ridge(i,j,k)=255;
            end
 
            
        end
    end
end


d=reshape(ridge,prod(size(ridge)),1);
[indx3,indy3,indz3]=ind2sub(size(ridge),find(d==255));
ridge_pos=[indx3,indy3,indz3];
num_ridge=size(ridge_pos);

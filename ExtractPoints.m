function [CoorX, CoorY, CoorZ]=ExtractPoints(x1,y1,z1,x2,y2,z2,up)

deltaX = abs(x1 - x2);
deltaY = abs(y1 - y2);
deltaZ = abs(z1 - z2);

delta=[deltaX, deltaY, deltaZ];
del=max(delta);
    
sumup = sqrt((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2);
vector=[(x2-x1)/sumup, (y2-y1)/sumup, (z2-z1)/sumup];
vec=max(vector);

CoorX(1)=x1;
CoorY(1)=y1;
CoorZ(1)=z1;

step=1;
while del>=vec
    x1=x1+vector(1);
    y1=y1+vector(2);
    z1=z1+vector(3);
                    
    if step>=up-2
        break;
    end
 
    step=step+1;
    CoorX(step)=x1;
    CoorY(step)=y1;
    CoorZ(step)=z1;  
    
    deltaX = abs(x1 - x2);
    deltaY = abs(y1 - y2);
    deltaZ = abs(z1 - z2);

    delta=[deltaX, deltaY, deltaZ];
    del=max(delta);
    
end

CoorX(step+1)=x2;
CoorY(step+1)=y2;
CoorZ(step+1)=z2;
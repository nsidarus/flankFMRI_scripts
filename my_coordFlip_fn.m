function [outMatrix] = my_coordFlip_fn(inMatrix,dirFlips,wrect,type)
% dirFlips is vector with 1 for flip, 0 for same
% 1st on horizontal and 2nd on vertical plane
% type: 'lines', 'poly', 'rect'

% % % NS, 22/09/2015
% % % added capacity to deal with multiple stim types

dirFlipsn = dirFlips;
dirFlipsn(dirFlipsn==0)=-1;
outMatrix = zeros(1,4);

if exist('type','var') 
    switch type
        case 'lines' % if drawing lines, 1st row in horizontal, and 2nd vertical
            outMatrix = [-dirFlipsn(1)*inMatrix(1,:)+wrect(3)*dirFlips(1); -dirFlipsn(2)*inMatrix(2,:)+wrect(4)*dirFlips(2)];
    
        case 'poly' % if using FillPoly function, this works
            outMatrix = [-dirFlipsn(1)*inMatrix(:,1)+wrect(3)*dirFlips(1) -dirFlipsn(2)*inMatrix(:,2)+wrect(4)*dirFlips(2)];    
            
        case 'rect' % if rectangle, with [left, top, rigth, bottom] - will have to flip coords!!
            if dirFlips(1) == 0
                outMatrix(1) = inMatrix(1); % left   - hor
                outMatrix(3) = inMatrix(3); % right  - hor
            else
                outMatrix(1) = -dirFlipsn(1)*inMatrix(3)+wrect(3)*dirFlips(1); % left   - hor
                outMatrix(3) = -dirFlipsn(1)*inMatrix(1)+wrect(3)*dirFlips(1); % right  - hor
            end
            
             if dirFlips(2) == 0
                outMatrix(2) = inMatrix(2); % top    - vert
                outMatrix(4) = inMatrix(4); % bottom - vert
            else
                outMatrix(2) = -dirFlipsn(2)*inMatrix(4)+wrect(4)*dirFlips(2); % top    - vert
                outMatrix(4) = -dirFlipsn(2)*inMatrix(2)+wrect(4)*dirFlips(2); % bottom - vert
            end               
    end
end
end

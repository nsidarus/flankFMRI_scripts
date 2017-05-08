
% windowSize = [50 50 1600 1000];


param.screenWidth       = 44; % in cm
param.viewDistance      = 50; % in cm

param.colour.black   = [0    0    0];     % black
param.colour.white   = [255  255  255];   % white

% param.colour.bkgd   = round(param.colour.white/2);
param.colour.bkgd   = param.colour.black;

                        
param.colour.effects = [180  120  90;...    % purple                           
                50   240  160;...   % light green
                0    115  200;...   % blue
                245  95   255;...   % lilac
                170  136  0;...     % green/brown
                150  150  150 ];    % grey

   
   
   
%     param.colour.effects = [255  212  42;...    % yellow
%                             0    185  255;...   % light blue
%                             130  40   255;...   % purple   
%                             0    220  0;...     % green
%                             255  40   170;...   % pink
%                             255  0     10;...   % red
%                             0    90    255;...  % dark blue
%                             255  120  0 ];      % orange       
   
%    param.colour.effects = [255  212  42;...    % yellow
%                 130  60   255;...   % purple           
%                 0    185  255;...   % light blue
%                 0    220  0;...     % green
%                 255  40   170;...   % pink
%                 255  0     10;...   % red
%                 0    70    255;...  % dark blue
%                 255  120  0 ];      % orange   
%  
            
            
%                             130  40   255;...   % purple           

%                 0    90    255;...  % dark blue

            
%             
%     param.colour.effects = [180  120  90;...    % purple
%                             255  70   40;...    % redish
%                             128  128  128;...   % grey                             
%                             50   240  160;...   % light green
%                             0    115  200;...   % blue
%                             245  95   255;...   % lilac
%                             170  136  0;...     % green/brown
%                             255  255  255 ];    % white
%                         
                        
% %                             225  245  20;...    % yellow/green
%   
% 
% param.colour.effects = [255  212  42;...    % yellow
%                         0    180  255;...   % light blue
%                         180  120  90;...    % brown
%                         255  40   170;...   % pink
%                         0    220  0;...     % green
%                         240  0    5;...     % red
%                         30   20   255;...   % dark blue
%                         255  120  0 ];      % orange

%%
                   
Screen('Preference', 'SkipSyncTests', 1)
screenNumber=max(Screen('Screens'));
[param.win, param.wrect] = PsychImaging('OpenWindow', screenNumber, param.colour.bkgd);
 
% [param.win, param.wrect] = Screen('OpenWindow', 0, param.colour.bkgd, windowSize); % 0 is ID of main screen, % colour % full window mode, as no other size was specified    

[nPixels, nPixelsUnrounded] = degrees2pixels(1, param.viewDistance, param.wrect(3)/param.screenWidth);
pixelPerDegree          = nPixelsUnrounded;

circWDeg = 4.8; % in visual degrees
param.stim.circleDiam=pixelPerDegree*circWDeg;
stim.circleBox = CenterRect([0 0 param.stim.circleDiam param.stim.circleDiam], param.wrect);

% for i=2
for i=1:size(param.colour.effects, 1)  
    param.stim.circleBox = stim.circleBox;
    Screen('FillOval', param.win, param.colour.effects(i, :), param.stim.circleBox, param.stim.circleDiam);

    Screen('DrawingFinished',param.win);
    Screen('Flip', param.win);
    
    
    WaitSecs(1);
end
% end



Screen('CloseAll')




%%
%
%     
% param.stim.circleBox = stim.circleBox;
% Screen('FillOval', param.win, param.colour.effects(1, :), param.stim.circleBox, param.stim.circleDiam);
% 
% param.stim.circleBox = stim.circleBox +70;
% Screen('FillOval', param.win, param.colour.effects(2, :), param.stim.circleBox, param.stim.circleDiam);
% 
% param.stim.circleBox = stim.circleBox +150;
% Screen('FillOval', param.win, param.colour.effects(3, :), param.stim.circleBox, param.stim.circleDiam);
% 
% param.stim.circleBox = stim.circleBox -70;
% Screen('FillOval', param.win, param.colour.effects(4,:), param.stim.circleBox, param.stim.circleDiam);
% 
% param.stim.circleBox = stim.circleBox -150;
% Screen('FillOval', param.win, param.colour.effects(5,:), param.stim.circleBox, param.stim.circleDiam);
% 
% param.stim.circleBox = stim.circleBox -220;
% Screen('FillOval', param.win, param.colour.effects(6,:), param.stim.circleBox, param.stim.circleDiam);
% 



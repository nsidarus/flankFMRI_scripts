function STOP = checkKeys(STOP, kbDevice)
% Check ongoing KbQueue, for a STOP

if ~exist('kbDevice','var')
    kbDevice = [];
end
if ~exist('STOP','var')
    STOP = 0;
end

if ~STOP    
    % check whether to pause or stop
    [pressed, firstPressed]= KbQueueCheck(kbDevice);
    if pressed
        if firstPressed(KbName('p')) % PAUSE SCRIPT Until space bar is pressed
           STOP = pauseFun(STOP, kbDevice);
        elseif firstPressed(KbName('Escape'))
            STOP = 1;
        end
    end
end

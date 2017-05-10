
function STOP = pauseFun(STOP, kbDevice)
% pause presentation, until return/enter or space keys are pressed

if ~exist('STOP', 'var')
    STOP = 0;
end
if ~exist('kbDevice', 'var')
    kbDevice = [];
end


fprintf('Pause Mode: Waiting for Space or Enter key press to continue.\n')

KbQueueStart(kbDevice);
KbQueueFlush(kbDevice);
while true
    [pressed, firstPressed]= KbQueueCheck(kbDevice);
    if pressed
        if firstPressed(KbName('Return'))        
            break
        elseif firstPressed(KbName('Enter'))
            break
        elseif firstPressed(KbName('Space'))
            break
        elseif firstPressed(KbName('Escape'))
            STOP = 1;
            break
        end
    end
    WaitSecs(0.01);
end
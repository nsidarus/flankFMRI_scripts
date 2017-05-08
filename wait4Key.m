       
function [STOP, key, tkey, dt] = wait4Key(inkey, STOP, kbDevice, timeOut, waitRelease)
%%% Wait for a key to be pressed (relaxed)

% inkey: key(s) to wait for
% timeOut: maximum wait time
% waitRelease: whether to wait for a key release
% Pressing "p" introduces a pause, until the "Enter" or the "Space" bar is pressed
% If pressed "Escape", the programme stops

% Note: Restarts KbQueues
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
if nargin < 5  || isempty(waitRelease)
    waitRelease = false;
end      
if nargin < 4 || isempty(timeOut)
    timeOut = inf;
end
if nargin < 3
    kbDevice = [];
end
if nargin < 2
   STOP = 0;
end
if nargin < 1 || isempty(inkey)
    inkey = 1:256;
end

key  = 0;
tkey = inf;
dt   = [];

% check first ongoing KbQueue for a STOP
STOP = checkKeys(STOP, kbDevice);

if ~STOP

    t0 = GetSecs;

    % Restart KbQueues  
    KbQueueStart(kbDevice);
    KbQueueFlush(kbDevice);
    while true
        [pressed, firstPressed] = KbQueueCheck(kbDevice);
        if GetSecs-t0 > timeOut
            break
        end
        if pressed
            if firstPressed(KbName('p')) % PAUSE SCRIPT Until space bar is pressed
                STOP = pauseFun(STOP, kbDevice);
                break
            elseif firstPressed(KbName('Escape'))
                STOP = 1;
                break
            elseif any(firstPressed(inkey))
                key  = find(firstPressed);
                tkey = firstPressed(find(firstPressed));                
                while waitRelease
                    [pressed, firstPressed, firstRelease] = KbQueueCheck(kbDevice);
                    if all(firstRelease(key) == 0) % check key release
                        dt = GetSecs-tkey;
                        break
                    end
                end
                break
            end     
        end
        WaitSecs(0.01);
    end
end

function flankFMRI_blockfun(b, getRatings)
% Run a Block of trials
% for the fMRI Flanker task

% input: block n.
% no output, just runs a block of trials

% NS, Nov 2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global param keys colno data
    

%% Loop Trials
    
if ~keys.STOP
    
trialIndex = 1:size(data.block{b},1); % no need to randomise, but might need to repeat trials 
% errorCount = 0;

t=0;
while true % repeated until no more trials are needed
    t=t+1;
    
    firstPressed = [];

    rt2 = 0;
    
    % read from block array id of stimuli to find what buffer to call
    thisNoise       = data.block{b}(trialIndex(t), colno.noise);
    thisFlanker     = data.block{b}(trialIndex(t), colno.flank);
    thisTarget      = data.block{b}(trialIndex(t), colno.target);
    thisAOI         = data.block{b}(trialIndex(t), colno.aoi);
    thisTrialType   = data.block{b}(trialIndex(t), colno.trialType);
    thisEffect      = data.block{b}(trialIndex(t), colno.effect);    

    
    % thisTrialType:
    % No Noise:
    % 1 - Compatible-Left,   2 - Compatible-Right,
    % 3 - Incompatible-Left, 4 - Incompatible-Right
    % Noise:
    % 5 - Compatible-Left,   6 - Compatible-Right,

        
%% % % % % Start Trial
    
    fprintf('\nBlock %d, Trial %d \n', b, t);

    % Jittered fixation Duration/ITI
    fixDur = param.fixationDur(1) + (param.fixationDur(2)-param.fixationDur(1))*rand(1);

% % Fixation Point
    Screen('FillRect', param.win, [param.colour.stim 1], param.stim.fixRect);
    start_vbl = Screen('Flip', param.win);
    data.allTimes(end+1,:) = {start_vbl, sprintf('trial%d_startFixation', t)};

% % % Draw Stim
    Screen('DrawTexture', param.win, param.stim.( param.figStimRefs{thisNoise}{thisTarget, thisFlanker} ), [], param.stim.figRect);                        
    Screen('DrawingFinished', param.win);
    stimOn_vbl = Screen('Flip', param.win, start_vbl + fixDur - param.slack);    
    targetONbackupTime = GetSecs;
    data.allTimes(end+1,:) = {stimOn_vbl, 'targetOn'};
    data.allTimes(end+1,:) = {targetONbackupTime, 'targetOn_BackUp'};
    
%% % % % Start Recording Key presses
    KbQueueStart(keys.kbDevice); % VERY IMPORTANT TO START QUEUE AND THEN FLUSH!!!
    KbQueueFlush(keys.kbDevice);
                
    correct  = 0;
    actKey   = 0;
    
    waitResp = 1;
    getResp  = 1;
    vbl = GetSecs; % to have vbl for response loop
    
    % Loop during response window
    while waitResp && vbl < stimOn_vbl + param.responseWindow - param.slack
       
        if vbl < stimOn_vbl + param.stimDur - param.rft - param.slack % if within duration of target, draw it
                
            Screen('DrawTexture', param.win, param.stim.( param.figStimRefs{thisNoise}{thisTarget, thisFlanker} ), [], param.stim.figRect);                        
            stimPres = 'targetOn';
        else
            stimPres = 'targetOff';
        end
        Screen('DrawingFinished', param.win);

                
        % between screen flips, loop to check responses
        while getResp && GetSecs < vbl+param.rft-param.slack

            [pressed, firstPressed]= KbQueueCheck(keys.kbDevice);
            if pressed                                    
                getResp=0; % stop inner loop
                waitResp=0; % stop outer loop

                data.allTimes(end+1,:) = {GetSecs, 'response'};
                
                   % here stim only on for 50ms, so too fast
%                 Screen('Flip', param.win); % Clear the screen in case target is still up
            end
            WaitSecs(0.001);        
        end

        % after checking for response
        vbl = Screen('Flip', param.win, vbl+param.rft-param.slack);       
        data.allTimes(end+1,:) = {vbl, stimPres};
    end % while waitResp && vbl ...
    

    %% % Handle responses
    resp = find(firstPressed~=0); % get key id

    if length(resp)==1 && ... % only 1 key was pressed
         ismember(resp, keys.action) % is one of the action response keys

        actKey = resp; % just for record, but can only handle 1 key
        
        if resp == keys.action(1) % then left key
            thisAction = 1;
        elseif resp == keys.action(2) % right
            thisAction = 2;
        end
        
        respTime = firstPressed(keys.action(thisAction));
        data.allTimes(end+1,:) = {respTime, sprintf('respTime_key%d', actKey)};
        
        rt       = (respTime - stimOn_vbl)*1000;       
        rt2      = (respTime - targetONbackupTime)*1000;
        
        if thisAction == thisTarget % if correct response
            correct=1;
        end          
        
    elseif ismember(keys.pause, resp) % PAUSE SCRIPT Until Enter is pressed
        pauseFun
        
    elseif ismember(keys.escape, resp)                
        keys.STOP = 1;
        return

    elseif ~isempty(resp)% if other keys are pressed
        thisAction  = 5;
        respTime    = firstPressed(resp(1)); % only consider first keys as > 1 is possible
        rt      	= (respTime - stimOn_vbl)*1000;                    
    end % if length(resp)==1 && ...
                
      
%% % % % % If Correct
    
    % Wait regardless of correct vs error, to balance timings
    wait4Scale = param.effect2scaleInt(1) + (param.effect2scaleInt(2)-param.effect2scaleInt(1))*rand(1);     

    if correct
        fprintf('Correct response.\n');
        
        %% Present Effect
        Screen('FillOval', param.win, param.colour.effects(thisEffect, :), param.stim.circleBox, param.stim.circleDiam);
        Screen('DrawingFinished', param.win);
        effectOn_vbl = Screen('Flip', param.win, respTime + param.aoiDur(thisAOI) - param.slack);
        data.allTimes(end+1,:) = {effectOn_vbl, 'effectOn'};
        
        % clear screen after effect, with fixation        
        Screen('FillRect', param.win, [param.colour.stim 1], param.stim.fixRect);
        effectOff_vbl = Screen('Flip', param.win, effectOn_vbl + param.effectDur - param.slack);
        data.allTimes(end+1,:) = {effectOff_vbl, 'fixation'};
        
        if getRatings

    % % % % % Present Rating Scale - with deadline!
            [rating, ratingKey, ratingRT, ratingTime, scaleOn_vbl, scaleOff_vbl] = flankFMRI_ratingscalefun(effectOff_vbl, wait4Scale);
            
            if rating == 0
                correct = 0; % no rating, so not correct trial
            end
        else            
            rating      = 0;
            ratingRT    = 0;
            ratingTime  = 0;                        
            scaleOn_vbl = 0;
            scaleOff_vbl= 0;
        end % if getRatings

        
    else % if error
%         errorCount = errorCount + 1;
                
        t_now = GetSecs;        

        fprintf('Response error.\n');
        
        Screen('DrawLines', param.win, param.stim.errorCross, 5, param.colour.stim);
        Screen('DrawingFinished', param.win);
        effectOn_vbl = Screen('Flip', param.win, t_now + param.rft - param.slack);
        data.allTimes(end+1,:) = {effectOn_vbl, 'errorCrossOn'};
        
        % wait for typical duration of effect and revert to fixation
        Screen('FillRect', param.win, [param.colour.stim 1], param.stim.fixRect);
        effectOff_vbl = Screen('Flip', param.win, effectOn_vbl + param.effectDur - param.slack);
        data.allTimes(end+1,:) = {effectOff_vbl, 'fixation'};
            
        % wait extra jittered interval
        WaitSecs(wait4Scale);
        
        if ~exist('rt', 'var')
            rt = 0;
        end       
        if ~exist('thisAction', 'var')
            thisAction = 0;
        end              
        if ~exist('respTime', 'var') % For PTB diagnostics matrix
            respTime = 0;
        end    
        
        rating      = 0;
        ratingKey   = 0;
        ratingRT    = 0;        
        ratingTime  = 0;                        
        scaleOn_vbl = 0;
        scaleOff_vbl= 0;
        

        % No error replacement
%         if errorCount <= param.maxErrorN
%             % To replace an error trial at the end of the block, add current index to list of trial indexes
%             trialIndex = [trialIndex, trialIndex(i)];       
%         end
    end % if correct

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    



%% % % % Record all trial info and responses

    data.raw{b}(end+1, :) = [...
        data.subj,...% col 1
        data.block{b}(trialIndex(t),colno.cond:colno.effect),... % cond, noise, flank, target, cong, aei, trialtype, effect
        thisAction,...          % col 10
        actKey,...              % col 11
        rt,...                  % col 12
        rt2,...
        rating,...              % col 13
        ratingKey,...           % col 14
        ratingRT,...            % col 15
        correct];               % col 16
    
%     data.rawHdr = {'subj', 'cond', 'noise', 'flank', 'target', 'cong', 'aei', 'trialtype', 'effect',...
%         'thisAction', 'actKey', 'rt', 'rating', 'ratingKey', 'ratingRT', 'correct'};
    
        
    % % Timing record    
    realAOI = effectOn_vbl - respTime;
    data.trialTimes{b}(end+1, :) = [...
        start_vbl,...               % 1
        fixDur,...                  % 2
        stimOn_vbl,...              % 3
        respTime,...                % 4
        effectOn_vbl,...            % 5        
        effectOff_vbl,...           % 6
        realAOI,...                 % 7
        wait4Scale,...              % 8
        scaleOn_vbl,...             % 9
        scaleOff_vbl,...            % 10
        ratingTime,...              % 11
        ratingRT];                  % 12

%     data.timesHdr = {'start', 'fixDur', 'stimOn', 'respTime', 'effectOn', 'effectOff',...
%         'realAOI', 'wait4Scale', 'scaleOn_vbl', 'scaleOff_vbl', 'ratingTime', 'ratingRT'};
    

    %% end of trial

    if ~keys.STOP
        
        % Read any ongoing cue for whether to pause or stop
        [pressed, firstPressed]= KbQueueCheck(keys.kbDevice);
        if pressed
            if ismember(keys.pause, find(firstPressed~=0)) % PAUSE SCRIPT Until space bar is pressed
                pauseFun
            elseif ismember(keys.escape, find(firstPressed~=0))
                keys.STOP = 1;
                return
            end
        end        
        
        % otherwise, continue - ITI set at trial start
        if  t >= length(trialIndex) % if last trial, end block
            break                  
        end
                    
    elseif keys.STOP
        return
    end % if ~keys.STOP
    
    clear thisNoise  thisFlank thisTarget thisCong  thisAOI  thisTrialType thisEffect
end % while true % repeated until no more trials are needed

else % if ~keys.STOP
    fprintf('\n\n  ------------Experiment stopped by user!!------------\n')        
end % if ~keys.STOP

end

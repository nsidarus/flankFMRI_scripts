function flankFMRI_blockfun(b, getRatings)
% Run a Block of trials
% for the fMRI Flanker task

% input: block n.
% no output, just runs a block of trials

% NS, May 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global param keys colno data
    

%% Loop Trials
    
if ~keys.STOP
    
trialIndex = 1:size(data.block{b},1); % no need to randomise, but might need to repeat trials 

t=0;
while true % repeated until no more trials are needed
    t=t+1;
    
    firstPressed = [];
    actKey  = NaN;
    rt      = NaN;
    rt2     = NaN;
    
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
    
    fprintf('\nBlock %d, Trial %d, Condition %d \n', b, t, data.block{b}(trialIndex(t), colno.cond));
%     fprintf('Condition %d \n',data.block{b}(trialIndex(t), colno.cond));
    
    % Jittered fixation Duration/ITI
    fixDur = param.fixationDur(1) + (param.fixationDur(2)-param.fixationDur(1))*rand(1);

% % Fixation Point
    Screen('FillRect', param.win, [param.colour.stim 1], param.stim.fixRect);
    start_vbl = Screen('Flip', param.win);
    data.allTimes(end+1,:) = {start_vbl, sprintf('startFixation_trial%d', t)};

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
    resp = find(firstPressed); % get key id

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
            rating      = NaN;
            ratingRT    = NaN;
            ratingTime  = NaN;                        
            scaleOn_vbl = NaN;
            scaleOff_vbl= NaN;
        end % if getRatings

        
    else % if error
                
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
        
        if ~exist('thisAction', 'var')
            thisAction  = NaN;
            rt          = NaN;
            rt2         = NaN;
            respTime    = NaN;
        end              
        
        rating      = NaN;
        ratingKey   = NaN;
        ratingRT    = NaN;        
        ratingTime  = NaN;                        
        scaleOn_vbl = NaN;
        scaleOff_vbl= NaN;
        
    end % if correct

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    



%% % % % Record all trial info and responses

    data.raw{b}(end+1, :) = [...
        data.subj,...           % col 1
        b,...                   % col 2
        t,...                   % col 3
        data.block{b}(trialIndex(t),colno.cond:colno.effect),... % cond, noise, flank, target, cong, aei, trialtype, effect
        thisAction,...          % col 13
        actKey,...              % col 14
        rt,...                  % col 15
        rt2,...
        rating,...              % col 16
        ratingKey,...           % col 17
        ratingRT,...            % col 18
        correct];               % col 19
    
    % data.rawHdr     = {'subj', 'blockN', 'trialN', 'cond', 'noise', 'flank', 'target', 'cong', 'aei', 'trialtype', 'effect',...
    %                     'thisAction', 'actKey', 'rt', 'rt2', 'rating', 'ratingKey', 'ratingRT', 'correct'};
    
        
    % % Timing record    
    realAOI = effectOn_vbl - respTime;
    
    data.trialTimes{b}(end+1, :) = [...
        data.subj,...               % 1
        b,...                       % 2
        t,...                       % 3
        data.triggerTimes(b),...    % 4
        start_vbl,...               % 5
        fixDur,...                  % 6
        stimOn_vbl,...              % 7
        respTime,...                % 8
        effectOn_vbl,...            % 9        
        effectOff_vbl,...           % 10
        realAOI,...                 % 11
        wait4Scale,...              % 12
        scaleOn_vbl,...             % 13
        scaleOff_vbl,...            % 14
        ratingTime,...              % 15
        ratingRT];                  % 16

    % data.timesHdr = {'subj', 'blockN', 'trialN', 'T0', 'start', 'fixDur', 'stimOn', 'respTime', 'effectOn', 'effectOff',...
    %     'realAOI', 'wait4Scale', 'scaleOn_vbl', 'scaleOff_vbl', 'ratingTime', 'ratingRT'};
    

    %% end of trial

    if ~keys.STOP
        
        % Read any ongoing cue for whether to pause or stop
        keys.STOP = checkKeys(keys.STOP, keys.kbDevice);  
        
        if ~keys.STOP % otherwise, continue - ITI set at trial start
            if  t >= length(trialIndex) % if last trial, end block
                break                  
            end
            
        elseif keys.STOP
            return
        end % if ~keys.STOP

    elseif keys.STOP
        return
    end % if ~keys.STOP
    
    clear thisAction thisNoise thisFlank thisTarget thisCong  thisAOI  thisTrialType thisEffect
end % while true % repeated until no more trials are needed

else % if ~keys.STOP
    fprintf('\n\n  ------------Experiment stopped by user!!------------\n')        
end % if ~keys.STOP

end

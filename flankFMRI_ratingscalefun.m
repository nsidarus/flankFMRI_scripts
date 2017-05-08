function [rating, ratingKey, ratingRT, ratingTime, scaleOn_vbl, scaleOff_vbl] = flankFMRI_ratingscalefun(effectOff_vbl, wait4Scale)
% Presents Rating Scale and collects ratings

% NS, May 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global param data keys

if ~exist('effectOff_vbl','var')
    effectOff_vbl = 0;    
end
if ~exist('wait4Scale','var')
    wait4Scale = 0;
end

noRatOn_vbl = 0;
noRatOff_vbl = 0;

%% Scale
message1 = 'Votre sentiment de contrôle ?';
message2 = 'Pas de contrôle                                          Contrôle total';
message3 = '     1      2      3      4      5      6      7      8    ';
Screen('TextSize', param.win, round(param.textSize*1.17));
Screen('TextStyle', param.win, 1);
DrawFormattedText(param.win, message1, 'center', param.xy0(2)-100, param.colour.stim, [],[],[], 1.5); % 1.5 - vertical spacing
Screen('TextSize', param.win, round(param.textSize*.76));
Screen('TextStyle', param.win, 2);
DrawFormattedText(param.win, message2, 'center', param.xy0(2)-6, param.colour.stim);
Screen('TextSize', param.win, param.textSize);
Screen('TextStyle', param.win, 1);
DrawFormattedText(param.win, message3, 'center', param.xy0(2)+40, param.colour.stim);
Screen('DrawingFinished', param.win);

scaleOn_vbl = Screen('Flip', param.win, effectOff_vbl + wait4Scale - param.slack); % draw scale after random interval          
data.allTimes(end+1,:) = {scaleOn_vbl, 'ratingScaleOn'};
fprintf('Rating scale window. \n')
            
[keys.STOP, ratingKey, ratingTime] = wait4Key(keys.rating, keys.STOP, keys.kbDevice, param.ratingWindow);

if ~keys.STOP &&...
        length(ratingKey)==1 && ratingKey > 0
    
    rating = find(ismember(keys.rating, ratingKey)); % convert to likert scale
    ratingRT = (ratingTime - scaleOn_vbl) * 1000;
    data.allTimes(end+1,:) = {ratingTime, sprintf('ratingTime_key%d',ratingKey)};
else
    ratingKey= 0;
    rating   = 0;
    ratingRT = 0;
end


% wait rest of rating window ?
if rating ~= 0
    fprintf('Valid rating.\n');
    
    % Clear screen to fixation
    Screen('FillRect', param.win, [param.colour.stim 1], param.stim.fixRect);
    scaleOff_vbl = Screen('Flip', param.win); % blank the screen 
    data.allTimes(end+1,:) = {scaleOff_vbl, 'fixation'};
    
    if param.waitRatWin
        fprintf('Waiting for rest of rating scale window. \n')
        while GetSecs < scaleOn_vbl + param.ratingWindow - param.slack
            Screen('FillRect', param.win, [param.colour.stim 1], param.stim.fixRect);
            Screen('Flip', param.win); % blank the screen 
        end
    end
    
else % no rating
    if param.noRatFeedback
        fprintf('No rating error.\n');
        
        message1 = 'Attention!';
        message2 = 'Vous n''avez pas répondu !';
        Screen('TextSize', param.win, param.textSize);
        Screen('TextStyle', param.win, 1);
        DrawFormattedText(param.win, message1, 'center', param.xy0(2)-30, param.colour.stim);
        Screen('TextSize', param.win, round(param.textSize*.8));
        Screen('TextStyle', param.win, 1);
        DrawFormattedText(param.win, message2, 'center', param.xy0(2)+30, param.colour.stim);

        noRatOn_vbl = Screen('Flip', param.win); % draw scale after random interval        
        scaleOff_vbl = noRatOn_vbl; % for trial-wise time record
        data.allTimes(end+1,:) = {noRatOn_vbl, 'noRatingFeedback'};
        
        
        % Clear screen to fixation
        Screen('FillRect', param.win, [param.colour.stim 1], param.stim.fixRect);
        noRatOff_vbl = Screen('Flip', param.win, noRatOn_vbl + param.noRatFeedbackDur - param.slack); % draw scale after random interval
        data.allTimes(end+1,:) = {noRatOff_vbl, 'fixation'};
        
    else
        % Clear screen to fixation
        Screen('FillRect', param.win, [param.colour.stim 1], param.stim.fixRect);
        scaleOff_vbl = Screen('Flip', param.win); % blank the screen 
        data.allTimes(end+1,:) = {scaleOff_vbl, 'fixation'};
    end    
end

    
    
    
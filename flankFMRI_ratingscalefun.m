function [STOP, rating, ratingKey, ratingRT, ratingTime, scaleOn_vbl, scaleOff_vbl, noRatOn_vbl, noRatOff_vbl] = flankFMRI_ratingscalefun(param, respKeys, STOP, kbDevice, effectOff_vbl, wait4Scale)
% Presents Rating Scale and collects ratings

% NS, May 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('STOP','var')
    STOP = 0;
end
if ~exist('kbDevice','var')
    kbDevice = [];
end
if ~exist('effectOff_vbl','var')
    effectOff_vbl = 0;    
end
if ~exist('wait4Scale','var')
    wait4Scale = 0;
end



waitRatWin = 0;
noRatFeedback = 1;
noRatFeedbackDur = 1; % s
noRatOn_vbl = 0;
noRatOff_vbl = 0;

%% Scale
message1 = 'Votre sentiment de contrôle ?';
message2 = 'Pas de contrôle                                    Contrôle total';
message3 = '     1      2      3      4      5      6      7      8    ';
Screen('TextSize', param.win, 40);
Screen('TextStyle', param.win, 1);
DrawFormattedText(param.win, message1, 'center', param.xy0(2)-100, param.colour.stim, [],[],[], 1.5); % 1.5 - vertical spacing
Screen('TextSize', param.win, 26);
Screen('TextStyle', param.win, 2);
DrawFormattedText(param.win, message2, 'center', param.xy0(2)-6, param.colour.stim);
Screen('TextSize', param.win, 34);
Screen('TextStyle', param.win, 1);
DrawFormattedText(param.win, message3, 'center', param.xy0(2)+40, param.colour.stim);
Screen('DrawingFinished', param.win);

scaleOn_vbl = Screen('Flip', param.win, effectOff_vbl + wait4Scale - param.slack); % draw scale after random interval
            
[STOP, ratingKey, ratingTime] = wait4Key(respKeys, STOP, kbDevice, param.ratingWindow);

if ~STOP && ratingKey > 0
    
    rating = find(ismember(respKeys, ratingKey)); % convert to likert scale
    ratingRT = (ratingTime - scaleOn_vbl) * 1000;
else
    rating = 0;
    ratingRT = 0;
end


% wait rest of rating window ?
if rating ~= 0
    
    % Clear screen to fixation
    Screen('FillRect', param.win, [param.colour.stim 1], param.stim.fixRect);
    scaleOff_vbl = Screen('Flip', param.win); % blank the screen 
    
    if waitRatWin
        while GetSecs < scaleOn_vbl + param.ratingWindow - param.slack
            Screen('FillRect', param.win, [param.colour.stim 1], param.stim.fixRect);
            Screen('Flip', param.win); % blank the screen 
        end
    end
    
else % no rating
    if noRatFeedback
        message1 = 'Attention!';
        message2 = 'Vous n''avez pas repondu !';
        Screen('TextSize', param.win, 30);
        Screen('TextStyle', param.win, 1);
        DrawFormattedText(param.win, message1, 'center', param.xy0(2)-30, param.colour.stim, [],[],[], 1.5); % 1.5 - vertical spacing
        Screen('TextSize', param.win, 26);
        Screen('TextStyle', param.win, 1);
        DrawFormattedText(param.win, message2, 'center', param.xy0(2)+30, param.colour.stim, [],[],[], 1.5); % 1.5 - vertical spacing

        noRatOn_vbl = Screen('Flip', param.win); % draw scale after random interval
        scaleOff_vbl = noRatOn_vbl;
        
        % Clear screen to fixation
        Screen('FillRect', param.win, [param.colour.stim 1], param.stim.fixRect);
        noRatOff_vbl = Screen('Flip', param.win, noRatOn_vbl + noRatFeedbackDur - param.slack); % draw scale after random interval
        
    else
        % Clear screen to fixation
        Screen('FillRect', param.win, [param.colour.stim 1], param.stim.fixRect);
        scaleOff_vbl = Screen('Flip', param.win); % blank the screen 
    end    
end

    
    
    
    
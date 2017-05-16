function testKeys

global param keys


% add extra "r" key, to repeat instructions
keysofinterest = [KbName('r'), keys.EXPtrigger, keys.action, keys.rating, keys.enter, keys.pause, keys.escape]; % only keys that will be read and recorded by KbQueueCheck

keyList                 = zeros(1,256);
keyList(keysofinterest) = 1;
KbQueueCreate(keys.kbDevice, keyList);




% Show message to signal start of run
message1 = 'Avant de commencer, nous allons vérifier\nsi toutes les touches fonctionne correctement.';
Screen('TextSize', param.win, param.textSize);
DrawFormattedText(param.win, message1, 'center', 'center', param.colour.text, 60,[],[], 1.5);
Screen('Flip', param.win);                                        

        
fprintf('\nWaiting for experimenter to press "s" to start. \n');

[keys.STOP] = wait4Key(keys.EXPtrigger, keys.STOP, keys.kbDevice);


if ~keys.STOP
    % Show message to signal start of run
    message1 = 'Veuillez appuyer, séquentiellement,\nsur les touches de 1 à 8.';
    message3 = '     1      2      3      4      5      6      7      8    ';
    Screen('TextSize', param.win, round(param.textSize*1.17));
    Screen('TextStyle', param.win, 1);
    DrawFormattedText(param.win, message1, 'center', param.xy0(2)-100, param.colour.stim, [],[],[], 1.5); % 1.5 - vertical spacing
    Screen('TextSize', param.win, param.textSize);
    Screen('TextStyle', param.win, 1);
    DrawFormattedText(param.win, message3, 'center', param.xy0(2)+40, param.colour.stim);
    Screen('DrawingFinished', param.win);

    Screen('Flip', param.win);                                        


    fprintf('Waiting to check key presses. Press "s" to stop and start experiment, or "r" to instruct a repeat.\n\n');


    while true
        % Check the queue for key presses.
        [ pressed, firstPress]=KbQueueCheck(keys.kbDevice);

        % If the user has pressed a key, then display its code number and name.
        if pressed

            % Note that we use find(firstPress) because firstPress is an array with
            % zero values for unpressed keys and non-zero values for pressed keys
            %
            % The fprintf statement implicitly assumes that only one key will have
            % been pressed. If this assumption is not correct, an error will result

            keyID = min(find(firstPress));
            if any(ismember(keys.rating, keyID))
                fprintf('Key pressed: %s, which is rating: %d\n', KbName(keyID), find(ismember(keys.rating, keyID)));
            else
                fprintf('Key pressed: %s, which is not a valid response nor rating key.\n', KbName(keyID));
            end

            if keyID == keys.EXPtrigger
                
                % Show message to signal start of run
                message1 = 'Tout vas bien, nous allons commencer.';
                Screen('TextSize', param.win, round(param.textSize*1.17));
                DrawFormattedText(param.win, message1, 'center', 'center', param.colour.stim, [],[],[], 1.5); % 1.5 - vertical spacing
                Screen('DrawingFinished', param.win);
                Screen('Flip', param.win);                                        

                fprintf('\nConfirming all is well.\n');
                                
                [keys.STOP] = wait4Key([], keys.STOP, keys.kbDevice, 2);                
                break
                
            elseif firstPress(KbName('r'))
                
                % Show message to signal start of run
                message1 = 'Encore une fois, veuillez appuyer, séquentiellement,\nsur les touches de 1 à 8.';
                message3 = '     1      2      3      4      5      6      7      8    ';
                Screen('TextSize', param.win, round(param.textSize*1.17));
                Screen('TextStyle', param.win, 1);
                DrawFormattedText(param.win, message1, 'center', param.xy0(2)-100, param.colour.stim, [],[],[], 1.5); % 1.5 - vertical spacing
                Screen('TextSize', param.win, param.textSize);
                Screen('TextStyle', param.win, 1);
                DrawFormattedText(param.win, message3, 'center', param.xy0(2)+40, param.colour.stim);
                Screen('DrawingFinished', param.win);

                Screen('Flip', param.win);                                        


                fprintf('\nWaiting to check key presses. Press "s" to stop and start experiment, or r to instruct a repeat.\n');
                
                    
            elseif firstPress(KbName('Escape'))
                keys.STOP = 1;
                KbQueueRelease(keys.kbDevice);
                return;
            end
        end
    end
end

KbQueueRelease(keys.kbDevice);






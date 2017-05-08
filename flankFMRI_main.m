% Flanker Task - fMRI adaptation, with visual noise manipulation


% % % % Design: Congruent Flanskers vs. Incongruent Flankers vs. Masked flankers (congruent)
% Targets and Flankers >>>>
% Presented With or Without visual noise added
% 6 outcome colours per block, contingent on action and condition
% AOIs: 100, 300, 500 ms
% Outcome duration: 300 ms


% 6 runs of 2 blocks, ~ 11 mins each
% to start 2 & 3 runs, need input from experimenter and a scanner trigger to
% continue programme


%%%%%% Check keys are correct, or change below

% keys.MRItrigger     = KbName('t');
% keys.responses      = KbName({'r','g','b','y', '1','2','3','4'}); % All response keys, from resp. boxes????
% keys.action         = KbName({'y', '1'}); % Left and Right Action Keys ????

% to start a run, experimenter will have to press the s key.
% keys.EXPtrigger     = KbName('s');
% NS, Nov 2015


%%% Updated, NS, March 2017
%%% - Separate each block into separate runs (so we don't need to model breaks)
%%% - No error replacement !

%%%%% To do:
%%%%%% - Combine training into main script
%%%%%% - Add In-scanner training of a few trials


%%%%%&% Questions:
%%%%%%% - Since there is a deadline for ratings, give feedback that no
%%%%%%% ratings was chosen?


%%%%%%%%% At CENIR, check :
%%%%%%%%% - trigger & response keys
%%%%%%%%% - Screen settings/distance

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Clear window and workspace

clear all;
clc;

sca; % close PTB windows
PsychJavaTrouble;
KbName('UnifyKeyNames');
AssertOpenGL;

Screen('CloseAll');
clear all;

% PsychJavaTrouble;
KbName('UnifyKeyNames');
AssertOpenGL;

savePath = '../data';
if ~exist(savePath, 'dir')
    mkdir(savePath);
end


% % % % % % % % % To run on test mode
scriptTest = 2; % scriptTest=0: exp  %% scriptTest=1: In fMRI  %% scriptTest=2: Not in fMRI 
testStage = 'exp'; % if scriptTest, then choose stage: train, train2, exp

getRatings = 1; % Get Online Ratings for all subjects

            
%%  Initialise session info
% To make critical data info available to all functions

global param keys colno data


% Get Subj & Experiment info
if ~scriptTest
    argindlg = inputdlg({'Participant number (two-digit)',...
                         'Stage: train, train2, exp)',...
                         'fMRI: y or n'});
    % argindlg = inputdlg({'Participant number (two-digit)',...
    %                      'Stage (train, train2, exp)',...
    %                      'fMRI (y or n)'}, '', 1, {'','',''}, 'on');
    if isempty(argindlg)
        error('Experiment Cancelled!');
    end

    data.subj  = str2num(argindlg{1});
    data.stage = argindlg{2};
    if argindlg{3} == 'y'
        data.fMRI = 1;
    else
        data.fMRI = 0;
    end

else
    data.subj  = 99; 
    data.stage = testStage;
    if scriptTest == 1
        data.fMRI = 1;
    else
        data.fMRI = 0;
    end    
end

data.date  = datestr(now,'yyyymmdd-HHMM');
data.name  = sprintf('flankFMRI_S%02d_%s_%s.mat', data.subj, data.stage, data.date);

subjPath   = [savePath filesep sprintf('S%02d', data.subj)];
if ~exist(subjPath, 'dir')
    mkdir(subjPath);
end
clear savePath

    
%% Initialise variables
% Screen
param.screenWidth       = 40;           % in cm

if data.fMRI
    param.viewDistance  = 120;          % in cm
    param.textSize      = 34;           % in points
else
    param.viewDistance  = 60;           % in cm    
    param.textSize      = 28;           % in points
end


% Stim
param.fixPointSize      = .2;           % in visual degrees
param.circDeg           = 2.4;          % For Outcomes, in visual degrees

% % Images with target/flankers
% % % first cell not masked, second cell, masked; targets in rows, flankers in cols
param.figStimRefs{1}    = {'LeftCongNM', 'LeftIncongNM'; ... % 1 1, 1 2        
                            'RightIncongNM', 'RightCongNM' };   % 1 2, 2 2
param.figStimRefs{2}    = {'LeftCongMask', 'LeftIncongMask'; ... % 1 1, 1 2        
                            'RightIncongMask', 'RightCongMask' };   % 1 2, 2 2
param.figScale          = param.viewDistance/100; % fig size set for 1m viewDistance, so scale based on actual viewDistance!
                    

% Timing, all in seconds!
param.stimDur           = .050;         % Duration of target % secs
param.aimHz             = 60;           % Hz
param.fixationDur       = [2   4];      % secs
param.responseWindow    = 1.2;          % secs
param.aoiDur            = [.100, .300, .500]; % secs
param.effectDur         = .300;         % secs
param.effect2scaleInt   = [2   4];      % secs
param.ratingWindow      = 1.5;          % secs
% more on rating scale
param.waitRatWin        = 0;            % wait rest of window after response? logical, y or n
param.noRatFeedback     = 1;            % logical, y or n
param.noRatFeedbackDur  = 1;            % secs



% If uncertain, or for macs:
% [keyboardIndices, productNames, allInfos] = GetKeyboardIndices;
% keys.kbDevice           = keyboardIndices; % this is the device that will be called by the KbQueue Functions, check with GetKeyboardIndices which number to use
% keys.kbDevice           = 0;  % for Win          
keys.kbDevice           = [];  % for Mac
keys.escape             = KbName('Escape');
keys.pause              = KbName('p');
keys.enter              = KbName('Return');
keys.MRItrigger         = KbName('t');
keys.EXPtrigger         = KbName('s');

if data.fMRI % different response keys/codes
    keys.action         = KbName({'e', 'b'}); % Left and Right Action Keys
    keys.rating         = KbName({'d', 'n', 'z', 'e', 'b', 'y', 'g', 'r'}); % All response keys, from both left & right resp. boxes
else
    keys.action         = KbName({'F','J'});
    keys.rating         = KbName({'1!','2@','3#','4$','5%','6^','7&','8*'});
end

keysofinterest          = [keys.MRItrigger, keys.EXPtrigger, keys.action, keys.rating, keys.enter, keys.pause, keys.escape]; % only keys that will be read and recorded by KbQueueCheck
keys.STOP               = 0;            % To Stop running scripts, logical
  

%% Define colours

param.colour.black   = [0 0 0];
param.colour.white   = [1 1 1];
param.colour.bkgd    = param.colour.black;
param.colour.stim    = param.colour.white;
param.colour.text    = param.colour.white;

effectsExp   = [255  212  42;...    % yellow       
                0    185  255;...   % light blue
                0    220  0;...     % green                
                255  0     10;...   % red
                0    70    255;...  % dark blue
                255  120  0 ];      % orange   
                        
effectsTrain = [180  120  90;...    % purple                           
                50   240  160;...   % light green
                0    115  200;...   % blue
                245  95   255;...   % lilac
                170  136  0;...     % green/brown
                160  160  160 ];    % grey
            


%% Randomise order of trials, colour groups, etc

nRepeat     = 2; % Repeat of trial (nCond*nAction*nAOI) per block
nColours    = 6;
nEffects    = nColours;
nCond       = 3; % Congruent vs. Incongruent vs. Masked
nAction     = 2; % left vs right
nAOI        = length(param.aoiDur);

% set seed of random number generator to subj. no.
data.rng = rng('shuffle'); % save/set random number generator
% rng(str2num(data.subj)*data.time*10); %#ok<ST2NM> for Matlab 2012 version

switch data.stage
    case {'train', 'train2'}
        nBlocks = 1;
        param.colour.effects = effectsTrain./255; % for 0-1 colour mapping            
        
    case 'exp'
        nBlocks = 6;
        param.colour.effects = effectsExp./255; % for 0-1 colour mapping
        
    otherwise
        error('No identifiable stage.');
end
clear effectsExp effectsTrain

% Set up block matrices
[blocks, randColours] = flankFMRI_Rand_TrialColourBlock(nBlocks, nColours, nEffects, nRepeat, nCond, nAction, nAOI);


% For shorter training in scanner - limit to 10 trials
if strcmp(data.stage, 'train2')
    blocks{1} = blocks{1}(1:10, :);
end



% if testing script, shorten blocks
if scriptTest > 0 && ~strcmp(data.stage, 'train2')
    if nBlocks > 1
        for i = 1:3
            blocks{i} = blocks{i}(1:6,:);
        end
    end
    nBlocks = size(blocks, 2); % Correct nBlocks
end


% Initialise data variables
data.block      = blocks;
data.colourMaps = randColours; % 1 col per block
data.raw        = cell(1, nBlocks);
data.trialTimes      = cell(1, nBlocks);
data.allTimes   = {'time', 'label'};
data.triggerTimes = nan(1, nBlocks); % MRI trigger times at the start of each block

% for record
data.rawHdr     = {'subj', 'cond', 'noise', 'flank', 'target', 'cong', 'aei', 'trialtype', 'effect',...
                    'thisAction', 'actKey', 'rt', 'rt2', 'rating', 'ratingKey', 'ratingRT', 'correct'};
data.trialTimesHdr   = {'start', 'fixDur', 'stimOn', 'respTime', 'effectOn', 'effectOff',...
                    'realAOI', 'wait4Scale', 'scaleOn_vbl', 'scaleOff_vbl', 'ratingTime', 'ratingRT'};



clear blocks randColours nColours nEffects nRepeat nCond nAction nAOI

    
% Columns in block array (not in data.raw)
colno.cond      = 1;
colno.noise     = 2;
colno.flank     = 3;
colno.target    = 4;
colno.cong      = 5;
colno.aoi       = 6;
colno.trialType = 7;
colno.effect    = 8;
    


%% Startup Psychtoolbox
    
try



if ~scriptTest % real exp
    % Since it's not priming, could do this, if PTB not happy
%     Screen('Preference', 'SkipSyncTests', 1);

    % PTB opening screen will be empty = black screen
    Screen('Preference', 'VisualDebugLevel', 1);
    Priority(2); %Highest priority when running program
%     screenNumber=max(Screen('Screens')); % Normal
    screenNumber=1;
    [param.win, param.wrect] = PsychImaging('OpenWindow', screenNumber, param.colour.bkgd);
    HideCursor;
    checkHz = 1; % check that screen refresh rate matches desired one, when in experiment mode
        
else
    % PTB opening screen will be empty = black screen
    Screen('Preference', 'VisualDebugLevel', 1);

%     Screen('Preference', 'SkipSyncTests', 1);
       
%     screenNumber=0;  % can specify number, otherwise, default
%     screenNumber=max(Screen('Screens'));
    screenNumber=1;
    %     [param.win, param.wrect] = Screen('OpenWindow', screenNumber, param.colour.bkgd);
    [param.win, param.wrect] = PsychImaging('OpenWindow', screenNumber, param.colour.bkgd);
    HideCursor;
end
     

Screen('ColorRange', param.win, 1, 0); % Adjust color range to 0-1


% Timing stuff
param.Hz    = Screen('NominalFrameRate',param.win); % Actual refresh rate, in Hz 
param.rft   = Screen('GetFlipInterval', param.win); % duration of 1 screen frame
param.slack = param.rft/3;


% If not testing script
if exist('checkHz', 'var') && checkHz == 1 && param.Hz ~= param.aimHz
    Priority(0);  %Reset priority 
    KbQueueRelease(keys.kbDevice); 
    ListenChar(0);
    Screen('CloseAll'); % Close PTB screen  
    error('CHECK REFRESH RATE');
end



% Visual stuff
[param.xy0(1), param.xy0(2)] = RectCenter(param.wrect);
[nPixels, nPixelsUnrounded] = degrees2pixels(1, param.viewDistance, param.wrect(3)/param.screenWidth);  
param.pixelPerDegree    = nPixels;

param.fixPointSizePix   = param.fixPointSize*param.pixelPerDegree;
param.stim.circleDiam   = param.pixelPerDegree*param.circDeg;

% Set Up Stimuli
param.stim.fixRect      = CenterRect([0, 0, param.fixPointSizePix, param.fixPointSizePix], param.wrect);
param.stim.circleBox    = CenterRect([0 0 param.stim.circleDiam param.stim.circleDiam], param.wrect);

errorCross = [...
    -0.7 -1;
    0.7 1;
    -0.7 1;
    0.7 -1];
errorCross = errorCross * (param.stim.circleDiam/3); % a bit smaller than outcome
param.stim.errorCross = [errorCross(:,1) + param.xy0(1) errorCross(:,2) + param.xy0(2)]'; % centre on screen
clear errorCross

% % Flankers/Targets, and scale if needed
img = imread( sprintf( '%s.png', param.figStimRefs{1}{1, 1} ) );
[s1, s2, s3] = size(img);    
param.stim.figRect = CenterRect([ 0 0 round(s2*param.figScale) round(s1*param.figScale) ], param.wrect);
clear img s1 s2 s3
for n = 1:2
    for t = 1:2
        for f = 1:2
            img = imread( sprintf( '%s.png', param.figStimRefs{n}{t, f} ) );               
            param.stim.( param.figStimRefs{n}{t, f} ) = Screen('MakeTexture', param.win, img);
            clear img
        end
    end
end

% Text stuff  
Screen('TextFont', param.win, 'Helvetica'); % Screen('TextFont', param.win, 'Lucida Console');
Screen('TextSize', param.win, 30);
Screen('TextStyle', param.win, 1);



%% Start runs/blocks
for b = 1:size(data.block, 2)
            
    if ~keys.STOP % if stop keys has not been pressed    

        fprintf('\nStart of block %d \n', b);  
        
        % Show message to signal start of run
        message1 = 'Veuillez attendre.';
        Screen('TextSize', param.win, param.textSize);
        DrawFormattedText(param.win, message1, 'center', 'center', param.colour.text);
        block_vbl = Screen('Flip', param.win);                                        
        data.allTimes(end+1,:) = {block_vbl, sprintf('block%d_waitMessage', b)};
                    
        %% Wait for experimenter input to confirm start
        
        fprintf('Waiting for experimenter to press "s" to start. \n');
        
        % Start normal keyboard recording capacity - Can't use Queues before the
        % KbTriggerWait command! or need to use KbQueueRelease first
        keyList                 = zeros(1,256);
        keyList(keysofinterest) = 1;
        KbQueueCreate(keys.kbDevice, keyList);
        ListenChar(-1); % Prevent spilling of keystrokes into console:

        [keys.STOP, ~, expTriggerTime] = wait4Key(keys.EXPtrigger, keys.STOP, keys.kbDevice);
        data.allTimes(end+1,:) = {expTriggerTime, 'EXPtrigger'};
        
        
        if ~keys.STOP     
            % Release Queues for possible MRI 
            KbQueueRelease(keys.kbDevice)
            ListenChar(0); 

            %% Wait exclusively for fMRI triggers

            if data.fMRI
                
                fprintf('Waiting for fMRI trigger (or the "t" key). \n')
                
                data.triggerTimes(b) = KbTriggerWait( keys.MRItrigger );
                data.allTimes(end+1,:) = {data.triggerTimes(b), 'MRItrigger'};

                % or, if that doesn't work, could do (basically what the other function does):
            %     keyList                 = zeros(1,256);
            %     keyList(keys.MRItrigger) = 1; % only read MRI events
            %     KbQueueCreate(keys.kbDevice, keyList);
            %     data.runStartTimes(r) = KbQueueWait(keys.kbDevice);                
            end

            % Re-Start normal keyboard recording capacity - Can't use Queues before the
            % KbTriggerWait command! or need to use KbQueueRelease first
            keyList                 = zeros(1,256);
            keyList(keysofinterest) = 1;
            KbQueueCreate(keys.kbDevice, keyList);
            ListenChar(-1); % Prevent spilling of keystrokes into console:

%             % Prepare participants for start of run
%             DrawFormattedText(param.win, 'Get ready...', 'center', 'center', param.colour.stim, [], [], [], 1.5);
%             Screen('Flip', param.win);
%             WaitSecs(2);  % secs
 

            %% Start Block

            % Extra time with fixation dot at start of block
            Screen('FillRect', param.win, [param.colour.stim 1], param.stim.fixRect);
            vbl = Screen('Flip', param.win); % clear screen
            data.allTimes(end+1,:) = {vbl, 'extraFixation'};
            
            WaitSecs(1);  % secs
            

            % Run a block of trials
            flankFMRI_blockfun(b, getRatings);        


            save([subjPath filesep data.name], 'data', 'param', 'keys');
            fprintf('\n ****************** DATA SAVED!! ****************** \n') 


            if ~keys.STOP % if stop keys has not been pressed    

                if b == nBlocks  % If last block

                    message1 = 'Fin de l''expérience \n\n\n Veuillez attendre l''expérimentateur.';

                    Screen('TextSize', param.win, param.textSize);
                    DrawFormattedText(param.win, message1, 'center', 'center', param.colour.text);
                    Screen('DrawingFinished', param.win);
                    vbl = Screen('Flip', param.win);
                    data.allTimes(end+1,:) = {vbl, 'endMessage'};

                    [keys.STOP] = wait4Key(keys.enter, keys.STOP, keys.kbDevice);

                % The alternative is between blocks/runs, where we go back to the start of a run (so need experimenter input to restart)
                end % if b == nBlocks

            else
                fprintf('\n\n  ------------Experiment stopped by user!!------------\n')
                break
            end % ~keys.STOP

        else
            fprintf('\n\n  ------------Experiment stopped by user!!------------\n')
            break
        end % ~keys.STOP
        
    else
        fprintf('\n\n  ------------Experiment stopped by user!!------------\n')
        break
    end % ~keys.STOP
        
    KbQueueRelease(keys.kbDevice); % end kb queues
    ListenChar(0); % Restore keystrokes
    
end % for b=1:nBlocks


% % % % End of Experiment
save([subjPath filesep data.name], 'data', 'param', 'keys');
fprintf('\n ****************** DATA SAVED!! ****************** \n')


KbQueueRelease(keys.kbDevice); 
ListenChar(0);
Priority(0);    % Reset priority 
sca;            % Close PTB screen  


catch err
    
if isfield(data, 'name')
    save([subjPath filesep data.name], 'data', 'param', 'keys');
    fprintf('\n ****************** DATA SAVED!! ****************** \n')
else
    fprintf('\n ****************** DATA NOT SAVED, as no data.name field!! ****************** \n')
end


KbQueueRelease(keys.kbDevice); 
ListenChar(0);
Priority(0);    % Reset priority 
sca;            % Close PTB screen  
    
rethrow(err);

end

   
% path(oldpath);





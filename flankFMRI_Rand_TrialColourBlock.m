function [blocks, randColours] = flankFMRI_Rand_TrialColourBlock(nBlocks, nColours, nEffects, nRepeat, nCond, nAction, nAOI)

% % % % Output: blocks, with Cols = noise, flankers, target, aoi, congruency, trialType, colour

% % Each block has nRepeat repetitions of each basic trial
% % nBlocks block repetitions
% % Given nColours colours in total, latin sq rotated

% % % Trials:
% % % nCond: Flankers vs. Incongruent Flankers vs. Masked flankers (congruent)
% % % nAction: action alternatives: left vs right
% % % nAOI: AOIs
% % % Per block, total = nCond*nResp*nAOI * nRepeat of trials

% % % thisTrialType:
% % % No Noise:
% % % 1 - Compatible-Left,   2 - Compatible-Right,
% % % 3 - Incompatible-Left, 4 - Incompatible-Right
% % % Noise:
% % % 5 - Compatible-Left,   6 - Compatible-Right


% NS, Nov 2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Get colours per block and randomise appearance
% 1 colour per priming * hand condition
colourOrder = latsq(nColours);
randColours = colourOrder(1:nEffects, randperm(nColours));


%% Get all blocks
blocks      = cell(1, nBlocks);

for b = 1:nBlocks

    colours = randColours(:, b);

    %% Make a block
    fullBlock  = NaN(nCond*nAction*nAOI*nRepeat, 8);    % Cols = nconditions, noise, flanker, target, cong, aoi, trialType, colour
    count      = 0;
    trialType  = 0; % start of counter for cong x action conditions for specifying colour - for Forced!
    % % % thisTrialType:
    % % % No Noise:
    % % % 1 - Compatible-Left,   2 - Compatible-Right,
    % % % 3 - Incompatible-Left, 4 - Incompatible-Right
    % % % Noise:
    % % % 5 - Compatible-Left,   6 - Compatible-Right,

    for cond = 1:nCond
        for t = 1:nAction
            trialType = trialType+1;

            if cond == 1;           % compatible trials, Unmasked
                noise = 1;
                flank = t;
                cong = 1;
            elseif cond == 2        % incompatible, Uunmasked
                noise = 1;
                if t == 1
                    flank = t + 1;
                else
                    flank = t - 1;
                end
                cong = 2;

            elseif cond == 3        % compatible trials, Masked
                noise = 2;
                flank = t;
                cong = 1;
            end             

            for i = 1:nAOI
                for r = 1:nRepeat
                    count=count+1;                
                    fullBlock(count, :) = [cond, noise, flank, t, cong, i, trialType, colours(trialType)];                               
                end
            end
        end
    end

    nTrials     = size(fullBlock,1);
    blocks{b}   = fullBlock(randperm(nTrials), :) ;                        


end


        

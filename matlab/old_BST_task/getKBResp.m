
function [RESP]=getKBResp(respWindowDuration, acceptedResps, startTimeStamp,terminateUponResp);

if nargin<4 | isempty(terminateUponResp)
    terminateUponResp = 0; %change default to not terminate upon response

end
if nargin<3 | isempty(startTimeStamp)
    startTimeStamp=GetSecs;
end
if nargin<2 | isempty(acceptedResps)
    acceptedResps='all';
end
if nargin<1 | isempty(respWindowDuration)
    respWindowDuration=Inf;
end

keyFlag=0;
while GetSecs-startTimeStamp<respWindowDuration
    FlushEvents('keydown'); % flush all prior keydown events so that it is clear for the upcoming input
    [keyIsDown, secs, key] = KbCheck; % Check to see if a Key is being pressed
    if  keyIsDown & ~keyFlag ; % if a key was being pressed and there was no earlier response
        if (size(find(key),2)==1); % check to see that only 1 key was pressed

            tmpResp=KbName(key); % Convert the 'key' vector (which is 0's and 1's ) to the ascii character that was pressed
            tmpResp=tmpResp(1); % take the first character in tmpResp as numbers can be represented with their shift possibilities too (e.g. '5' is actually '5%')

            if strcmp(acceptedResps,'all') | ~isempty(find(strcmp(tmpResp,acceptedResps)))
                RESP.key=tmpResp;
                RESP.time=secs-startTimeStamp;
                keyFlag=1;
                if terminateUponResp
                    return;
                end
            end
        end
    end
end
if ~keyFlag
    RESP.key='None';
    RESP.time=-1;
end
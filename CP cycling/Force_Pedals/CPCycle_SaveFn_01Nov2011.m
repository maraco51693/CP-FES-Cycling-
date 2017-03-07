%% Name .mat file

    datime = datestr(now);
    colon = datime == ':';
    space = datime == ' ';
    dash  = datime == '-';
    datime(colon) = '';
    datime(space) = '_';
    datime(dash) = '';
    
    prompt = {'Subject #?','When? (PRE,POST,etc.)','Type of test? (forcepedals)', 'Loaded? (Enter loaded or unloaded)','Trial #? (1,2,...)'};

    dlgTitle = 'File Name';
    numlines = 1;
    default = {'000','PREPOST','forcepedals','loadedunloaded','1'};
    userinfo = inputdlg(prompt,dlgTitle,numlines,default);
    
    if isempty(userinfo) == 0 
        sub = userinfo{1};
        reltime = userinfo{2};
        testype = userinfo{3};
        resist  = userinfo{4};
        trial   = userinfo{5};

        Filename = strcat('FESCycling_',sub,'_',reltime,'_',testype,'_',resist,'_',trial,'_',datime)

%     cd path_file
% 
        save(Filename)
    end
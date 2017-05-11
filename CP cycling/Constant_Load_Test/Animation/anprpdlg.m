function anpropertydialog( Action  , ...
                           hTarget , hWorkingFig    , ...
                           cLabels , cProperties    , ...
                           cValues , cFieldNames    , ...
                           chMethod, chUpdateAction , ...
                           chTitle , chHelpText       ...
                         )
                           
%ANPRPDLG Properties dialog function.
%	ANPRPDLG( ACTION, TARGET, WORKINGFIG, TEXT, VALUES, PROPERTIES, ...
%             FIELDNAMES, UPDATEMETHOD, UPDATEACTION, FIGTITLE, FIGHELP )
%	creates the properties modification dialog for a given target object;
%   modifies the object PROPERTIES as values are changed;
%   and sends an UPDATEACTION command using the specified UPDATEMETHOD
%   once the OK button is hit.
%
%	ACTION may be one of 4 strings:
%	'#Initialize'  Initialize the figure.
%	        '#OK'  OK button callback.     -- internal use only
%	    '#Cancel'  Cancel button callback. -- internal use only
%	      '#Help'  Help button callback.   -- internal use only
%
%	TARGET is the handle of the object to be modified.
%
%	WORKINGFIG is the handle for the figure the target object is in.
%
%	TEXT is a cell array of text strings for the titles of the 
%   edit text control areas (ETBoxes).
%
%	VALUES is a cell array of text strings for the current values in the
%	ETBoxes (length & order must match TEXT cell array) 
%
%	PROPERTIES is a cell array of text strings that define the official 
%   HG object properties for the ETBoxes (length & order must match TEXT)
%
%   FIELDNAMES is a cell array of field names for the data structure that
%   will be sent back to the specified UPDATEMETHOD alng with the
%   UPDATEACTION command. The structure will contain the final text strings
%   in each of the ETBoxes when the OK button is hit.
%   (length & order must match TEXT cell array)
%
%	METHOD is the name of the function that draws the object in question.
%   It must suppoort the call METHOD( UPDATEACTION, DATASTRUCTURE )
%
%	FIGTITLE is the title for the figure.
%
%	FIGHELP is the help text for the figure.
%
%	See also ANDOT, ANRECT, ANTEXT.

%   Data structure in PrpDlgFig UserData:
%   sHandles = struct( 'PropertiesFig'  , []        , ...
%                      'AnimationFig'   , hWorkingFig, ...
%                      'TargetObj'      , Handle    , ...
%                      'ETBoxes'        , []        , ...
%                      'OKBtn'          , []        , ...
%                      'CancelBtn'      , []        , ...
%                      'HelpBtn'        , []        , ...
%                      'ObjMethod'      , chMethod      ...
%                  );

%	Loren Dean  March, 1995.
%   Kevin Kohrt March, 1997.
%   3/06/97 KGK Convert to Switch block
%   3/06/97 KGK Break out local_Initialize subroutine
%   4/02/97 KGK Convert to new structure of Working Fig UserData; clean up
%   4/07/97 KGK convert cProperties, cLabels, & cValues to cell arrays for prpdlg
%   4/07/97 KGK make one callback applied to all ETBoxes 
%   4/10/97 KGK Breaks code by starting total rewite for v5 optimization
%   4/15/97 KGK Bug fixes. Some code clean up.
%   4/15/97 KGK Major changes needed to have consistant modularity & functionality
%   4/25/97 KGK rewrite for Ansim2
%   $Author$  $State$
%	Copyright (c) 1990-97 by The MathWorks, Inc.
% 	$Revision$  $Date$

%==========================================================================
% Check Inputs
%==========================================================================
%    OutHandles = anprpdlg( Action      ,  Handle,  hWorkingFig  , ...
%                           cLabels,  cValues,  chMethod      , ...
%                           cProperties ,  FigTag,  chTitle    , ...
%                           chHelpText                               ...
%                         )

if nargin==1, % i.e. a call from prpdlg figure to prpdlg itself
    [ hUICtrl, hPropFig ]  = gcbo;
    sPUD                = get(hPropFig,'UserData');
    hWorkingFig         = sPUD.AnimationFig;
end

switch Action,

%%%%%%%%%%%%%%%%%%
%%% Initialize %%%
%%%%%%%%%%%%%%%%%%  
case '#Initialize',
    % Call expects Working Figure to be passed in
    if nargin < 10,
        % No title provided. Make one.
        sFigUserData = get( hWorkingFig, 'UserData' );
        SimHandle = sFigUserData.m.hAnimationBlock;
        chTitle  = ['Object Properties: ' get_param(SimHandle,'Name')];
    end 
  
    if nargin < 11,
        % No Help text provided. Make some up.
        chHelpText=[ ...
        'The entries in each of these blocks get evaluated.  If an entry is'
        'bad, a default value will be used as determined by the calling    '
        'function.  Vectors and matrices should be entered with square     '
        'brackets enclosing them.  Strings do not need quotes enclosing    '
        'them.  Signals can be referenced as u(n) where n is the signal    '
        'number to be used.                                                '
        'An example entry is:                                              '
        '  u(1)+50*cos(u(2))                                               '
        ];
    end
          
    local_Initialize(   hTarget , hWorkingFig    , ...
                        cLabels , cProperties    , ...
                        cValues , cFieldNames    , ...
                        chMethod, chUpdateAction , ...
                        chTitle , chHelpText       ...
                    )
  
%%%%%%%%%%%%%%
%%% Change %%%
%%%%%%%%%%%%%%  
case '#Change',
    %------------------------------------------------------------------------
    % User has changed a value in an ETBox and wants to see how it looks
    %------------------------------------------------------------------------
    
%     % Determine which field and from what property dialog figure
%     [ hUICtrl, hPropFig ] = gcbo;
%     
%     % Get the structure of handles and data from the figure's userdata
%     sPUD = get( hPropFig, 'UserData' );
    
    % Find the Property and Value to be changed, as well as the change record
    % cPropValHist{1} = Property string
    % cPropValHist{2} = Value (string expression)
    % cPropValHist{3} = History of Value assignments (cell array of strings)
    cPropValHist   = get( hUICtrl, {'Tag','String','UserData' } );
    ObjProperty    = cPropValHist{1};
    PropertyValue  = cPropValHist{2};
    cHistory       = cPropValHist{3};
    
    % Call the change method
    ItWorked = feval( sPUD.UpdateMethod, ...
                     '#ChangeLook', sPUD.TargetObj, hUICtrl );

     % Record the event if the assignment worked, or reset the field if it did not
     if ItWorked,
        % Record the new settings in the ETBoxes UserData
        set( hUICtrl, 'UserData', { cHistory{:}, PropertyValue } )
    else,
        % reset the ETBox field with the previous end value
        set( hUICtrl, 'String', cHistory{end} )
        disp(lasterr)
        disp( ['Bad property value: ' PropertyValue])
        WarningTxt = ['This is an invalid property value and the field has ',...
                      'been reset to its previous value. See the Command ',...
                      'Window for a copy of the offending entry and the' ,...
                      'corresponding MATLAB error message.'
                     ];
        warndlg( WarningTxt, 'Invalid Entry' )
    end % if ItWorked  
    
% %%%%%%%%%%%%%%
% %%% Apply %%%
% %%%%%%%%%%%%%%  
% case '#Apply',
%     %------------------------------------------------------------------------
%     % User has changed a value in an ETBox and wants to see how it looks
%     %------------------------------------------------------------------------
%     
% %     % Determine which field and from what property dialog figure
% %     [ hUICtrl, hPropFig ] = gcbo;
% %     
% %     % Get the structure of handles and data from the figure's userdata
% %     sPUD = get( hPropFig, 'UserData' );
%     
% %     % Find the Property and Value to be changed, as well as the change record
% %     % cPropValHist{1} = Property string
% %     % cPropValHist{2} = Value (string expression)
% %     % cPropValHist{3} = History of Value assignments (cell array of strings)
% %     cPropValHist   = get( hUICtrl, {'Tag','String','UserData' } );
% %     ObjProperty    = cPropValHist{1};
% %     PropertyValue  = cPropValHist{2};
% %     cHistory       = cPropValHist{3};
% 
%     % Get the Property/Value pairs from all ETBoxes
%     % cPropValHist(:,1) = Property strings from each ETBox
%     % cPropValHist(:,2) = History of cValues from each ETBox (cell array of strings)
%     % cPropValHist(:,2) = Value (string expression)
%     cPropAndHist    = get( sPUD.ETBoxes, {'Tag','UserData','String'} );
%     cObjProperty    = cPropAndHist(:,1);
%     cValueHistory   = cPropAndHist(:,2);
%     cPropertyValue   = cPropAndHist(:,3);
% 
%     % Call the change method
%     ItWorked = feval( sPUD.UpdateMethod, ...
%                  '#ChangeLook', sPUD.TargetObj, sPUD.ETBoxes );
%     
%     % Loop to assign all of the new properties to the object
%     for idx = 1 : length( cObjProperty ),
%         hUICtrl = sPUD.ETBoxes(idx);
%         
%          % Record the event if the assignment worked, or reset the field if it did not
%         if ItWorked,
%             % Record the new settings in the ETBoxes UserData
%             set( hUICtrl, 'UserData', ...
%                          { cValueHistory{idx}{:}, cPropertyValue{idx} } )
%         else,
%             % reset the ETBox field with the previous end value
%             set( hUICtrl, 'String', cValueHistory{idx}{end} )
%             %disp( ['The entered value: ' cPropertyValue{idx} ' is invalid and has been reset'])
%             disp(lasterr)
%         end % if ItWorked   
%                  
%     end % for idx...
%     


    
%%%%%%%%%%
%%% OK %%%
%%%%%%%%%%
case '#OK',
    %------------------------------------------------------------------------------
    % User has hit the OK button, implying all is well and it should stay that way
    %------------------------------------------------------------------------------
    
%     % Get the handle the Property Dialog figure
%     hPropFig = gcbf;
%     
%     % Get the structure of handles from the figure's userdata
%     sPUD = get( hPropFig, 'UserData' );
    
    % Grab all of the value expressions (the actual strings) from each ETBox.
    cValues = get( sPUD.ETBoxes, {'String'} );
    
    % Assemble the property value pairs into a structure so the object
    % can extract them easily.
    sPropertyValues = cell2struct( cValues, sPUD.FieldNames, 1 );
    
    % Evaluate an #Update command using the current object's own method,
    % and pass in the Property Value structure for the object to parse
    feval( sPUD.UpdateMethod, ...
           sPUD.UpdateAction, sPUD.TargetObj, sPropertyValues );    
     
    
    % Reset figure
    anfigure( '#Reset', sPUD.AnimationFig )
    
    % Close the Property Dialog figure window 
    close( hPropFig )       



%%%%%%%%%%%%%%
%%% Cancel %%%
%%%%%%%%%%%%%%
case '#Cancel',
    %------------------------------------------------------------------------------
    % User has hit the Cancel button, so change everything back to the way it was
    %------------------------------------------------------------------------------
    
%     % Get the handle the Property Dialog figure
%     hPropFig = gcbf;
%     
%     % Get the structure of handles from the figure's userdata
%     sPUD = get( hPropFig, 'UserData' );
%     
%     % Get the initial conditions from the workking figure
%     u = angetic( sPUD.AnimationFig ); 

    % Get the Property/Value pairs from all ETBoxes
    % cPropValHist(:,1) = Property strings from each ETBox
    % cPropValHist(:,2) = History of cValues from each ETBox (cell array of strings)
    cPropAndHist      = get( sPUD.ETBoxes, {'Tag','UserData'} );
    cObjProperty    = cPropAndHist(:,1);
    cValueHistory   = cPropAndHist(:,2);
    
    % Loop to reassign all of the original properties to the object
    for idx = 1 : length( cObjProperty ),
        % Get the history cell array of the idx'th object
        cHistory =  cValueHistory{idx};
        % Check to see if there is a history!
        if length( cHistory ) > 1,
            % At least one change was made. So change it back
            % Strat by changing the string
            set( sPUD.ETBoxes(idx), 'String', cHistory{1} );
            % Then call the object's change method
            feval( sPUD.UpdateMethod, ...
                     '#ChangeLook', sPUD.TargetObj, sPUD.ETBoxes(idx) );
        end
                 
    end % for idx...

    % Resize the axes (if required and if allowed)
        
    
    % Deselect everything
    anfigure( '#DeselectObj', hWorkingFig ); 
   
    
    % Close the Property Dialog figure window
    close( hPropFig )    
    
 
%%%%%%%%%%%%
%%% Help %%%
%%%%%%%%%%%%
case '#Help',
    % Call by Property Dialog GUI button
    HelpHandle = findobj( hPropFig, 'Type','uicontrol', 'Tag','Help' );
    chHelpText    = get( HelpHandle, 'UserData' );
    helpdlg( chHelpText, 'Animation Dialog Help' );
    
end % switch Action,

%#############################################################################
%         %                                                                   %
%   END   %   main function anprpdlg                                          %
%         %                                                                   %
%#############################################################################

%#############################################################################
%         %                                                                   %
%  BEGIN  %  local function local_Initialize()                                %
%         %                                                                   %
%#############################################################################

function local_Initialize(  Handle  , hWorkingFig    , ...
                            cLabels , cProperties    , ...
                            cValues , cFieldNames    , ...
                            chMethod, chUpdateAction , ...
                            chTitle , chHelpText       ...
                        )
                        
%----------------------------------------------------------------------------
% Define key parameters
%----------------------------------------------------------------------------
% % % sFigUserData = get( hWorkingFig, 'UserData' );
FigTag      = 'Property Dialog Figure'; 
NumEdits    = length( cLabels );
FigWidth    = 400; 
Border      = 20; % i.e. width of left, right, and bottom border in GUI
uiHeight    = 20; % Height of all uicontrols
BtnWidth    = 50; % Width of buttons
txtWidth    = FigWidth - 2*Border; % Width of text fields
% Left edge of Apply,Cancel,OK buttons
BtnGroupLeft = FigWidth - Border - ( BtnWidth + 20)*2; 
% Bottom edge of text fields
txtBottom   = Border + uiHeight + 15; 

FigPosition      = get(0,'DefaultFigurePosition'); 
FigPosition(1:2) = FigPosition(1:2) - 100;
FigPosition(3:4) = [ FigWidth ( 80 + (NumEdits + 1)*2*uiHeight ) ];
FigColor         = get(0,'defaultuicontrolbackgroundcolor');

%----------------------------------------------------------------------------
% Check inputs, and configure certain parameters thereby
%----------------------------------------------------------------------------
if isempty(Handle) | strcmp( get(Handle,'Type'), 'uimenu' ),
    % Generic dialog box; write a generic title
    TitleTextString1    = 'Input Dialog';
    TitleTextString2    = ' ';    
    CancelBtnVisibilty  = 'off';
else,
    TitleTextString1    = 'Reference block input variable names as "u".';
    TitleTextString2    = 'Example: sin(u(1)*pi/180)+10';
    CancelBtnVisibilty  = 'on';
end    
                 
%----------------------------------------------------------------------------
% Determine if a Properties dialog for this figure is already open
% and close it if it is
%----------------------------------------------------------------------------
close( findobj( allchild(0), 'flat', 'Tag', FigTag ) );
                 
%----------------------------------------------------------------------------
% Initialize a structure to hold all the handles for the figure
%----------------------------------------------------------------------------
sHandles = struct( 'PropertiesFig'  , []            , ...
                   'AnimationFig'   , hWorkingFig   , ...
                   'TargetObj'      , Handle        , ...
                   'ETBoxes'        , []            , ...
                   'OKBtn'          , []            , ...
                   'CancelBtn'      , []            , ...
                   'HelpBtn'        , []            , ...
                   'UpdateMethod'   , chMethod      , ...
                   'UpdateAction'   , chUpdateAction, ...
                   'FieldNames'     , []     ...
                 );
% You cannot fill a fiels d with a cell array using the struct command
% (it creates an n-dimentional structure and places one element of your
% cell array in each dimention of the structure)
% And don't put an empty cell array in there! {} will generate a 0x0
% structure! i.e. competely empty!
sHandles.FieldNames = cFieldNames;

%----------------------------------------------------------------------------
% Create the Properties Dialog Figure
%----------------------------------------------------------------------------
hPropFig = figure( ...
    'Name'        , chTitle             , ...
    'NumberTitle' , 'off'               , ...
    'BackingStore', 'on'                , ...
    'Position'    , FigPosition         , ...
    'Color'       , FigColor            , ...
    'MenuBar'     , 'none'              , ...
    'KeyPressFcn' , 'anedit #KeyPress'  , ...
    'Visible'     , 'off'               , ...
    'Tag'         , FigTag                ...
    );
    
sHandles.PropertiesFig = hPropFig;

%----------------------------------------------------------------------------
% Build a background frame for the Apply, Cancel, and OK buttons
%----------------------------------------------------------------------------
uicontrol( ...
    'Parent'   , hPropFig                                                 , ...
    'Style'    , 'frame'                                                  , ...
    'Position' , [BtnGroupLeft-5 Border-5 (BtnWidth+20)*2+10 uiHeight+10] ...
    );

%----------------------------------------------------------------------------
% Add  Apply, Cancel, and OK control buttons:
%----------------------------------------------------------------------------
BtnGroupPosition = [ BtnGroupLeft Border BtnWidth uiHeight ];

sHandles.OKBtn = uicontrol( ...
    'Parent'   , hPropFig                                   , ...
    'String'   , 'OK'                                       , ...
    'Style'    , 'pushbutton'                               , ...
    'Units'    , 'pixels'                                   , ...
    'Tag'      , 'OK'                                       , ...
    'Position' , BtnGroupPosition + [ 1*(BtnWidth + 30) 0 0 0 ]  , ...
    'CallBack' , 'anprpdlg #OK'                               ...
    );

sHandles.CancelBtn = uicontrol( ...
    'Parent'   , hPropFig                               , ...
    'String'   , 'Cancel'                               , ...
    'Style'    , 'pushbutton'                           , ...
    'Units'    , 'pixels'                               , ...
    'Position' , BtnGroupPosition + [ 0*(BtnWidth + 30) 0 0 0 ]  , ...
    'Visible'  , CancelBtnVisibilty                     , ...
    'Tag'      , 'Cancel'                               , ...
    'CallBack' , 'anprpdlg #Cancel'                       ...
    );

% % % Bailed due to implementation details % % %
%
% sHandles.ApplyBtn = uicontrol( ...
%     'Parent'   , hPropFig                        , ...
%     'String'   , 'Apply'                          , ...
%     'Style'    , 'pushbutton'                    , ...
%     'Units'    , 'pixels'                        , ...
%     'Position' , BtnGroupPosition + [ 0*(BtnWidth + 30) 0 0 0 ]  , ...
%     'Tag'      , 'Help'                          , ...
%     'UserData' , chHelpText                         , ...
%     'CallBack' , 'anprpdlg #Apply'                  ...
%     );

%----------------------------------------------------------------------------
% Build a background frame for the Help button
%----------------------------------------------------------------------------
uicontrol( ...
    'Parent'   , hPropFig                                       , ...
    'Style'    , 'frame'                                        , ...
    'Position' , [Border-5 Border-5 BtnWidth+10 uiHeight+10]    ...
    );
%----------------------------------------------------------------------------
% Help Button
%----------------------------------------------------------------------------
sHandles.HelpBtn = uicontrol( ...
    'Parent'   , hPropFig                        , ...
    'String'   , 'Help'                          , ...
    'Style'    , 'pushbutton'                    , ...
    'Units'    , 'pixels'                        , ...
    'Position' , [Border Border BtnWidth uiHeight]      , ...
    'Tag'      , 'Help'                          , ...
    'UserData' , chHelpText                         , ...
    'CallBack' , 'anprpdlg #Help'                  ...
    );

%----------------------------------------------------------------------------
% Title text to be put above ETBoxes
%----------------------------------------------------------------------------                 
uicontrol( hPropFig, ...
    'String'   ,TitleTextString1                            , ...
    'Style'    ,'text'                                      , ...
    'Units'    ,'pixels'                                    , ...
    'Position' ,[Border txtBottom+(NumEdits+1)*40 txtWidth uiHeight]      , ...
    'Tag'      , 'HelpText1'                                  ...
    );
uicontrol( hPropFig, ...
    'String'   , TitleTextString2                           , ...
    'Style'    ,'text'                                      , ...
    'Units'    ,'pixels'                                    , ...
    'Position' , [Border txtBottom+(NumEdits+1)*40-20 txtWidth uiHeight]  , ...
    'Tag'      ,'HelpText2'                                   ...
    );

%----------------------------------------------------------------------------
% Frame around the ETBoxes                 
%----------------------------------------------------------------------------
uicontrol( hPropFig, ...
    'Style'    , 'frame'                                     , ...
    'Position' , [Border-5 txtBottom-5 txtWidth+10 NumEdits*2*uiHeight+15]   ...
    );

%----------------------------------------------------------------------------
% Add all of the ETBoxes                 
%----------------------------------------------------------------------------
pXTh    = Border;
pXTwdth = txtWidth-5;
for lp=1:NumEdits,
    pXTv = txtBottom + (NumEdits - lp)*40;
    hTextPrompt(lp) = uicontrol( hPropFig                    , ...
        'String'             , cLabels{lp}                   , ...
        'Style'              , 'text'                        , ... 
        'Position'           , [Border pXTv+20 pXTwdth uiHeight] , ... 
        'BackGroundColor'    , FigColor                      , ...
        'HorizontalAlignment','left'                           ...
        );
    % Note that the initial string must be stored in the UserData as a
    % cell array for the Cancel button to work properly
    hETBoxes(lp) = uicontrol( hPropFig                       , ...
        'Style'              , 'edit'                        , ...
        'String'             , cValues{lp}                    , ...
        'BackGroundColor'    , [1 1 1]                       , ...
        'HorizontalAlignment', 'left'                        , ...
        'Position'           , [Border pXTv pXTwdth uiHeight]    , ...
        'UserData'           , { cValues{lp} }                   , ...
        'CallBack'           , 'anprpdlg #Change'                , ...
        'Tag'                , cProperties{lp}                 ...
        );
end % for lp

% Store the field handles
sHandles.ETBoxes = hETBoxes;

%----------------------------------------------------------------------------
% Normalize everything for proper scaling, then make it visible
%----------------------------------------------------------------------------
set( allchild( hPropFig ), 'Units', 'Normalized' );
set( hPropFig, 'UserData', sHandles, 'Visible', 'on' );
set( 0, 'CurrentFigure', hPropFig ) ;

%#############################################################################
%  END  : local function local_Initialize()
%#############################################################################


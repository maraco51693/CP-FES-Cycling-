function cntrl = rst_design_ben(mdl_p, r_d_p, r_d_m)
% cntrl = rst_design_ben(mdl_p)
%   This m function is used to design an rst controller
%   based on a plant model mdl_p which is given in the
%   idpoly format.  The user will be prompted for
%   controller properties like rise time etc.
%
%   cntrl: is a structure describing the controller,
%      with the following feilds:
%         'R': the R component of the controller.
%         'S': the S component of the controller.
%         'T': the T component of the controller.
%         'lti_p': the lti model of the plant.
%         'lti_m': the lti model of the ref. model.
%         'Aaw': Anti-wind up component of the controller.
%         'Aaw_R': = Aaw - R.
%         'Ao': = The observer polynomial.
%
% cntrl = rst_design_ben(mdl_p, [r_p d_p])
%   By providing a rise time r_p and damping d_p as
%   inputs means that no use prompting is necessary.
%
% cntrl = rst_design_ben(mdl_p, [r_p d_p], [r_m d_m])
%   Can be used to include a model reference component
%   with specified model rise time r_m and model
%   damping d_m.  This makes a 2 degree of freedom
%   controller.  If ommited then no model referenc will
%   be used at all (single degree of freedom).
%

% Author : Benjamin A Saunders
%   Date : 11 / October 2003
% University of Glasgow - Mechanical Engineering

% Updates:
%   11 Oct 2003 : Benjamin A Saunders
%      Added main functionality of this function


% ------------------------------------------------------
% Check inputs

% Set default outputs (if function should fail)
cntrl = [];

% set debugging mode:
debugging = 0;

if nargin < 1
    error('Parameter ''mdl_p'' is required for this function.');
else
    if ~isa(mdl_p, 'idpoly')
        error('Parameter ''mdl_p'' is not of type idpoly.');
    end
end

if nargin < 2
    get_r_d_from_gui = 1;
else
    if length(r_d_p) ~= 2
        error('Parameter ''[r_p d_p]'' does not have (only) 2 elements.');
    end
    r_p = r_d_p(1);
    d_p = r_d_p(2);
    get_r_d_from_gui = 0;
end

if nargin < 3
    use_model_reference = 0;
else
    if length(r_d_m) ~= 2
        error('Parameter ''[r_m d_m]'' does not have (only) 2 elements.');
    end
    r_m = r_d_m(1);
    d_m = r_d_m(2);
    use_model_reference = 1;
end


% ------------------------------------------------------
% If not given, get rise times and damping coefficients via a GUI

if get_r_d_from_gui
    
    accepted_all = 0;
    while ~accepted_all
        
        % Get the plant controller dynamics
        r_d_p_input = inputdlg({'Please enter a rise time:', ...
                'Please enter a damping coefficient:'}, ...
            'Controller Dynamics Input');
        
        % Check if user pressed the 'Cancel' button
        if length(r_d_p_input) ~= 2
            % cancel whole controller design
            return;
        end
        
        % Check inputs of user
        r_p = str2num(r_d_p_input{1});
        d_p = str2num(r_d_p_input{2});
        if (isempty(r_p) | isempty(d_p))
            uiwait(msgbox('Incorrect input values!', ...
                'Controller Dynamics Input','error'));
            continue; % start the while accepted_all loop again
        end
        
        accepted_model_ref = 0;
        while ~accepted_model_ref
            
            % Ask if the user wants to use a model reference
            button = questdlg(['Do you want to use a reference model?'], ...
                'Model Reference Selection');
            
            if strcmp(button, 'Cancel')
                % cancel whole controller design
                return;
            elseif strcmp(button, 'No')
                use_model_reference = 0;
                accepted_model_ref = 1;
            else
                
                % Get the model reference dynamics
                r_d_m_input = inputdlg({'Please enter a rise time:', ...
                        'Please enter a damping coefficient:'}, ...
                    'Model Reference Dynamics Input');
                
                % Check if user pressed the 'Cancel' button
                if length(r_d_m_input) ~= 2
                    % ask again about using a reference model model
                    continue; % start the while accepted_model_ref loop again
                end
                
                % Check inputs of user
                r_m = str2num(r_d_m_input{1});
                d_m = str2num(r_d_m_input{2});
                if (isempty(r_m) | isempty(d_m))
                    uiwait(msgbox('Incorrect input values!', ...
                        'Reference Model Dynamics Input','error'));
                    continue; % start the while accepted_model_ref loop again
                end
                use_model_reference = 1;
            end
            
            accepted_model_ref = 1; % to exit the while accepted_model_ref loop
            % the while accepted_model_ref loop is not exited by continue
            % commands within the loop
            
        end % end while accepted_model_ref loop
        
        confirm_string = sprintf(['Selected plant controller dynamics:\n\n', ...
                '\trise time: %6.2f \n\tdamping: %6.2f \n\n\n'], r_p, d_p);
        if use_model_reference
            confirm_string = sprintf(['%sSelected model reference dynamics: \n\n', ...
                    '\trise time: %6.2f \n\tdamping: %6.2f \n\n\n'], confirm_string, r_m, d_m);
        else
            confirm_string = sprintf(['%sSelected model reference dynamics: \n\n', ...
                    '\tNot selected! \n\n\n'], confirm_string);
        end
        confirm_string = sprintf(['%sIs this correct? \n\n'], confirm_string);
        
        button = questdlg(confirm_string, 'Confirm Properties');
        if strcmp(button, 'Cancel')
            % cancel whole controller design
            return;
        elseif strcmp(button, 'Yes')
            accepted_all = 1; % exit the while accepted_all loop
        end
        
    end % end while accepted_all loop
    
end % end if get_r_d_from_gui

if debugging
    disp(['Debugging (', mfilename, '): Control dynamics = [', num2str([r_p d_p]), ']']);
    if use_model_reference
        disp(['Debugging (', mfilename, '): Model dynamics   = [', num2str([r_m d_m]), ']']);
    else
        disp(['Debugging (', mfilename, '): Model dynamics   = Not used.']);
    end
end


% ------------------------------------------------------
% ????
%

if use_model_reference
    % --------------------------
    % Use a model reference component
    
else
    % --------------------------
    % Without a model reference component
    
    disp(['Warning (', mfilename, '): This option is not implemented yet!']);
    return;
    
end


% ------------------------------------------------------
% Controller Synthesis
%

% Initialized the polynomial tool box
pinit;
% Change the polynomial variable propertie from s to (z^-1)
gprop('z^-1');

% Use the same sample time for the controller as the model
Ts = mdl_p.Ts;

% Assuming a desired model based on:
%                     nf_p^2                    B_p(s)
%   G(s) =  -------------------------------  = --------
%           (s^2 + 2*d_p*nf_p*s + nf_p^2)     A_p(s)
% where nf_p is the desired natural frequency and
% can be caluculated from the desired rise time as
% follows (if underdamped!!!!):

if ((d_p <= 0) | (d_p >= 1))
    warning('Can only handle 0 < d_p < 1.');
    return;
end

Cal_Wo = inline('1./Tr.*exp(D./sqrt(1-D.^2).*acos(D))','Tr','D');
Cal_Pol = inline(['[1 (-2*exp(-D.*wo*Ts).*cos(wo.*sqrt(1-D.^2)*Ts)) ' ...
      'exp(-2*D.*wo*Ts)]'],'D','wo','Ts');

% Set Up the Charicteristic Polynomial for Am
Tr_Am = r_m; D_Am = d_m;
wo_Am = Cal_Wo(Tr_Am, D_Am);
Am = Cal_Pol(D_Am, wo_Am, Ts);

% Set Up the Charicteristic Polynomial for Ao
Tr_Ao = r_p; D_Ao = d_p;
wo_Ao = Cal_Wo(Tr_Ao, D_Ao);
Ao = Cal_Pol(D_Ao, wo_Ao, Ts);

Aaw = Ao;
d = 0;

% Get B and A from lti;
%[num den] = th2tf(mdl_p);
%tf_p = tf(num, den, Ts, 'Variable', 'z^-1');
lti_p = tf(mdl_p.B, mdl_p.A, 0.05, 'Variable', 'z^-1');
[B, A] = lti2lmf(lti_p);

% Set Up to Cancel A and B
Aplus  = A;
Aminus = 1;

Bplus  = 1;
Bminus = B;

% Specified Common Factors of R and S respectfully
Rd = 1-z^-1; % Controller should have integral action (?? I think)
Sd = 1;

%Calculate degree of Ao
degAminus = deg(Aminus);
degBminus = deg(Bminus);
degRd = deg(Rd);
degSd = deg(Sd);
degAo = max(degAminus+degRd+degBminus+degSd-1, ...
    degBminus+degSd+degAminus+degRd-1);

Am = pol(Am,length(Am)-1);
Ao = pol(Ao,length(Ao)-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Solve dioph. equ.                                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

AA = Aminus * Rd;
BB = Bminus * Sd;
CC = Ao;

[r0, s0] = axbyc(AA, BB, CC);

R = r0 * Rd * Am * Bplus;
S = s0 * Sd * Am * Aplus;
T = Ao * Aplus * sum(unPol(Am)) / sum(unPol(Bminus));  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert to vectors and generated lti_m and uff                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

AR=A*R;
BS=B*S;
RB=B*R;
TB=T*B;
%Aaw_R=fliplr(pol2mat(pol(Aaw,length(Aaw)-1)-pol(R,length(R)-1)));
Aaw_R = pol(Aaw, length(Aaw)-1) - R;

%R = fliplr(unPol(R));
%S = fliplr(unPol(S));
%T = fliplr(unPol(T));
%Am = [fliplr(unPol(Am))];
%Bm = fliplr(unPol(Bminus))*sum(Am)/sum(fliplr(unPol(Bminus)));

R = unPol(R);
S = unPol(S);
T = unPol(T);
Am = unPol(Am);
Aaw_R = unPol(Aaw_R);
Bm = unPol(Bminus) * sum(Am) / sum(unPol(Bminus));

lti_m = tf(Bm, Am, Ts, 'Variable', 'z^-1');

%uff = -d / sum(fliplr(unPol(B)));
uff = -d / sum(unPol(B));

cntrl.R = R;
cntrl.S = S;
cntrl.T = T;
cntrl.Aaw   = Aaw;
cntrl.Aaw_R = Aaw_R;
cntrl.Ao    = Ao;
cntrl.lti_p = lti_p;
cntrl.lti_m = lti_m;
cntrl.Ts = Ts;


% ------------------------------------------------------
% Controller analysis

%AR_BS = AR + BS; AR_BS = fliplr(unPol(AR_BS));
%AR = fliplr(unPol(AR));
%BS = fliplr(unPol(BS));
%RB = fliplr(unPol(RB));
%TB = fliplr(unPol(TB));

AR_BS = AR + BS; AR_BS = unPol(AR_BS);
AR = unPol(AR);
BS = unPol(BS);
RB = unPol(RB);
TB = unPol(TB);

w = logspace(-6, 2, 100);

lti_sen  = tf(AR, AR_BS, Ts); % Sensitivity Function
lti_csen = tf(BS, AR_BS, Ts); % Complimentary Sensitivity Function
lti_uy   = tf(RB, AR_BS, Ts); % Affecting Responce to load disturbances (B(1)R(1) = 0)
lti_ry   = tf(TB, AR_BS, Ts); % Closed Loop Transfer Function

[mag_Sen,  pha, w] = bode(lti_sen, w);  magS  = mag_Sen(1,:)';
[mag_CSen, pha, w] = bode(lti_csen, w); magCS = mag_CSen(1,:)';
[mag_ry,   pha, w] = bode(lti_ry, w);   magry = mag_ry(1,:)';
[mag_uy,   pha, w] = bode(lti_uy, w);   maguy = mag_uy(1,:)';

nyquist_frequency=pi/(Ts); sampling_frequency=2*pi/(Ts);

% The closed loop system
lti_cl = tf(TB, AR_BS, Ts, 'Variable', 'z^-1');

plot_pzmaps_and_TS = 1;
if plot_pzmaps_and_TS
    
    figure; clf; 
    
    TSAx = BenPlot([5 3],[1 1 3 3],1,1,gcf,[50 50 20 40]);
    TpzAx = BenPlot([5 3],[4 1 2 1],1,1);
    MpzAx = BenPlot([5 3],[4 2 2 1],1,1);
    BpzAx = BenPlot([5 3],[4 3 2 1],1,1);
    set(gcf,'position',[145 40 730 655]);
    
    axes(TSAx);
    semilogx(w,magCS,'k');hold on;
    semilogx(w,magS,'Color',[0.6 0.6 0.6]);
    semilogx(w,maguy,':','Color',[0.6 0.6 0.6]);
    semilogx(w,magry,'k:');hold off;
    grid;
    xlabel('\omega[rad/s]');
    ylabel('Magnitude'); title('S and T');
    nyquist_frequency=pi/(Ts); sampling_frequency=2*pi/(Ts);
    set(gca,'XScale','log');
    axis([min(w) nyquist_frequency*1.6 0 1.8]);
    legend({'T: n->y','S: e->y','u->y','r->y'});
    
    axes(TpzAx); hold on;
    %zgrid([0.2:0.2:1],[0 : pi/5 : pi],'new');
    pzmap(lti_p);
    
    axes(MpzAx); hold on;
    %zgrid([0.2:0.2:1],[0 : pi/5 : pi],'new');
    pzmap(lti_m);
    
    axes(BpzAx); hold on;
    %zgrid([0.2:0.2:1],[0 : pi/5 : pi],'new');
    pzmap(lti_cl);
    
    b = findobj(gcf,'Tag','LTIdisplayAxes');
    axes(b(3)); title('Pole-Zero map of the Identified System');
    axes(b(2)); title('Pole-Zero map of the Control Model');
    axes(b(1)); title('Pole-Zero map of the Closed Loop System');
    
    c = findobj(gcf,'Tag','LTIresponseLines');
    for i = 1 : length(c)
        set(c(i),'Color','k');
    end
    
end

view_step_resp = 0;
if view_step_resp
    figure; clf; hold on; x = [0:0.05:40]; u = (0.5 .* square((x.*2*pi)./20)) + 0.5;
    plot(x, u, 'k:');
    plot(x, lsim(lti_p, u, x), 'b');
    plot(x, lsim(lti_m, u, x), 'g');
    plot(x, lsim(lti_cl, u, x), 'm:');
end


% ======================================================
function outMat = unPol(inPol)
% outMat = unPol(inPol)
%   Is used to transform a polynomial type back into a
%   vector.  Does the opposite as pol.  Add this here
%   because current version of pol2mat doesn't work
%   (polynomial toolbox v2.0 with winXP).

outMat = [];

for i = deg(inPol):-1:0
    outMat(end+1) = inPol{i};
end

outMat = fliplr(outMat);

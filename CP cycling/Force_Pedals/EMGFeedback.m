function [] = EMGFeedback(restFileName, maxFileName )
%UNTITLED4 Summary of this function goes here
%   To run this program, enter the title and the two inputs into the command line.  
%Ex: EMGFeedback('resting_left.mat', 'max_left.mat'))
% The first input is the matlab file containing the resting values, and the
% second input is the matlab file containing the maximum values.
%
%The first set of buttons in the gui gives you the option to plot
%everything on one graph with 12 sublots.  It gives you the option for
%filtered and unfiltered resting and maximum electrode records.
%
%Clicking the "Check Resting Voltage" button will check each resting
%electrode reading to make sure that the rectified signals fall within the secified range.
%
%Clicking the "Check Maximum Voltage" button will filter all of the data
%with a moving average and will compare the standard deviations to
%determine if they are on.  The complete list will be printed to the matlab
%screen, not to the GUI.
%
%The second set (popup menu and button) allows you to look at an individual
%electrode.  It will produce a set of 4 subplots that represent the resting
%and maximum voltage readings from that electrode, filtered and unfiltered.
% This will allow you to visually see whether or not the electrodes are
% recording properly.  


load (restFileName)
timeR = clock.signals.values(:);
rest(1, :) = LBF.signals.values(:);
rest(2, :) = LGM.signals.values(:);
rest(5, :) = LLG.signals.values(:);
rest(6, :) = LRF.signals.values(:);
rest(9, :) = LTA.signals.values(:);
rest(10, :) = LVL.signals.values(:);
rest(3, :) = RBF.signals.values(:);
rest(4, :) = RGM.signals.values(:);
rest(7, :) = RLG.signals.values(:);
rest(8, :) = RRF.signals.values(:);
rest(11, :) = RTA.signals.values(:);
rest(12, :) = RVL.signals.values(:);
ls = {'L Bicep Femoris';
    'L Gluteus Maximus';
    'R Bicep Femoris';
    'R Gluteus Maximus';
    'L Lateral Gastr.';
    'L Rectus Femoris';
    'R Lateral Gastr.';
    'R Rectus Femoris';
    'L Tibialis Anterior';
    'L Vastus Lateralis';
    'R Tibialis Anterior';
    'R Vastus Lateralis'};

load(maxFileName)
maxx(1, :) = LBF.signals.values(:);
maxx(2, :) = LGM.signals.values(:);
maxx(5, :) = LLG.signals.values(:);
maxx(6, :) = LRF.signals.values(:);
maxx(9, :) = LTA.signals.values(:);
maxx(10, :) = LVL.signals.values(:);
maxx(3, :) = RBF.signals.values(:);
maxx(4, :) = RGM.signals.values(:);
maxx(7, :) = RLG.signals.values(:);
maxx(8, :) = RRF.signals.values(:);
maxx(11, :) = RTA.signals.values(:);
maxx(12, :) = RVL.signals.values(:);
timeM = clock.signals.values(:);

%%set up GUI
f = figure('Visible','on','Position',[360,250,650,285]);
set(gcf,'MenuBar','none','NumberTitle','Off','Name','EMG Feedback ');
%draw panel
hall = uipanel('Title','Controls for all Electrodes','FontSize',12,...
             'Position',[0  .65 .95 .3]);
hind = uipanel('Title','Analyze Individual Electrodes','FontSize',12,...
             'Position',[0  .35 .95 .2]);

hPRest = uicontrol('Style','pushbutton','String','Plot Resting Voltages',...
          'Position',[15,220,170,25],...
          'Callback',{@PRest_Callback, timeR, rest, ls});
hPMax = uicontrol('Style','pushbutton','String','Plot Maximum Voltages',...
          'Position',[15,190,170,25],...
          'Callback',{@PMax_Callback, timeM, maxx, ls});      
hFRest = uicontrol('Style','pushbutton','String','Plot Filtered Resting Voltages',...
          'Position',[215,220,170,25],...
          'Callback',{@FRest_Callback,timeR, rest, ls});
hFMax = uicontrol('Style','pushbutton','String','Plot Filtered Maximum Voltages',...
          'Position',[215,190,170,25],...
          'Callback',{@FMax_Callback, timeM, maxx, ls});  
hCRest = uicontrol('Style','pushbutton','String','Check Resting Voltages',...
          'Position',[415,220,170,25],...
          'Callback',{@CRest_Callback,timeR, rest, ls});
hCMax = uicontrol('Style','pushbutton','String','Check Maximum Voltages',...
          'Position',[415,190,170,25],...
          'Callback',{@CMax_Callback, rest, maxx, ls});       

hpopup2 = uicontrol('Style','popupmenu',...
          'String',{' Select Muscle Group'
          'Left Bicep Femoris';
    'Left Gluteus Maximus';
    'Right Bicep Femoris';
    'Right Gluteus Maximus';
    'Left Lateral Gastr.';
    'Left Rectus Femoris';
    'Right Lateral Gastr.';
    'Right Rectus Femoris';
    'Left Tibialis Anterior';
    'Left Vastus Lateralis';
    'Right Tibialis Anterior';
    'Right Vastus Lateralis'},...
          'Position',[50,80,130,50],...
          'Callback',{@partial_level}); 
      
 hbutton1 = uicontrol('Style','pushbutton','String','Analyze this Electrode',...
          'Position',[200,110,130,25],...
          'Callback',{@bElectrode, timeR, timeM, rest, maxx, ls});

end


   
function PRest_Callback(src,eventdata, time, restt, ls)
        figure()
        for i = 1:12
        subplot (3,4,i)
        plot(time, restt(i,:))
        xlabel('time')
        ylabel('voltage')
        title(ls(i))
        end
end

function FRest_Callback(src,eventdata, time, restt, ls)
        
        figure()
        window = 15;
        h = ones(window,1)/window;
        for i = 1:12
        filtered_rest = filter(h,1,restt(i,:));
        subplot (3,4,i)
        plot(time, filtered_rest)
        xlabel('time')
        ylabel('filtered voltage')
        title(ls(i))
        end
        
      
end

function FMax_Callback(src,eventdata, time, maxxx, ls)
        figure()
        window = 15;
        h = ones(window,1)/window;
        for i = 1:12
        filtered_max = filter(h,1,maxxx(i,:));
        subplot (3,4,i)
        plot(time, filtered_max)
        xlabel('time')
        ylabel('filtered voltage')
        title(ls(i))
        end
        
      
end



function PMax_Callback(src,eventdata, time, maxxx, ls)
        figure()
        for i = 1:12
        subplot (3,4,i)
        plot(time, maxxx(i,:))
        xlabel('time')
        ylabel('voltage')
        title(ls(i))
        end

end

function CRest_Callback(src,eventdata, time, restt, ls)
    c = 0;
         for i = 1:12
    m = mean(abs(restt(i,:)));
    if (m <.001)
        disp('mean signal for ', ls(i), ' is not between 1 and 3.5 mV') 
        c = c+1;
    elseif (m >.0035)
        disp(['mean signal for ', ls(i), ' is not between 1 and 3.5 mV'])
        c = c+1; 
    end
         end
    if(c==0)
        disp('The rest data all falls within the acceptable range')
    end
end

function CMax_Callback(src,eventdata, restt, maxxx, ls)
    %first, filter all of the data;
    %to check to see if a muscle is on, find the maximum and the standard
    %deviation of the resting one.  Then make sure that the average is at
    %least 5 standard deviations higher than the average of the resting
    restt = abs(restt);
    maxxx = abs(maxxx);
    window = 15;
    h = ones(window,1)/window;
    
        for i = 1:12
        %filter the resting ones too
        filtered_rest = filter(h,1,restt(i,:));
        resting_average = mean(abs(filtered_rest));
        resting_sd = std(abs(filtered_rest));
        filtered_max = filter(h,1,maxxx(i,:));
        max_average = std(abs(filtered_max));
        if (max_average > 3*resting_sd);
            disp ([ls(i), ' is ON'])
        else
            disp([ls(i), ' is OFF'])
        end

        end

    
end

    function partial_level(source,eventdata)
    
    
    
         str = get(source, 'String');
         val = get(source,'Value');
         data = get(gcf,'UserData');
         fig = gcf;
	info = get(fig,'UserData');
	info.g = val;
	set(fig,'UserData',info)   ; 
    
    end
    
    function bElectrode(source,eventdata, timeR, timeM, restt, maxxx, ls)
         %first figure out what electrode to look at
         %in 2 graphs, plot the resting, and the maximum values
         %to matlab screen: 
         fig=gcf;
         info = get(fig,'UserData');
         n = info.g - 1;
         figure()
         subplot(2,2,1)
         plot(timeR, restt(n,:))
         title('Resting Voltage - unfiltered')
         xlabel ('Time')
         ylabel ('Voltage')
         subplot(2,2,2)
         plot(timeM, maxxx(n,:))
         title('Maximum Voltage - unfiltered')
         xlabel ('Time')
         ylabel ('Voltage')
         
         
         %now filter the rest data
         window = 15;
         h = ones(window,1)/window;
         filtered_rest = filter(h,1,restt(n,:));
         resting_average = mean(abs(filtered_rest));
         resting_sd = std(abs(filtered_rest));
         filtered_max = filter(h,1,maxxx(n,:));
         max_average = std(abs(filtered_max));
         
         subplot(2,2,3)
         plot(timeR, filtered_rest);
         title('Resting Voltage - Filtered')
         xlabel ('Time')
         ylabel ('Voltage')
         
          subplot(2,2,4)
         plot(timeM, filtered_max);
         title('Maximum Voltage - Filtered')
         xlabel ('Time')
         ylabel ('Voltage')
       
         
        restt = abs(restt);
         maxxx = abs(maxxx); 
         
        filtered_rest = filter(h,1,restt(n,:));
        resting_average = mean(abs(filtered_rest));
        resting_sd = std(abs(filtered_rest));
        filtered_max = filter(h,1,maxxx(n,:));
        max_average = std(abs(filtered_max));
        if (max_average > 3*resting_sd);
            disp ([ls(n), ' is ON'])
        else
            disp([ls(n), ' is OFF'])
        end

         
        
    end
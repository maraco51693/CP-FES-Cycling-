% mexMiniLAB: Used to run the mex compilation commands
% and save having to type it all in lots of times :-)

%selection = [1 2 3 4 5];
selection = [1];

for i = 1 : length(selection)
	switch selection(i)
		
	case 1 % miniLAB_AIn_sFcn.c
		disp(['Mexing file miniLAB_AIn_sFcn.c ...']);
		mex -I'c:\MCC\C' miniLAB_AIn_sFcn.c ...
		'c:\MCC\C\cbw32.lib';
      
	otherwise
		disp(['Warning (', mfilename, '): Unknown mex file selection ', num2str(selection(i))]);
		
	end
	
	disp(['mex Complete.']); disp([' ']);
end

disp(['done!']);

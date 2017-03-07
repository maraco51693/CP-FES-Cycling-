
t = tout;
sT = 0.05;
nps = 450;

dt = [0 : sT/nps : sT-(sT/nps)];

t2 = []; d1 = []; d2 = []; d3 = []; d4 = [];
for i = 1 : length(t)
	t2(end+1:end+length(dt),1) = (t(i)+dt)';
	d1(end+1:end+length(dt),1) = chan1data(i,:)';
	d2(end+1:end+length(dt),1) = chan2data(i,:)';
	d3(end+1:end+length(dt),1) = chan3data(i,:)';
	d4(end+1:end+length(dt),1) = chan4data(i,:)';
end

hold on;
%plot(t+(1*sT/nps), d1(:,2), 'r');
%plot(t+(4*sT/nps), d1(:,5), 'm');
plot(t2, [d1, d2, d3, d4]);



clear all
%===============================================================================================================
%changeable variables
%===============================================================================================================
fishID='30';
trialID='T1';

%---------------------------------------------------------------------------------------------------------------
%Video file information
[file path]=uigetfile('title','Select a Video File');
FileName=fullfile(path, file);
m = VideoReader(FileName);
nFrames =m.NumberOfFrames;
vidHeight = m.Height;
vidWidth = m.Width;
%---------------------------------------------------------------------------------------------------------------
iptsetpref('ImshowBorder','loose');
answer = inputdlg({'Start Minutes','Start Seconds','End Minutes','End Seconds'},'Start Time',[1 45],{'0','0','0','0'});
ans=inputdlg({'Frame rate'},'Frame Rate'); 
frame_step=str2num(ans{1});
%frame_step=10;
%how many frames to skip when averaging to get the background to then subtract
back_frame_step=200;
%which frame to start at
start_frame=1; 
%start_frame=round((str2num(answer{1})*60+str2num(answer{2}))*60);
%which frame to stop at
stop_frame=nFrames;
%stop_frame=round((str2num(answer{3})*60+str2num(answer{4}))*60); %(last frame of video is nFrames)
%---------------------------------------------------------------------------------------------------------------
%sets threshold level when converting to BW (background ends up black, fish ends up white)
n_thresh=0.1;
%---------------------------------------------------------------------------------------------------------------
%set the minimum pixel grouping, which will combine into 1 group if fish is
%blotchy
%fish_area=1000;
fish_area=20;
%---------------------------------------------------------------------------------------------------------------
% Preallocate movie structure.
mov(start_frame:nFrames) = struct('cdata', zeros(vidHeight,vidWidth, 3,'uint8'),'colormap', []);

figure(1)
hold off
subplot(111)
mov(start_frame).cdata = read(m,start_frame);
imshow(mov(start_frame).cdata)

title('Choose focal area (Top left 1st click, Bottom right second)')
[TL_coord BR_coord] = ginput(2);
crop_left=round(TL_coord(1));
crop_right=round(TL_coord(2));
crop_top=round(BR_coord(1));
crop_bottom=round(BR_coord(2));

imshow(mov(start_frame).cdata(crop_top:crop_bottom,crop_left:crop_right,:));
title('Choose middle of focal area (1st click =start point, 2nd click=end point')
[x_coord y_coord] = ginput(1); 
MidPt1=[x_coord y_coord];
[x_coord y_coord] = ginput(1); 
MidPt2=[x_coord y_coord];

%=========================================================================
%use average of full movie as background
%=========================================================================
col=3;%full colour(1:3) or one of rgb ([1 2 3])
back = mov(start_frame).cdata(crop_top:crop_bottom,crop_left:crop_right,col);
%back = mov(start_frame).cdata(:,:,col);
back=zeros(length(crop_top:crop_bottom),length(crop_left:crop_right),length(col),'double');

for k = 1:back_frame_step:nFrames % for whole video: k = start_frame:back_frame_step:nFrames
    mov(k).cdata = read(m,k);
    d=double(mov(k).cdata(crop_top:crop_bottom,crop_left:crop_right,col))/255; %convert to double
    back=back+d;
    clear mov d
end
back=uint8(round(back/length(1:back_frame_step:nFrames)*255)); %convert back to uint8

%=========================================================================
%start stepping through video and finding fish
%=========================================================================

for k =start_frame:frame_step:stop_frame
    [k/stop_frame*100];
    mov(k).cdata = read(m,k);
    tmp=mov(k).cdata(crop_top:crop_bottom,crop_left:crop_right,col);
    d=imabsdiff(back,tmp);
    d=medfilt2(d,[7 7]);
    bw=(d>=n_thresh*255);
    bw=bwareaopen(bw,250);
    bw=bwareaopen(bw,fish_area);
    L=bwlabel(bw);
    s=regionprops(L,'area','centroid');
    area_vector=[s.Area];
    [tmp,idx]=max(area_vector);
   
    figure(1)
    subplot(211)
    imshow(mov(k).cdata(crop_top:crop_bottom,crop_left:crop_right,:));
    line([MidPt1(1),MidPt2(1)],[MidPt1(2),MidPt2(2)], 'Color', 'b')
    subplot(212)
    hold off
    imshow(bw)
    line([MidPt1(1),MidPt2(1)],[MidPt1(2),MidPt2(2)], 'Color', 'y')
    hold on

    if isempty(idx)
        position(k,:,:)=[NaN NaN];
    else
        figure(1)
        subplot(212)
        plot(s(idx).Centroid(1),s(idx).Centroid(2),'b.')
        hold on
        position(k,:,:)=[s(idx).Centroid(1) s(idx).Centroid(2)];
    end
    
    
    clear mov tmp d bw
end

%=========================================================================
%Plotting position
%=========================================================================

NumFrames=numel(position(position>0));
NumFramesOnSide2=numel(position(position>MidPt1(1)));
PercentOfFramesOnSide2=NumFramesOnSide2/NumFrames*100


figure(11)
title('Fish Trajectory')
mov(start_frame).cdata = read(m,start_frame);
imshow(mov(start_frame).cdata(crop_top:crop_bottom,crop_left:crop_right,:))
hold on
line([MidPt1(1),MidPt2(1)],[MidPt1(2),MidPt2(2)], 'Color', 'r')
plot(MidPt1(1),MidPt1(2), 'dc')
hold on
plot(position(start_frame:frame_step:stop_frame,1,1),position(start_frame:frame_step:stop_frame,1,2),'b-o','LineWidth',1)
hold off

clear m
%==================================================================================================
%save txt file 
%==================================================================================================
% tmp1= cell(length(nonzeros(position(:,1,1))), 1);
% tmp1(:)={fishID};
% tmp2= cell(length(nonzeros(position(:,1,1))), 1);
% tmp2(:)={trialID};
% %time_stamp=time(start_frame:frame_step:stop_frame)';
% tmp3=[tmp1(:),tmp2(:),num2cell(time_stamp),num2cell(nonzeros(position(:,1,1))),num2cell(nonzeros(position(:,1,2)))]';
% fileID = fopen(['FISH_', fishID, '_TRIAL_', trialID,'.txt'],'w');
% fprintf(fileID,'%8s\t%8s\t%8s\t%8s\t%8s\n', 'FISH_ID','Trial_ID','Time(s)','X_coord','Y_coord');
% fprintf(fileID,'%8s\t%8s\t%8f\t%8.4f\t%8.4f\n',tmp3{:});
% fclose(fileID);
%==================================================================================================
%save mat file
%==================================================================================================
% save([fishID '_' trialID])
% figure(11)
% savefig([fishID '_' trialID])
% clear  all
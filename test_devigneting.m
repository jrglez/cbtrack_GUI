function test_devigneting(V_coeff)
% Apply devignetting to a video and visualize the results

% Load video 
filetypes={  '*.ufmf','MicroFlyMovieFormat (*.ufmf)'; ...
  '*.fmf','FlyMovieFormat (*.fmf)'; ...
  '*.sbfmf','StaticBackgroundFMF (*.sbfmf)'; ...
  '*.avi','AVI (*.avi)'
  '*.mp4','MP4 (*.mp4)'
  '*.mov','MOV (*.mov)'
  '*.mmf','MMF (*.mmf)'
  '*.*','*.*'};
[moviefile,folder]=open_files2(filetypes);
moviefile=fullfile(folder,moviefile{1});
[readframe,n_frames,fid,~] = get_readframe_fcn(moviefile);

I=readframe(1);
nr=size(I,1);
nc=size(I,2);

% Vigneting function
[X,Y]=meshgrid(1:nc,1:nr);
V_fit=ones(size(X)).*V_coeff(1)+X.*V_coeff(2)+Y.*V_coeff(3)+X.^2.*V_coeff(4)+X.*Y.*V_coeff(5)+Y.^2.*V_coeff(6)+X.^3.*V_coeff(7)+X.^2.*Y.*V_coeff(8)+X.*Y.^2.*V_coeff(9)+Y.^3.*V_coeff(10);
f1=figure;
pos1=get(f1,'Position');
pos1(3)=pos1(3)*2;
set(f1,'Position',pos1);

% Devignet some frames
n_frames_sample=100;
frames_sample=round(linspace(1,n_frames,n_frames_sample));
for i=1:n_frames_sample
    j=frames_sample(i);
    I=readframe(j);
    O=I./V_fit;
    subplot(1,2,1)
    imagesc(I,[0 255])
    axis('image')
    subplot(1,2,2)
    imagesc(O,[0 255])
    axis('image')
    drawnow
end

if fid>1
    fclose(fid);
end





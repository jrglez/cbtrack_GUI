function V_coeff=compute_vignetting
% Compute the vignetting function such as I=O*V, where I is the recorded
% image, O is the original image and V is the vignetting function. 
% Since O is unknown, assume that it has uniform intensity. The inteisty is
% computed as the average inside a disk centered around the point of
% maximum intenisty of I.
% The vignetting function is computed for n_frames_sample frames the
% average is fitted to a 2D polynomial of order 3. A are the 10
% coefficients of such fit.

% Load video without flies
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

[X,Y]=meshgrid(1:nc,1:nr);

% Create filter
disk_filt=round(((nr+nc)/2)/100); % Filter window size depend on the size of the imate
f=fspecial('disk',disk_filt);

radius=round(((nr+nc)/2)/10); % Radius of the region of uniform intensity

f1=figure;
pos1=get(f1,'Position');
pos1(3)=pos1(3)*3;
set(f1,'Position',pos1);

n_frames_sample=100;
frames_sample=round(linspace(1,n_frames,n_frames_sample));
V=nan(nr,nc,n_frames_sample); % Vitneting function
for i=1:n_frames_sample
    j=frames_sample(i);
    I=readframe(j);
    I=imfilter(I,f);
    max_int=max(I(:));
    [center(:,2),center(:,1)]=find(I==max_int); % Center of the radius of uniform inteisty
    center=mean(center,1);
    is_in=((X-center(1)).^2+(Y-center(2)).^2)<radius^2; % Points inside the disk
    I_in=I(is_in); 
    O=mean(I_in)*ones(size(I)); % Estimated original image
    V(:,:,i)=I./O; 
    
    % Plot
    subplot(1,3,1);
    imagesc(I,[0 255])
    hold on
    plot(center(1),center(2),'kx')
    is_edge=((X-center(1)).^2+(Y-center(2)).^2)==radius^2; % Points in the edge of the disk
    plot(X(is_edge),Y(is_edge),'.k')
    hold off
    subplot(1,3,2);
    imagesc(O,[0 255])
    subplot(1,3,3);
    imagesc(V(:,:,i))
    drawnow
end

M_V=mean(V,3); % Average devigneting function
x=reshape(X,[],1);
y=reshape(Y,[],1);
m_V=reshape(M_V,[],1);
% Fit vignetting function to a 2D polynomial
V_coeff=[ones(size(x)) x y x.^2 x.*y y.^2 x.^3 x.^2.*y x.*y.^2 y.^3]\m_V;

% Plot results
V_fit=ones(size(X)).*V_coeff(1)+X.*V_coeff(2)+Y.*V_coeff(3)+X.^2.*V_coeff(4)+X.*Y.*V_coeff(5)+Y.^2.*V_coeff(6)+X.^3.*V_coeff(7)+X.^2.*Y.*V_coeff(8)+X.*Y.^2.*V_coeff(9)+Y.^3.*V_coeff(10);
f2=figure;
pos2=get(f2,'Position');
pos2(3)=pos2(3)*2;
set(f2,'Position',pos2);
subplot(1,2,1)
contourf(V_fit)
axis('ij','image')
subplot(1,2,2)
surf(V_fit,'LineStyle','None')

if fid>1
    fclose(fid);
end
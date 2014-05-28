function headerinfo=all_read_header(filename)
[~,ext] = splitext(filename);
if strcmpi(ext,'.fmf'),
    [header_size,version,nr,nc,bytes_per_chunk,nframes,data_format] = fmf_read_header(filename);
    headerinfo = struct('header_size',header_size,'version',version,'nr',nr,'nc',nc,...
    'bytes_per_chunk',bytes_per_chunk,'nframes',nframes,'data_format',data_format,'type','fmf');    
    headerinfo.fid = fopen(filename);
elseif strcmpi(ext,'.sbfmf'),
  [ nr,nc,nframes,bgcenter,bgstd,frame2file] = sbfmf_read_header(filename);
    headerinfo = struct('nr',nr,'nc',nc,'nframes',nframes,'bgcenter',bgcenter,...
    'bgstd',bgstd,'frame2file',frame2file,'type','sbfmf');
    headerinfo.fid = fopen(filename);
elseif strcmpi(ext,'.ufmf'),
    headerinfo = ufmf_read_header(filename);
elseif strcmpi(ext,'.mmf'),
    headerinfo = mmf_read_header(filename);
else
    readerobj = VideoReader(filename);
    headerinfo = get(readerobj);
    headerinfo.type = 'avi';
    headerinfo.nr = headerinfo.Height;
    headerinfo.nc = headerinfo.Width;
    headerinfo.nframes = headerinfo.NumberOfFrames;
    headerinfo.fid = 0;
end

  
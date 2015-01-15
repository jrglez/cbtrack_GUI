function eqim=eq_image(im)
a=double(min(im(:)));
b=double(max(im(:)));
eqim=255*(double(im)-a)/(b-a);
if isa(im,'uint8')
    eqim=uint8(eqim);
elseif isa(im,'int8')
    eqim=int8(eqim);
elseif isa(im,'uint16')
    eqim=uint16(eqim);
elseif isa(im,'int16')
    eqim=int16(eqim);
elseif isa(im,'uint32')
    eqim=uint32(eqim);
elseif isa(im,'int32')
    eqim=int32(eqim);
elseif isa(im,'uint64')
    eqim=uint64(eqim);
elseif isa(im,'int64')
    eqim=int64(eqim);
end
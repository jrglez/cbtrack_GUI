function A_any=any_class(A,new_class)
switch new_class
    case 'double'
        A_any=double(A);
    case 'single'
        A_any=single(A);
    case 'uint8'
        A_any=uint8(A);
    case 'int8'
        A_any=int8(A);
    case 'uint16'
        A_any=uint16(A);
    case 'int16'
        A_any=int16(A);
    case 'uint32'
        A_any=uint32(A);
    case 'int32'
        A_any=int32(A);
    case 'uint64'
        A_any=uint64(A);
    case 'int64'
        A_any=int64(A);
    case 'logical'
        A_any=logical(A);
end
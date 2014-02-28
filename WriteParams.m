function WriteParams
out=getappdata(0,'out');
cbparams=getappdata(0,'cbparams');
params_file=fullfile(out.folder,'out_params.xml');
if exist(params_file,'file')
    delete(params_file);
end    
fid=fopen(params_file,'a');

fprintf(fid,'<?xml version="1.0" encoding="utf-8"?>\n\n');
fprintf(fid,'<params>\n\n');

fields1=fieldnames(cbparams);
for f1=1:length(fields1)
    fprintf(fid,'<%s',fields1{f1});    
    fields2=fieldnames(cbparams.(fields1{f1}));
    has_struct=false;
    for f2=1:length(fields2)
        if isstruct(cbparams.(fields1{f1}).(fields2{f2}))
            has_struct=true;
            fprintf(fid,'>\n\t<%s',fields2{f2});
            fields3=fieldnames(cbparams.(fields1{f1}).(fields2{f2}));
            for f3=1:length(fields3)
                fprintf(fid,'\n\t\t%s=',fields3{f3});
                variable=cbparams.(fields1{f1}).(fields2{f2}).(fields3{f3});
                if isempty(variable)
                    v_class='empty';
                else
                    v_class=class(variable);
                end
                switch v_class
                    case 'char'
                        fprintf(fid,'"%s"',variable);
                    case 'double'
                        fprintf(fid,'"');
                        if numel(variable)>0
                            for i=1:numel(variable)-1
                                fprintf(fid,'%g,',variable(i));
                            end
                        end
                        fprintf(fid,'%g',variable(end));
                        fprintf(fid,'"');
                    case 'cell'
                        fprintf(fid,'"');
                        if numel(variable)>0
                            for i=1:numel(variable)-1
                                if ischar(variable{i})
                                    fprintf(fid,'%s,',variable{i});
                                elseif isnum(variable{i})
                                    fprintf(fid,'%g,',variable{i});
                                end
                            end
                        end                    
                        if ischar(variable{i})
                            fprintf(fid,'%s',variable{end});
                        elseif isnum(variable{i})
                            fprintf(fid,'%g',variable{end});
                        end
                        fprintf(fid,'"');
                    case 'empty'
                        fprintf(fid,'""');
                    case 'logical'
                        if variable
                            variable=1;
                        else
                            variable=0;
                        end
                        fprintf(fid,'%g',variable);
                end
                
            end
            fprintf(fid,'/');
        else
            if f2>1 && isstruct(cbparams.(fields1{f1}).(fields2{f2-1}))
                fprintf(fid,'>');
            end
            fprintf(fid,'\n\t%s=',fields2{f2});
            variable=cbparams.(fields1{f1}).(fields2{f2});
            if isempty(variable)
                v_class='empty';
            else
                v_class=class(variable);
            end
            switch v_class
                case 'char'
                    fprintf(fid,'"%s"',variable);
                case 'double'
                    fprintf(fid,'"');
                    if numel(variable)>0
                        for i=1:numel(variable)-1
                            fprintf(fid,'%g,',variable(i));
                        end
                    end
                    fprintf(fid,'%g',variable(end));
                    fprintf(fid,'"');
                case 'cell'
                    fprintf(fid,'"');
                    if numel(variable)>0
                        for i=1:numel(variable)-1
                            if ischar(variable{i})
                                fprintf(fid,'%s,',variable{i});
                            elseif isnum(variable{i})
                                fprintf(fid,'%g,',variable{i});
                            end
                        end
                    end                    
                    if ischar(variable{i})
                        fprintf(fid,'%s',variable{end});
                    elseif isnum(variable{i})
                        fprintf(fid,'%g',variable{end});
                    end
                    fprintf(fid,'"');
                case 'empty'
                    fprintf(fid,'""');
                case 'logical'
                if variable
                    variable=1;
                else
                    variable=0;
                end
                fprintf(fid,'"%g"',variable);
            end            
        end        
    end
    if has_struct
        fprintf(fid,'>\n</%s>\n\n',fields1{f1});
    else
        fprintf(fid,'/>\n\n');
    end
end

fprintf(fid,'</params>');

fclose(fid);
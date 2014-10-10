function trx2csv(fullfiletxt)
[~,~,expdirs] = ReadGroupedExperimentList_queue(fullfiletxt);

for i=1:numel(expdirs)
    try
        trxfile=fullfile(expdirs{i},'registered_trx.mat');
        load(trxfile);    
        data=[trx(1).timestamps';trx(1).a;trx(1).b;trx(1).theta;trx(1).wing_anglel;trx(1).wing_angler];

        csvfile=fullfile(expdirs{i},'registered_trx.csv');
        if exist(csvfile,'file')
            delete(csvfile)
        end
        fid=fopen(csvfile,'a');
        format=[repmat('%.16g, ',1,6),'\n'];
        fprintf(fid,format,data);
        fclose(fid);
    catch ME
        sprintf('Could not create csv for %s: %s',expdirs{i},ME.message)
    end
end
    
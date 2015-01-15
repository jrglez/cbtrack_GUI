[file,folder]=open_files;
bagfile = fullfile(folder,file{1});
bag = ros.Bag.load(bagfile);

topics = {'/flymad/raw_2d_positions','/flymad/laser_head_delta','/targeter/targeted','/flymad_micro/position','/flymad_micro/position_echo'};
msgs_2dpos = bag.readAll(topics{1});
msgs_2dpos = [msgs_2dpos{:}];
msgs_2dpos = [msgs_2dpos.points];
pos2d = msgs_2dpos(1:2,:);

[msgs_laser,meta_laser] = bag.readAll(topics{2});
msgs_laser = [msgs_laser{:}];
head = [msgs_laser.head_x;msgs_laser.head_y];
body = [msgs_laser.body_x;msgs_laser.body_y];

msgs_target = bag.readAll(topics{3});
msgs_target = [msgs_target{:}];
fly = [msgs_target.fly_x;msgs_target.fly_y];



msgs_pos = bag.readAll(topics{4});
pos = cell2mat(msgs_pos);

msgs_posecho = bag.readAll(topics{5});
posecho = cell2mat(msgs_posecho);

savefile = fullfile(folder,'bag_position.mat');
save(savefile,'pos2d')
% StartUp script
% Run this script only once to setup correct path

if( isempty(strfind(path,pwd)) )
    path(pwd,path);
    path(strcat(pwd,'\samri_data'),path);
    disp('Path is set.');
end
function [U,V,GDOP,gridd,stime] = get_hfr_from_thredds(t_min,t_max,b_lon,b_lat) %,res)
% [U,V,GDOP,gridd,mtime] = get_hfr_from_thredds(t_min,t_max,b_lon,b_lat)
% 
% This function harvests hourly HFR data from the OPENDAP sever located here:
% http://hfrnet.ucsd.edu/thredds/HFRADAR_USWC_hourly_RTV.html/
% and outputs velocity components, error estimates, grid point locations, and
% time in a format identical to that provided by get_total_data.m 
% (except for the addition of GDOP)
%
% The INPUT arguments describe the temporal and spatial range of data to be output.
% (see test code below)
%
% 't_min' and 't_max' specify the time range of interest (UTC)
% '01-Oct-2011 00:00:00' to present - ~3hrs
%     
% 'b_lon' and 'b_lat' (two values each) provide the boundaries of a rectangular box
% containing the desired HFR grid points
% (max lon ranges are -130.4 to-115.8 W, and lat ranges 30.25 to 50.0 N)
%
% The OUTPUT variables are formatted identically to those we're used to from
% get_total_data.m.  
%
% U (m/s), easterly, toward east positive (structured [grid locations,times])
% V (m/s), northerly, toward north positive 
%
% 'GDOP' = Geometric Dilution Of Precision
% Here's an explanation from the web site:
% The longitudinal dilution of precision (DOPx,y) represents the
% contribution of the radars' configuration geometry to
% uncertainty in the eastward velocity estimate (u,v). DOPx,y is a
% direct multiplier of the standard error in obtaining the
% standard deviation for the eastward velocity estimate from the
% least squares best fit. DOPx and DOPy are commonly used to
% obtain the geometric dilution of precision
% (GDOP = sqrt(DOPx^2 + DOPy^2)), a useful metric for filtering
% errant velocities due to poor geometry.
% 
% 'gridd' is [longitude,latitude] for each output grid point
%
% 'mtime' = time (UTC)
%

% Brian Emery, Chris Gotschalk and Tom Cook
%
% Version '31-Jul-2019 16:17:38'

% TODO
% ... output a TUV also
% ... add functionality for other URL's:
% 'res' is a string argument that allows you to specify the output resolution. 
% It looks like there is pretty good spatial coverage for the 2km and 6km grid 
% spacings.  500m and 1km are available only in a few spots I've found so far.
% 

% works with 2017a, 2019a, ... not 2015a

% check for test case
if strcmp('--t',t_min), test_case, return, end


% define the url 
% use ncdisp(url) to get info about how the data is structured
url = 'http://hfrnet-tds.ucsd.edu/thredds/dodsC/HFR/USWC/2km/hourly/RTV/HFRADAR_US_West_Coast_2km_Resolution_Hourly_RTV_best.ncd';

T = readUVfromTDS(url,t_min,t_max,b_lon,b_lat);



% RESHAPE OUTPUTS 

% get the gridd
[lon,lat] = meshgrid(T.lon,T.lat);
gridd = double([lon(:) lat(:)]); % stack columns

% time output
stime = T.stime;

% get sizes
[m,n,p] = size(T.u);

% reshape and double, m/s, permute transposes matrix at each time 
U = double(reshape( permute(T.u,[2 1 3]) ,m*n,p));
V = double(reshape( permute(T.v,[2 1 3]) ,m*n,p));

% unitless dilution of precision
DOPx = double(reshape( permute(T.dopx,[2 1 3]),m*n,p));
DOPy = double(reshape( permute(T.dopy,[2 1 3]),m*n,p));

% get GDOP 
GDOP = sqrt(DOPx.^2 + DOPy.^2);






end


function test_case
% uncomment for testing ------------------------------

%provide time and space boundaries
t_min = datenum(2012,9,11,0,0,0);
t_max = datenum(2012,9,11,2,0,0); %2

b_lon = [-120.6 -119.2];
b_lat = [34 34.6];


[U,V,GDOP,gridd,mtime] = get_hfr_from_thredds(t_min,t_max,b_lon,b_lat);

keyboard

sbc

plotrad2tot_simple(U( GDOP(:,1)<1.5 ,1).*100,V( GDOP(:,1)<1.5 ,1).*100,gridd( GDOP(:,1)<1.5, :))

axis([-120.5500 -119.100   33.9000   34.5000])



end


function T = readUVfromTDS(url,t_min,t_max,b_lon,b_lat)
% script to read RTV data from HFRnet TDS 
% data url from OPeNDap page
%
% 
% url='http://hfrnet-tds.ucsd.edu/thredds/dodsC/HFR/USEGC/2km/hourly/RTV/HFRADAR_US_East_and_Gulf_Coast_2km_Resolution_Hourly_RTV_best.ncd';
% url='http://hfrnet-tds.ucsd.edu/thredds/dodsC/HFR/USWC/6km/hourly/RTV/HFRADAR_US_West_Coast_6km_Resolution_Hourly_RTV_best.ncd';%
% url='http://tds-backup/thredds/dodsC/HFR/USWC/6km/hourly/RTV/HFRADAR_US_West_Coast_6km_Resolution_Hourly_RTV_best.ncd';
%
% * NOTE * 
% when changing the URL, check the time reference with this:
% ncdisp(url,'time_offset')

% based on the mfile by Tom Cook, UCSD


%url='http://hfrnet-tds.ucsd.edu/thredds/dodsC/USWC-month-LTA-6km.nc';
% LTA have different time base - seconds from  1,1,1970

% % uncomment to display info on all netcdf variables
% ncdisp(url)

% % uncomment to display info on specific netcdf variable
%ncdisp(url,'time')

% retrieve lat and lon variables
lat = ncread(url,'lat');
lon = ncread(url,'lon');

% handle time variable reference time since it appears to change with hfr
% file updates
%
S = ncinfo(url,'time_offset');
junk = S.Attributes(4).Value;
reftime = datenum(str2num(junk(13:16)),str2num(junk(18:19)),str2num(junk(21:22)));

stime = ncread(url,'time')/24 + reftime;

% % view date string of start and end time
% datestr(double(stime([1 end])))

% get the latest realtime vector map
lon_j = find(lon >= b_lon(1) & lon <= b_lon(2));
lat_j = find(lat >= b_lat(1) & lat <= b_lat(2));

% read in 3hr old data values
% typically most recent data is sparse as it takes a few hours
% for data to be reported from all stations
time_j = find(stime >= t_min & stime <= t_max);

% index inputs ar the starting indicies and the count, "the number of 
% elements to read along the corresponding dimensions"
% u          Size:       700x1099x68707
%            Dimensions: lon,lat,time
T.u = ncread(url, 'u', [lon_j(1) lat_j(1) time_j(1)], [length(lon_j) length(lat_j) length(time_j)]);
T.v = ncread(url, 'v', [lon_j(1) lat_j(1) time_j(1)], [length(lon_j) length(lat_j) length(time_j)]);

T.lon = lon(lon_j);
T.lat = lat(lat_j);

T.stime = stime(time_j);

% DOPx and DOPy are commonly used to
% obtain the geometric dilution of precision
% (GDOP = sqrt(DOPx^2 + DOPy^2)), a useful metric for filtering
% errant velocities due to poor geometry.'
T.dopx = ncread(url, 'dopx', [lon_j(1) lat_j(1) time_j(1)], [length(lon_j) length(lat_j) length(time_j)]);
T.dopy = ncread(url, 'dopy', [lon_j(1) lat_j(1) time_j(1)], [length(lon_j) length(lat_j) length(time_j)]);


% 
% % %u=ncread(url, 'u_mean', [lon_j(1) lat_j(1) mytime], [lon_j(end)-lon_j(1)+1 lat_j(end)-lat_j(1)+1 1]);
% %v=ncread(url, 'v_mean', [lon_j(1) lat_j(1) mytime], [lon_j(end)-lon_j(1)+1 lat_j(end)-lat_j(1)+1 1]);
% 
% 
% [LN,LT]=meshgrid(lon(lon_j),lat(lat_j));
% quiver(LN,LT,u',v');



end
# HFR Thredds Data Reader

 This function harvests hourly HFR data from the OPENDAP sever located here:
 https://hfrnet-tds.ucsd.edu/thredds/catalog.html
 and outputs velocity components, error estimates, grid point locations, and
 time in a format identical to that provided by get_total_data.m 
 (except for the addition of GDOP)

 The INPUT arguments describe the temporal and spatial range of data to be output.
 (see test code below)

 't_min' and 't_max' specify the time range of interest (UTC)
 '01-Oct-2011 00:00:00' to present - ~3hrs
     
 'b_lon' and 'b_lat' (two values each) provide the boundaries of a rectangular box
 containing the desired HFR grid points
 (max lon ranges are -130.4 to-115.8 W, and lat ranges 30.25 to 50.0 N)

 The OUTPUT variables are formatted like the fields of TUV structs from HFRprogs

Wrapper for Tom Cook's code, written by Brian Emery and Chris Gotschalk

## How it works
```
% Define a min and max time range
t_min = datenum(2012,9,11,0,0,0);
t_max = datenum(2012,9,11,2,0,0); %2

% Define a Longitude range and latitude range
b_lon = [-120.6 -119.2];
b_lat = [34 34.6];

% Get the data
[U,V,GDOP,gridd,mtime] = get_hfr_from_thredds(t_min,t_max,b_lon,b_lat);
```

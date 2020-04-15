# HFR Thredds Data Reader

 This function harvests hourly HFR data from the OPENDAP sever located here:
 http://hfrnet.ucsd.edu/thredds/HFRADAR_USWC_hourly_RTV.html/
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

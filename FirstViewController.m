//
//  FirstViewController.m
//  CityNamesJson
//
//  Created by Marijan Vukcevich on 3/2/15.
//  marijanv@yahoo.com  - 949-891-2644
//  Copyright (c) 2015 East Side Interactive, LLC by Marijan Vukcevich. All rights reserved.
//

#import "FirstViewController.h"
#import "MapViewController.h"


@interface FirstViewController ()

@end

@implementation FirstViewController

@synthesize locMgr;
@synthesize startingPoint;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.combinedJsonArrays = [NSMutableArray array];
    
    // Get path to documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // Path to save array data
    NSString* arrayPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"CombinedJsonArray.out"];
    self.combinedJsonArrays = [NSMutableArray arrayWithContentsOfFile:arrayPath];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    //Initialize CLLocation Manager so we can get location and calculate distance
    self.locMgr =[[CLLocationManager alloc] init];
    //  NSLog(@"self.locMgr: %@", self.locMgr);
    // set its delegate
    self.locMgr.delegate = self;
    self.startingPoint = [[CLLocation alloc] init]; //property that we store our current location
    
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locMgr respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        
        [self.locMgr requestWhenInUseAuthorization];
    }

    
   
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void) getStationsJsonData {
    
   
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"cities_with_states_json1" ofType:@"json"];
    
    NSString *myJSON = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    //NSLog(@"%@", myJSON);
    
    NSError *error =  nil;
    NSMutableDictionary *json1 = [NSJSONSerialization JSONObjectWithData:[myJSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    
   
    NSString *filePath2 = [[NSBundle mainBundle] pathForResource:@"cities_with_states_json2" ofType:@"json"];
    
    NSString *myJSON2 = [[NSString alloc] initWithContentsOfFile:filePath2 encoding:NSUTF8StringEncoding error:NULL];
    //NSLog(@"%@", myJSON);
    
    NSError *error2 =  nil;
    NSMutableDictionary *json2 = [NSJSONSerialization JSONObjectWithData:[myJSON2 dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error2];
    
    
     self.combinedJsonArrays = [[json2 valueForKeyPath:@"places"] mutableCopy];
    NSLog(@"dbg: self.combinedJsonArrays count: %lu", (unsigned long)[self.combinedJsonArrays count]);
    
    NSMutableArray *itemsFinal = [[json1 valueForKeyPath:@"places"] mutableCopy];
    
    [self.combinedJsonArrays addObjectsFromArray:itemsFinal];
    NSLog(@"dbg: self.combinedJsonArrays count(final): %lu", (unsigned long)[self.combinedJsonArrays count]);
    
    //Save the values to Documents Directory so we can use it later
    // Get path to documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // Path to save array data
    NSString* arrayPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"CombinedJsonArray.out"];
    // Write array
    [self.combinedJsonArrays writeToFile:arrayPath atomically:YES];
    
}

-(void) calculateDistanceForData {
    
    
    //Note: If it's null we can not get correct distance for stations latitude and longitude
    self.startingPoint = self.locMgr.location;
    NSLog(@"dbg -(check point -  self.startingPoint: %f : %f", self.startingPoint.coordinate.latitude, self.startingPoint.coordinate.longitude);
    
    //store the values in variables so we can reuse their values for calculation
    double latB = self.startingPoint.coordinate.latitude;
    double logB = self.startingPoint.coordinate.longitude;
    
    NSLog(@"latB: %f", latB);
    NSLog(@"logB: %f", logB);
    
    //storing are results
    self.dictAllCityNames = [NSMutableDictionary dictionary];
    self.cityNamesRecordsArray = [NSMutableArray array];
    
    for (NSDictionary *item in self.combinedJsonArrays) {
        
        NSMutableDictionary* d = [item objectForKey:@"coordinate"];
        
        //get latitude and longitude values for each station
        double latA = [[d objectForKey:@"latitude"] floatValue];
        double logA = [[d objectForKey:@"longitude"] floatValue];
        
        CLLocation *jsonStations = [[CLLocation alloc] initWithLatitude:latA longitude:logA];
        CLLocation *localStartingPoint = [[CLLocation alloc] initWithLatitude:latB longitude:logB];
        
        //1 Meter = 0.000621371192 Miles
        //1 Mile = 1609.344 Meters
        CLLocationDistance distanceInMeters = [localStartingPoint distanceFromLocation:jsonStations];
        //convert it to miles
        double miles = distanceInMeters / 1609.344;
        
        //create dictionary
        [self.dictAllCityNames setValue:[item objectForKey:@"cityname"] forKey:@"cityname"];
        [self.dictAllCityNames setValue:[item objectForKey:@"state"] forKey:@"state"];
        [self.dictAllCityNames setObject:d forKey:@"coordinate"]; //we need to added back, so we can use the values for MapKit
        [self.dictAllCityNames setValue:[NSNumber numberWithDouble:miles] forKey:@"miles"]; //we use nsnumber it will help us with sorting, string did not work
                                                                                           //add each dictionary to array
        [self.cityNamesRecordsArray addObject:[self.dictAllCityNames copy]];
        
        // NSLog(@"self.dictAllStations: %@", self.dictAllStations);
        
    }
    //Note: our newRecordsArray with stations and their distances in miles
    // NSLog(@"self.stationsRecordsArray: %@", self.stationsRecordsArray);
    
    //Sort Array by miles so we can display the closest station
    [self.cityNamesRecordsArray sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"miles" ascending:YES], nil]];
    
    //our sorted array as per distance
    NSLog(@"\n\n\ndbg:sorted(self.stationsRecordsArray): %@", self.cityNamesRecordsArray);
    
    //Save the values to Documents Directory so we can use it later
    // Get path to documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // Path to save array data
    NSString* arrayPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"CitiesRecordsArray.out"];
    // Write array
    [self.cityNamesRecordsArray writeToFile:arrayPath atomically:YES];
    
}

#pragma mark - 
#pragma mark - UITableView Delegates and Datasource
#pragma mark - 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.cityNamesRecordsArray count];
}

#pragma mark - UITableViewDataSource
// number of section(s), now I assume there is only 1 section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StationsCell"];
    
    NSLog(@"----self.stationsRecordsArray: %@", self.cityNamesRecordsArray);
   
    NSDictionary * d = [NSDictionary dictionary];
    if(self.cityNamesRecordsArray  == NULL) {
        d = [self.combinedJsonArrays objectAtIndex:[indexPath row]];
    } else {
        d = [self.cityNamesRecordsArray objectAtIndex:[indexPath row]];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", [d objectForKey:@"cityname"], [d objectForKey:@"state"]];
      cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
     double mileDistance = [[d objectForKey:@"miles"] doubleValue];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f mi", mileDistance ];

    
   return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showMapView"]) {
        NSLog(@"DEBUG");
        NSIndexPath *indexPath = [self.stationTableView indexPathForSelectedRow];
       
        
         NSDictionary * d = [self.cityNamesRecordsArray objectAtIndex:[indexPath row]];
        
        NSLog(@"dbg: d(selected): %@", d);
        //NSUInteger row		= [indexPath row];
        NSMutableDictionary* cor = [d objectForKey:@"coordinate"];
        NSString* latlongValue = [NSString stringWithFormat:@"%@ %@", [cor objectForKey:@"latitude"], [cor objectForKey:@"longitude"]];
        NSString *cityName = [d objectForKey:@"cityname"];
        NSString *stateName = [d objectForKey:@"state"];
        double dist = [[d objectForKey:@"miles"] doubleValue];
        NSString* distance = [NSString stringWithFormat:@"%.2f", dist];
        
        
        NSMutableArray* myArray		= [[NSMutableArray alloc] init];
        NSMutableArray* packArray	= [[NSMutableArray alloc] init];
        
        [packArray addObject:latlongValue];
        [packArray addObject:cityName];
        [packArray addObject:stateName];
        [packArray addObject:distance];
        [myArray addObject:packArray];
        
         MapViewController *myMap = segue.destinationViewController;
        NSLog(@"packArray: %@", packArray);
        myMap.myAddressArray = packArray;
        NSLog(@"dbg: myMap.myAddressArray: %@", myMap.myAddressArray);
       
    }
}

#pragma mark -
#pragma mark CLLocationManagerDelegate Methods
#pragma mark -
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    // NSLog(@"dbg -- didUpdateToLocation: %@", newLocation);
    //NSLog(@"dbg -- didUpdateToLocation: %@", oldLocation);
    
    if (self.startingPoint == nil)
        self.startingPoint = newLocation;
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSString *errorType = (error.code == kCLErrorDenied) ?
    @"Access Denied" : @"Unknown Error";
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Error getting Location"
                          message:errorType
                          delegate:nil
                          cancelButtonTitle:@"Okay"
                          otherButtonTitles:nil];
    [alert show];
      [self.locMgr stopUpdatingLocation];
}

#pragma mark - 
#pragma mark - Delegate CLLocationManager
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    NSLog(@"DEBUG_______Came here for this callback delegate");
    if (status == kCLAuthorizationStatusDenied) {
        //location denied, handle accordingly
        NSLog(@"01 - Came here for this callback delegate- clicked NO --");
        [self.stationTableView reloadData];
        [self.locMgr stopUpdatingLocation];
        UIAlertView*   alert = [[UIAlertView alloc] initWithTitle:@"App Permission Denied"
                                                          message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [alert show];
    }
    else if (status == kCLAuthorizationStatusAuthorizedAlways) {
        //hooray! begin startTracking
        NSLog(@"02- StatusAuthorizedAlways - this callback delegate");
        [self getStationsJsonData];
        [self.locMgr startUpdatingLocation];
        [self calculateDistanceForData];
        [self.stationTableView reloadData];
    } else if (status ==  kCLAuthorizationStatusAuthorizedWhenInUse) {
        NSLog(@"03- StatusAuthorizedWhenInUse - this callback delegate");
        [self getStationsJsonData];
        [self.locMgr startUpdatingLocation];
        [self calculateDistanceForData];
        [self.stationTableView reloadData];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

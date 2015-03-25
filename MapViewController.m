//
//  MapViewController.m
//  CityNamesJson
//
//  Created by Marijan Vukcevich on 3/5/15.
//  marijanv@yahoo.com  - 949-891-2644
//  Copyright (c) 2015 East Side Interactive, LLC by Marijan Vukcevich. All rights reserved.
//

#import "MapViewController.h"


#import "ESIAnnotation.h"

@interface MapViewController ()

@end

@implementation MapViewController

@synthesize myAddressArray;

-(void)showAddressInView:(CLLocationCoordinate2D)location
{
    NSLog(@"came here - or not");
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta  = 0.01;
    span.longitudeDelta = 0.01;
    
    region.span=span;
    region.center=location;
    
    if(self.addAnnotation != nil)
    {
        [self.mapView removeAnnotation:self.addAnnotation];
        self.addAnnotation = nil;
    }
    
     self.addAnnotation = [[ESIAnnotation alloc] init];
    self.addAnnotation.coordinate = location;
    [self.mapView addAnnotation:self.addAnnotation];
    [self.mapView setRegion:region animated:TRUE];
    [self.mapView regionThatFits:region];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.startingPoint = [[CLLocation alloc] init]; //property that we store our current location
    
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 500;
    
    [self.locationManager startUpdatingLocation];
    
    // self.mapView.showsUserLocation = YES;
    
    // [self showCurrentLocation];
    
    [self getStationLocaton];
    
   
}

- (void) showCurrentLocation {
    
    self.mapView.showsUserLocation = YES;
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta=0.001;
    span.longitudeDelta=0.001;
    
    CLLocationCoordinate2D location = [[[self.mapView userLocation] location] coordinate];
    
    //  NSLog(@"Location found from Map: %f %f",location.latitude,location.longitude);
    
    region.span=span;
    region.center=location;
    
    
    [self.mapView setRegion:region animated:TRUE];
    [self.mapView regionThatFits:region];
}

-(void) getStationLocaton {
  
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    CLLocationCoordinate2D coordinate;
    CLLocationCoordinate2D firstCoordinate;
    
    
    NSString* strLatLong = [self.myAddressArray objectAtIndex:0];
    NSString* strCity = [self.myAddressArray objectAtIndex:1];
    NSString* strState = [self.myAddressArray objectAtIndex:2];
    NSString* strDistance = [self.myAddressArray objectAtIndex:3];
    
    //    NSString* str0 = @"33.646556 -117.846949";
    //    NSString* str1 = @"KUCI";
    //    NSString* str2 = @"1.43";
    
    NSLog(@"dbg-str0: %@", strLatLong);
    
    NSArray *listItems = [strLatLong componentsSeparatedByString:@" "];
    double latitude = 0.0;
    double longitude = 0.0;
    
    if([listItems count] >= 2)
    {
        latitude = [[listItems objectAtIndex:0] doubleValue];
        longitude = [[listItems objectAtIndex:1] doubleValue];
    }
    
    NSLog(@"dbg:latitude: %f", latitude);
    NSLog(@"dbg:longitude: %f", longitude);
    
    coordinate.latitude = latitude;
    coordinate.longitude = longitude;
    
    firstCoordinate.latitude  = coordinate.latitude;
    firstCoordinate.longitude = coordinate.longitude;
    
    // add to the annotation list
    ESIAnnotation* annotation = [[ESIAnnotation alloc] init];
    
    annotation.coordinate = firstCoordinate;
    NSLog(@"dbg -(Title) str1: %@", strCity);
    NSLog(@"dbg -(subtitle) str2: %@", strDistance);
    
    NSString* cityState = [NSString stringWithFormat:@"%@, %@", strCity, strState];
    NSString* finDist = [NSString stringWithFormat:@"%@ mi", strDistance];
    
    
    [annotation setTitle:cityState];
    [annotation setSubtitle:finDist];
    [self.mapView addAnnotation:annotation];
    
    span.latitudeDelta  = 0.29; //0.01;
    span.longitudeDelta = 0.29; //0.01;
    
    region.span = span;
    region.center = firstCoordinate;
    
    [self.mapView setRegion:region animated:TRUE];
    [self.mapView regionThatFits:region];
     self.mapView.showsUserLocation = YES;
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    //NSLog(@"welcome into the map view annotation");
    
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
       return nil;
    
    // try to dequeue an existing pin view first
    static NSString* AnnotationIdentifier = @"AnnotationIdentifier1";
    MKPinAnnotationView* pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
    pinView.animatesDrop=YES;
    pinView.canShowCallout=YES;
    pinView.pinColor = MKPinAnnotationColorPurple;
   	//pinView.pinColor = MKPinAnnotationColorGreen;
    
    UIImageView *profileIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile.png"]];
    
    pinView.leftCalloutAccessoryView = profileIconView;
    
    return pinView;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation: (MKUserLocation *)userLocation {
    //coomment out we want to center on stations location, not current user
    // self.mapView.centerCoordinate = userLocation.location.coordinate;
}


#pragma mark -
#pragma mark CLLocationManagerDelegate Methods
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
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
}


-(void)addAddress:(NSMutableArray*)address
{
    self.myAddressArray = address;
}

//Helper method - if needed
-(float)kilometresBetweenPlace1:(CLLocationCoordinate2D) currentLocation andPlace2:(CLLocationCoordinate2D) place2
{
    CLLocation *userLoc = [[CLLocation alloc] initWithLatitude:currentLocation.latitude longitude:currentLocation.longitude];
    CLLocation *poiLoc = [[CLLocation alloc] initWithLatitude:place2.latitude longitude:place2.longitude];
    
    CLLocationDistance dist = [poiLoc distanceFromLocation:userLoc];
    
    //CLLocationDistance dist = [userLoc getDistanceFrom:poiLoc]/(1000*distance);
    // - (CLLocationDistance)distanceFromLocation:(const CLLocation *)location
    NSString *strDistance = [NSString stringWithFormat:@"%.2f", dist];
    // NSLog(@"%@",strDistance);
    
    return [strDistance floatValue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

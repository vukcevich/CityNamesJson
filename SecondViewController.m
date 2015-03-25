//
//  SecondViewController.m
//  CityNamesJson
//
//  Created by Marijan Vukcevich on 3/2/15.
//  marijanv@yahoo.com  - 949-891-2644
//  Copyright (c) 2015 East Side Interactive, LLC by Marijan Vukcevich. All rights reserved.
//

#import "SecondViewController.h"

#import "ESIAnnotation.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

@synthesize myAddressArray;


- (void)viewDidLoad {
    [super viewDidLoad];
   
    
    // Get path to documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // Path to save array data
    NSString* arrayPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"CitiesRecordsArray.out"];
    self.savedStationsFromFile = [NSArray arrayWithContentsOfFile:arrayPath];
    
    NSLog(@"dbg: self.savedStationsFromFile: %@", self.savedStationsFromFile);
    
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
    
    [self showCurrentLocation];
    
    [self getLocations]; 
    
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


-(void) getLocations {
    
    self.mapView.delegate=self;
    
    if(annotations != NULL) {
        return;
    }
    
    annotations=[[NSMutableArray alloc] init];
    
    for(NSDictionary* d in self.savedStationsFromFile) {
        NSMutableDictionary* coor = [d objectForKey:@"coordinate"];
        
        NSString *dblat = [coor objectForKey:@"latitude"];
        checkPlace.latitude = [dblat doubleValue];
        NSString *dblng = [coor objectForKey:@"longitude"];
        checkPlace.longitude = [dblng doubleValue];
        
         NSLog(@"Test one: %f : %f", checkPlace.latitude, checkPlace.longitude);
        ESIAnnotation* myAnnotation =[[ESIAnnotation alloc] init];
        
        myAnnotation.coordinate = checkPlace;
        myAnnotation.title= [NSString stringWithFormat:@"%@, %@", [d objectForKey:@"cityname"], [d objectForKey:@"state"]];
        myAnnotation.subtitle= [NSString stringWithFormat:@"%.2f mi",[[d objectForKey:@"miles"]doubleValue]];
        
        [self.mapView addAnnotation:myAnnotation];
        
        [annotations addObject:myAnnotation];
     }
    
    // Walk the list of overlays and annotations and create a MKMapRect that
    // bounds all of them and store it into flyTo.
    MKMapRect flyTo = MKMapRectNull;
    for (id <MKAnnotation> annotation in annotations) {
        NSLog(@"fly to on");
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(flyTo)) {
            flyTo = pointRect;
        } else {
            flyTo = MKMapRectUnion(flyTo, pointRect);
            NSLog(@"else-%f",annotationPoint.x);
        }
        
    }
    
    // Position the map so that all overlays and annotations are visible on screen.
    [self.mapView setVisibleMapRect:flyTo animated:YES];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    //NSLog(@"welcome into the map view annotation");
    
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // try to dequeue an existing pin view first
    static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
    MKPinAnnotationView* pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
    pinView.animatesDrop=YES;
    pinView.canShowCallout=YES;
   	pinView.pinColor = MKPinAnnotationColorPurple;
    
    UIImageView *profileIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile.png"]];
    pinView.leftCalloutAccessoryView = profileIconView;
    
    return pinView;
}



- (void)mapView:(MKMapView *)mapView didUpdateUserLocation: (MKUserLocation *)userLocation {
     self.mapView.centerCoordinate = userLocation.location.coordinate;
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

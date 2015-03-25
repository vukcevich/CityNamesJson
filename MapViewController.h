//
//  MapViewController.h
//  CityNamesJson
//
//  Created by Marijan Vukcevich on 3/5/15.
//  marijanv@yahoo.com  - 949-891-2644
//  Copyright (c) 2015 East Side Interactive, LLC by Marijan Vukcevich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CoreLocation/CoreLocation.h"

#define NSLog(...) NSLog(@"%s [Line %d] %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])

@class ESIAnnotation;

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>
{
    
    CLLocationCoordinate2D checkPlace;
    
    NSMutableArray* annotations;
}


@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) CLLocation *startingPoint;

@property (strong, nonatomic) IBOutlet MKMapView* mapView;


@property (strong, nonatomic) ESIAnnotation*  addAnnotation;

@property(nonatomic, strong) NSMutableArray* myAddressArray;

-(void)addAddress:(NSMutableArray*)address;

@end

//
//  FirstViewController.h
//  CityNamesJson
//
//  Created by Marijan Vukcevich on 3/2/15.
//  marijanv@yahoo.com  - 949-891-2644
//  Copyright (c) 2015 East Side Interactive, LLC by Marijan Vukcevich. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CoreLocation/CoreLocation.h"

#define NSLog(...) NSLog(@"%s [Line %d] %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])

@interface FirstViewController : UITableViewController <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>


@property (nonatomic,strong) CLLocationManager* locMgr;

@property (strong, nonatomic) CLLocation* startingPoint;

@property (strong, nonatomic) NSMutableDictionary* dictAllCityNames;
@property (strong,  nonatomic) NSMutableArray* cityNamesRecordsArray;
@property (strong, nonatomic) NSMutableArray* combinedJsonArrays;

@property (strong, nonatomic) IBOutlet UITableView* stationTableView;

-(void)getStationsJsonData;
@end


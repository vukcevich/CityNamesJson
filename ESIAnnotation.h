//
//  ESIAnnotation.h
//  CityNamesJson
//
//  Created by Marijan Vukcevich on 8/9/12.
//  marijanv@yahoo.com  - 949-891-2644
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#define NSLog(...) NSLog(@"%s [Line %d] %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])

@interface ESIAnnotation : NSObject <MKAnnotation> {
    
    CLLocationCoordinate2D	coordinate;
	NSString*				title;
	NSString*				subtitle;
}

@property (nonatomic, assign)	CLLocationCoordinate2D	coordinate;
@property (nonatomic, copy)		NSString*				title;
@property (nonatomic, copy)		NSString*				subtitle;

@end

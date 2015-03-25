//
//  ESIAnnotation.m
//  CityNamesJson
//
//  Created by Marijan Vukcevich on 8/9/12.
//  marijanv@yahoo.com  - 949-891-2644
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ESIAnnotation.h"

@implementation ESIAnnotation

@synthesize title, subtitle, coordinate;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c {
	coordinate=c;
    //	NSLog(@"DEBUG: %f,%f",c.latitude,c.longitude);
	return self;
}


@end

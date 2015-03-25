//
//  AppDelegate.h
//  CityNamesJson
//
//  Created by Marijan Vukcevich on 3/2/15.
//  marijanv@yahoo.com  - 949-891-2644
//  Copyright (c) 2015 East Side Interactive, LLC by Marijan Vukcevich. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NSLog(...) NSLog(@"%s [Line %d] %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end


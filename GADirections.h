//
//  GADirections.h
//  TimeTrack
//
//  Created by Roman Hardukevich on 25.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "Reachability.h"
#import "RegexKitLite.h"

@interface GADirections : NSObject


+(NSArray*)calculateRoutesFrom:(CLLocation*)A
                            to:(CLLocation*)B
                   writeTimeTo:(NSMutableString **)travelTime;

@end

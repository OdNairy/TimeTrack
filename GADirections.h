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


+(NSArray*)calculateRoutesFrom:(CLLocationCoordinate2D)A
                            to:(CLLocationCoordinate2D)B
                   WriteTimeTo:(NSMutableString *)travelTime;

@end

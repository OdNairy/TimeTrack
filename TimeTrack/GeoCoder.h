//
//  GeoCoder.h
//  TimeTrack
//
//  Created by Roman Hardukevich on 18.08.11.
//  Copyright 2011 iTransition ©. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "RegexKitLite.h"


@interface GeoCoder

+(NSString*)getGeoCodeString:(NSString*)place;
+(CLLocation*)getGeoCodeCoordinates:(NSString*)place;
+(CLLocation*)createLocationFromGeoString:(NSString*)geoString;

@end

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
+(CLLocationCoordinate2D)getGeoCodeCoordinates:(NSString*)place;
+(CLLocationCoordinate2D)getCoorsFromString:(NSString*)place;

@end

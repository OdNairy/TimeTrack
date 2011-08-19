//
//  GeoCoder.h
//  TimeTrack
//
//  Created by Roman Hardukevich on 18.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "RegexKitLite.h"


@interface GeoCoder

+(NSString*)getGeoCode:(NSString*)place;
+(CLLocationCoordinate2D)getCoordinatesOfPlace:(NSString*)place;

@end

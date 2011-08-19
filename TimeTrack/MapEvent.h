//
//  Place.h
//  Miller
//
//  Created by kadir pekel on 2/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapEvent : NSObject {
	NSString* name;
	NSString* description;
	CLLocationDegrees latitude;
	CLLocationDegrees longitude;
}

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* description;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

-(id)initWithName:(NSString*)_name description:(NSString*)_description latitude:(CLLocationDegrees)_latitude longitude:(CLLocationDegrees)_longitude;

@end

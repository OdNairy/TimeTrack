//
//  Place.m
//  Miller
//
//  Created by kadir pekel on 2/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MapEvent.h"


@implementation MapEvent

@synthesize name;
@synthesize description;
@synthesize latitude;
@synthesize longitude;

- (void) dealloc
{
	[name release];
	[description release];
	[super dealloc];
}

-(id)initWithName:(NSString *)_name description:(NSString *)_description latitude:(CLLocationDegrees)_latitude longitude:(CLLocationDegrees)_longitude
{
           self.name = name;
    self.description = description;
       self.latitude = latitude;
      self.longitude = longitude;
    
    return self;
}

@end

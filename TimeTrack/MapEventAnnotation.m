//
//  PlaceMark.m
//  TimeTrack
//
//  Created by Roman Hardukevich on 18.08.11.
//  Copyright 2011 iTransition ©. All rights reserved.
//

#import "MapEventAnnotation.h"


@implementation MapEventAnnotation

@synthesize coordinate,title,subtitle;

-(id) initWithName:(NSString *)_name
       description:(NSString *)_description
          latitude:(CLLocationDegrees)_latitude
         longitude:(CLLocationDegrees)_longitude
{
	self = [super init];
	if (self != nil)
    {
                   self.title = _name        ;
                self.subtitle = _description ;
          coordinate.latitude = _latitude    ;
         coordinate.longitude = _longitude   ;
	}
	return self;
}

+(MapEventAnnotation*)mapEventAnnotationWithName:(NSString *)_name
                                     description:(NSString *)_description
                                        latitude:(CLLocationDegrees)_latitude
                                       longitude:(CLLocationDegrees)_longitude
{
    MapEventAnnotation* annotation = [[[MapEventAnnotation alloc] initWithName:_name
                                                                   description:_description
                                                                      latitude:_latitude
                                                                     longitude:_longitude]
                                      autorelease];
    return annotation;
}

- (void) dealloc
{
    self.title = nil;
    self.subtitle = nil;

	[super dealloc];
}


@end

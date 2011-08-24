//
//  PlaceMark.h
//  TimeTrack
//
//  Created by Roman Hardukevich on 18.08.11.
//  Copyright 2011 iTransition ©. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapEventAnnotation : NSObject<MKAnnotation> {

	CLLocationCoordinate2D coordinate;
    NSString* title;
	NSString* subtitle;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, readwrite, copy) NSString *title;
@property (nonatomic, readwrite, copy) NSString *subtitle;

-(id)initWithName:(NSString*)_name 
      description:(NSString*)_description 
         latitude:(CLLocationDegrees)_latitude 
        longitude:(CLLocationDegrees)_longitude; 
+(MapEventAnnotation*)mapEventAnnotationWithName:(NSString*)_name 
                                     description:(NSString*)_description 
                                        latitude:(CLLocationDegrees)_latitude 
                                       longitude:(CLLocationDegrees)_longitude;

@end

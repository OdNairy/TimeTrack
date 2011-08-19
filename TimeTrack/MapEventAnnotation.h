//
//  PlaceMark.h
//  Miller
//
//  Created by kadir pekel on 2/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "MapEvent.h"

@interface MapEventAnnotation : NSObject <MKAnnotation> {

	CLLocationCoordinate2D coordinate;
	MapEvent* place;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) MapEvent* place;

-(id) initWithPlace: (MapEvent*) p;

@end

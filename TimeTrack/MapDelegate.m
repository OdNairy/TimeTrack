//
//  EventMap.m
//  TimeTrack
//
//  Created by Roman Hardukevich on 21.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapDelegate.h"
#import "Reachability.h"
@interface MapDelegate()

-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded;
-(void) updateRouteView;
-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) from to: (CLLocationCoordinate2D) to;
-(void) centerMap;

@end

@implementation MapDelegate
@synthesize travelTime,lineColor;

- (id)init
{
    self = [super init];
    if (self) {
        self.lineColor = [UIColor colorWithWhite:0.2 alpha:0.5];
    }
    
    return self;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	
	// don't change user-pin
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
	static NSString* AnnotationIdentifier = @"pinIdentifier";
	MKPinAnnotationView* pinView = [[[MKPinAnnotationView alloc]
									 initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier] autorelease];
	pinView.animatesDrop=YES;
	pinView.canShowCallout=YES;
	pinView.pinColor=MKPinAnnotationColorPurple;
	
	
	UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	[rightButton setTitle:annotation.title forState:UIControlStateNormal];
	[rightButton addTarget:self
					action:@selector(showDetails:)
		  forControlEvents:UIControlEventTouchUpInside];
	pinView.rightCalloutAccessoryView = rightButton;
	
	UIImageView *profileIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile.png"]];
	pinView.leftCalloutAccessoryView = profileIconView;
	[profileIconView release];
	
	
	return pinView;
}

-(NSMutableArray*)decodePolyLine:(NSMutableString *)encoded
{
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
								options:NSLiteralSearch
								  range:NSMakeRange(0, [encoded length])];
	NSInteger 
        length = [encoded length],
        i = 0;
	NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
	NSInteger 
        lat = 0,
        lng = 0;
	while (i < length) {
		NSInteger b;
		NSInteger shift = 0;
		NSInteger result = 0;
		do {
			b = [encoded characterAtIndex:i++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
        
		NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lat += dlat;
		shift = 0;
		result = 0;
		do {
			b = [encoded characterAtIndex:i++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
        
		NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lng += dlng;
		NSNumber *latitude = [[[NSNumber alloc] initWithFloat:lat * 1e-5] autorelease];
		NSNumber *longitude = [[[NSNumber alloc] initWithFloat:lng * 1e-5] autorelease];
		printf("[%f,", [latitude doubleValue]);
		printf("%f]", [longitude doubleValue]);
		CLLocation *loc = [[[CLLocation alloc] initWithLatitude:[latitude floatValue] 
                                                      longitude:[longitude floatValue]] 
                           autorelease];
		[array addObject:loc];
	}
    
	return array;
}

-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to
{
    if (![Reachability isNetworkAvailable]) 
    {
        return nil;
    }
    
    NSString* apiStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%f,%f&daddr=%f,%f",from.latitude,from.longitude,to.latitude,to.longitude];
    NSString* apiResponse = [NSString stringWithContentsOfURL:[NSURL URLWithString:apiStr] encoding:NSUTF8StringEncoding error:nil];
    
    if (apiResponse == nil){
        // TODO Write 
        apiResponse= [NSString stringWithString:@"{tooltipHtml:\" (13.8\x26#160;km / 21 mins)\",polylines:[{id:\"route0\",points:\"g~qgI{oxgDiD_K}BaGaHoN}D_GiEwF}CeDwd@ed@c`@__@kh@sh@??wAwBMeA@aA`@{@pEu@h@HZ^LjAC`A??sDnKuAtFq@xDe@|DqBjM??yLjq@uE`VoKnm@iNpv@}@dE_@hC_AhE_Q|j@_@zA_@~BkLtaAcCtTaOtoAc@BUTWv@E~@F`@Vn@cBjOoC`RmGp[sOht@aDnP??sL|i@??_@vCQvC@~C`Aj[^dFrDr\\???lAKv@mAbD}AzBoBvDmh@ngAiLzP??}CmIkDsI??QV??m@h@\",levels:\"B??@?@???BB???@?@??BB????BB?????@??@??????????@???BBBB???@?BB?????@BB?BBBBB\",numLevels:4,zoomFactor:16}]}"];
    }
    
    travelTime = [apiResponse stringByMatching:@"tooltipHtml:s\"\ .*?\/.(.*?).\"" capture:1L];
    
    NSMutableString* encodedPoints = (NSMutableString*) [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
	
    return [self decodePolyLine: encodedPoints];
}

- (void)showRouteFrom:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to
{
    if (routes) {
        [routes addObjectsFromArray:[[self calculateRoutesFrom:from to:to] mutableCopy]];
    } else {
        routes = [[self calculateRoutesFrom:from to:to] mutableCopy];
    }
    
    
}


@end

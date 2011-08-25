//
//  TrackMap.m
//  TimeTrack
//
//  Created by Roman Hardukevich on 24.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrackMap.h"

@interface TrackMap()
{
    @private
    NSMutableArray* routes;
    UIColor* lineColor;
}
-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded;
-(void) updateRoute;
-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D)A to: (CLLocationCoordinate2D)B WriteTimeTo:(NSMutableString*)travelTime;
-(void) centerMap;

@end

@implementation TrackMap

- (id)init
{
    self = [super init];
    if (self) {
        lineColor = [UIColor colorWithWhite:0.2 alpha:0.5];
        routes = [[NSMutableArray alloc] init];
    }
    
    return self;
}





-(NSDate *)showPathFrom:(CLLocationCoordinate2D)A to:(CLLocationCoordinate2D)B
{
    NSMutableString* travelTime = [[NSMutableString alloc] init];
    [routes addObjectsFromArray:[self calculateRoutesFrom:A
                                                       to:B
                                              WriteTimeTo:travelTime]];

    [self updateRoute];
    [self centerMap];
    
    // TODO parse travelTime and return Date
    
    
    // days hours/hour
    // Very long way
    // http://maps.google.com/maps?saddr=U.S.+30+E&daddr=28.62903,-109.99601+to:35.11166,-78.96094+to:23.6424,-103.62574+to:40.79664,-77.67056+to:48.0356,-98.44414+to:45.11,-119.125&hl=en&sll=37.579413,-103.31543&sspn=28.529625,56.90918&geocode=FTzfqgIdiFf6-A%3BFSbYtAEdFphx-Sk72MKcKcvIhjG5NFVKkh9yyw%3BFezCFwId1CZL-ylFq6R6pmuriTFGRPPHAnyseA%3BFSDBaAEd9MvS-SkRymV18FObhjHMgbDoNetuPw%3BFeCBbgIdYNde-yk98QbVFbrOiTEMkeiK_7lYyA%3BFRD33AIdlNwh-imxRIrEM8HEUjH1_U99Lj02dw%3BFfBSsAId-Evm-A&vpsrc=0&mra=mift&mrsp=0&sz=5&via=1,2,3,4,5&z=5
    
    [travelTime release];
    return nil;
}

-(NSArray*)calculateRoutesFrom:(CLLocationCoordinate2D)A to:(CLLocationCoordinate2D)B WriteTimeTo:(NSMutableString *)travelTime
{
    if (![Reachability isNetworkAvailable]) 
    {
        return nil;
    }
    
    NSString* apiStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%f,%f&daddr=%f,%f",A.latitude,A.longitude,B.latitude,B.longitude];
    NSString* apiResponse = [NSString stringWithContentsOfURL:[NSURL URLWithString:apiStr] encoding:NSUTF8StringEncoding error:nil];
    
    travelTime = [[apiResponse stringByMatching:@"tooltipHtml:s\"\ .*?\/.(.*?).\"" capture:1L] mutableCopy];
    
    NSMutableString* encodedPoints = (NSMutableString*) [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
	
    return [self decodePolyLine: encodedPoints];
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


-(void)updateRoute
{
    CGContextRef context = CGBitmapContextCreate(nil, 
                                                 self.frame.size.width, 
                                                 self.frame.size.height, 
                                                 8, 
                                                 4*self.frame.size.width, 
                                                 CGColorSpaceCreateDeviceRGB(), 
                                                 kCGImageAlphaPremultipliedLast);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
    CGContextSetLineWidth(context, 6.0);
    
    CLLocation* location;
    for (size_t i = 0; i < routes.count; ++i) 
    {
        location = [routes objectAtIndex:i];
        CGPoint point = [self convertCoordinate:location.coordinate toPointToView:self];
        
        if (i == 0) 
        {
            CGContextMoveToPoint(context, point.x, self.frame.size.height - point.y);
        } else 
        {
            CGContextAddLineToPoint(context, point.x, self.frame.size.height - point.y);
        }
    }
    
    CGContextStrokePath(context);
    
    CGImageRef  image = CGBitmapContextCreateImage(context);
    UIImage*    uiImage = [UIImage imageWithCGImage:image];
    
    
    
    return;
}


































@end

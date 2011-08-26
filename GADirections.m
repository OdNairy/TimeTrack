//
//  GADirections.m
//  TimeTrack
//
//  Created by Roman Hardukevich on 25.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GADirections.h"

@interface GADirections()
+(NSArray *)decodePolyLine: (NSString *)encodedStr;
@end


@implementation GADirections

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+(NSArray*)decodePolyLine:(NSString *)encodedStr
{
    NSMutableString* encoded = [encodedStr mutableCopy];
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
        
        
        CLLocation *loc = [[[CLLocation alloc] initWithLatitude:[latitude floatValue] 
                                                      longitude:[longitude floatValue]] 
                           autorelease];
		[array addObject:loc];
	}


    
	return array;
}

+(NSArray*)calculateRoutesFrom:(CLLocationCoordinate2D)A to:(CLLocationCoordinate2D)B WriteTimeTo:(NSMutableString *)travelTime
{
    if (![Reachability isNetworkAvailable]) 
    {
        return nil;
    }
    
    NSString* apiStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%f,%f&daddr=%f,%f",A.latitude,A.longitude,B.latitude,B.longitude];
    NSString* apiResponse = [NSString stringWithContentsOfURL:[NSURL URLWithString:apiStr] encoding:NSUTF8StringEncoding error:nil];
    
    travelTime = [[apiResponse stringByMatching:@"tooltipHtml:\"\ .*?\/.(.*?).\"" capture:1L] mutableCopy];
	
    return [GADirections decodePolyLine: [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L]];
}

@end

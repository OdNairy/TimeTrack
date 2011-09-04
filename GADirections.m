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
    if (!encodedStr) {
        return nil;
    }
    
    NSMutableString* encoded = [encodedStr mutableCopy];
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
								options:NSLiteralSearch
								  range:NSMakeRange(0, [encoded length])];
	NSInteger length = [encoded length];
    NSInteger lat = 0;
    NSInteger lng = 0;
    NSUInteger i = 0;
	NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
	
	while (i < length)
    {
		NSInteger b;
		NSInteger shift = 0;
		NSInteger result = 0;
		do 
        {
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
        
		NSNumber *latitude  = [NSNumber numberWithFloat:lat * 1e-5];
		NSNumber *longitude = [NSNumber numberWithFloat:lng * 1e-5];
        
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] 
                                                     longitude:[longitude floatValue]];
		[array addObject:loc];
        [loc release];
	}


    [encoded release];
	return array;
}

+(NSArray*)calculateRoutesFrom:(CLLocation*)A to:(CLLocation*)B WriteTimeTo:(NSMutableString **)travelTime
{
    if (![Reachability isNetworkAvailable])
    {
        return nil;
    }
    
    NSString* apiStr = [NSString stringWithFormat:@"http://maps.google.com/maps?units=metric&output=dragdir&saddr=%f,%f&daddr=%f,%f",
                        A.coordinate.latitude ,
                        A.coordinate.longitude,
                        B.coordinate.latitude ,
                        B.coordinate.longitude];

    NSString* apiResponse = [NSString stringWithContentsOfURL:[NSURL URLWithString:apiStr]
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
    
    *travelTime = [[apiResponse stringByMatching:@"tooltipHtml:\" .*?/.(.*?).\"" capture:1L] mutableCopy];
	
    return [GADirections decodePolyLine: [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L]];
}

@end

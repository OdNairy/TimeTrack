//
//  GADirections.m
//  TimeTrack
//
//  Created by Roman Hardukevich on 25.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GADirections.h"

@interface GADirections()

/*!
    @method     decodePolyLine:
    @discussion Look alghorithm in
    http://code.google.com/intl/ru/apis/maps/documentation/utilities/polylinealgorithm.html
*/
+(NSArray *)decodePolyLine: (NSString *)encodedStr;
@end


@implementation GADirections

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

+(NSArray*)calculateRoutesFrom:(CLLocation*)A to:(CLLocation*)B writeTimeTo:(NSMutableString **)travelTime
{
    if (![Reachability isNetworkAvailable])
    {
        return nil;
    }
    
    /*
     
     Travel Modes
     When you calculate directions, you may specify which transportation mode to use. By default, directions are calculated as driving directions. The following travel modes are currently supported:
            driving (default)           indicates standard driving directions using the road network.
            walking                     requests walking directions via pedestrian paths & sidewalks (where available).
            bicycling                   requests bicycling directions via bicycle paths & preferred streets (currently only available in the US).

     */
    
    NSString* apiStr = [NSString stringWithFormat:@"http://maps.google.com/maps?units=metric&output=dragdir&saddr=%f,%f&daddr=%f,%f",
                        A.coordinate.latitude ,
                        A.coordinate.longitude,
                        B.coordinate.latitude ,
                        B.coordinate.longitude];
    
    NSLog(@"GET->%@",apiStr);
    
    NSError* error = nil;
    NSString* apiResponse = [NSString stringWithContentsOfURL:[NSURL URLWithString:apiStr]
                                                     encoding:NSUTF8StringEncoding
                                                        error:&error];
    if (!error) {
        
        NSString* travTime = [apiResponse stringByMatching:@"tooltipHtml:\" .*?/.(.*?).\"" capture:1L];
        if (travelTime) {
            *travelTime = [travTime mutableCopy];
            NSLog(@"Calculate: travelTime = %@",*travelTime);
        }
        NSString* points_str = [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
        if (points_str) {
            NSMutableArray* points = [[NSMutableArray alloc] init];
            [points addObject:A];
            
            NSArray* pointsBetweenAAndB = [GADirections decodePolyLine: points_str];
            [points addObjectsFromArray:pointsBetweenAAndB];
            [points addObject:B];
            
            [points autorelease];
            return points;
        }
        return nil;
    }
    
    NSLog(@"Error: %@",error);
    return nil;

}

@end

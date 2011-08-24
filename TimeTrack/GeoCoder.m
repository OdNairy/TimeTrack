//
//  GeoCoder.m
//  TimeTrack
//
//  Created by Roman Hardukevich on 18.08.11.
//  Copyright 2011 iTransition ©. All rights reserved.
//

#import "GeoCoder.h"

// http://code.google.com/intl/ru/apis/maps/documentation/geocoding/#StatusCodes Just RUSSIAN
#define G_GEO_SUCCESS               @"200"
#define G_GEO_SERVER_ERROR          @"500"
#define G_GEO_MISSING_QUERY         @"601"
#define G_GEO_UNKNOWN_ADDRESS       @"602"
#define G_GEO_UNAVAILABLE_ADDRESS   @"603"
#define G_GEO_BAD_KEY               @"610"
#define G_GEO_TOO_MANY_QUERIES      @"620"

@implementation GeoCoder

+(NSString*)getGeoCodeString:(NSString*)place{
    NSString* a = [NSString stringWithContentsOfURL:[NSURL URLWithString:
                                                     [NSString stringWithFormat:
 @"http://maps.google.com/maps/geo?q=%@&output=csv&oe=utf8&sensor=false&key=ABQIAAAAsQG"
  "q8WplM--eXjoG22fyoxQfeLOjlwh1gOAGly-wMj-tpVbFhxRxlFsf4c59AN-bk20pwlqZVKAjtA",place]] 
                                           encoding:NSUTF8StringEncoding 
                                              error:nil];
    if ([[a stringByMatching:@"^[0-9]{3}"] isEqualToString:G_GEO_SUCCESS]) {
        return [a stringByMatching:@"^[0-9]{3},(.*)" capture:1L];
    }

    return nil;
}

+(CLLocationCoordinate2D)getGeoCodeCoordinates:(NSString*)place{
    NSString* coors = [GeoCoder getGeoCodeString:place];
    return [GeoCoder getCoorsFromString:coors];
}

+(CLLocationCoordinate2D)getCoorsFromString:(NSString *)place{
    return CLLocationCoordinate2DMake([[place stringByMatching:@"^..(.*)"   capture:1L] floatValue], 
                                      [[place stringByMatching:@",.*?,(.*)" capture:1L] floatValue]);
}
@end

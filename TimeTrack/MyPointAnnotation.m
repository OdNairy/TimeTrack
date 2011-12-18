//
//  MyAnnotation.m
//  TimeTrack
//
//  Created by Roman Hardukevich on 01.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyPointAnnotation.h"

@implementation MyPointAnnotation

@synthesize event;

- (id)init
{
    if (self = [super init])
    {
        event = nil;
    }
    
    return self;
}

@end

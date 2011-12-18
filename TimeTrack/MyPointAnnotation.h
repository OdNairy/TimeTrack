//
//  MyAnnotation.h
//  TimeTrack
//
//  Created by Roman Hardukevich on 01.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CalendarCenter.h"

@interface MyPointAnnotation : MKPointAnnotation
{
    EKEvent* event;
}

@property(nonatomic,assign) EKEvent* event;

@end

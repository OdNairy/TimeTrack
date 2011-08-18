//
//  CalendarCenter.h
//  TimeTrack
//
//  Created by Roman Hardukevich on 18.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface CalendarCenter: NSObject{
        
        EKEventViewController *detailViewController;
        EKEventStore *eventStore;
        EKCalendar *defaultCalendar;
        NSMutableArray *eventsList;
    }

@property (nonatomic, retain) EKEventStore *eventStore;
@property (nonatomic, retain) EKCalendar *defaultCalendar;
@property (nonatomic, retain) NSMutableArray *eventsList;
@property (nonatomic, retain) EKEventViewController *detailViewController;

- (NSArray *) fetchEventsForToday;
//- (IBAction) addEvent:(id)sender;

@end
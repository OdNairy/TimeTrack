//
//  CalendarCenter.m
//  TimeTrack
//
//  Created by Roman Hardukevich on 18.08.11.
//  Copyright 2011 iTransition ©. All rights reserved.
//

#import "CalendarCenter.h"

@implementation CalendarCenter

@synthesize eventsList, eventStore, defaultCalendar, detailViewController;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialize an event store object with the init method. Initilize the array for events.
        self.eventStore = [[EKEventStore alloc] init];
        
        self.eventsList = [[NSMutableArray alloc] init];
        
        // Fetch today's event on selected calendar and put them into the eventsList array
//        [self.eventsList addObjectsFromArray:[self fetchEventsForToday]];
    }
    
    return self;
}

- (void)dealloc
{
    [eventStore release];
    [eventsList release];
    [super dealloc];
}

- (NSArray *)fetchEventsForToday 
{
	NSDate *startDate = [NSDate date];
    
	// endDate is 1 day = 60*60*24 seconds = 86400 seconds from startDate
	NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow:86400];
	
    EKEventStore* store = [[EKEventStore alloc] init];
    
	// Create the predicate. Pass it the default calendar.
	NSPredicate *predicate = [store predicateForEventsWithStartDate:startDate endDate:endDate 
                                                                    calendars:nil]; 
	
	// Fetch all events that match the predicate.
	NSMutableArray* arr = [(NSMutableArray*)[store eventsMatchingPredicate:predicate] autorelease];
    
	return arr;
}



- (NSArray *)fetchEventsWithCoordinatesFrom:(NSDate*)from to:(NSDate*)to
{
    NSPredicate* predicate = [self.eventStore predicateForEventsWithStartDate:from endDate:to calendars:nil];
    eventsList = [[self.eventStore eventsMatchingPredicate:predicate] mutableCopy];
    
    CLLocationCoordinate2D eventCoors;
    EKEvent* event;
    NSUInteger count = eventsList.count;
    for (NSInteger i = count - 1; i >= 0; --i) {
        event = [eventsList objectAtIndex:i];
        
        if ([event.startDate compare:from] == NSOrderedAscending)
        {
            [eventsList removeObjectAtIndex:i];
            continue;
        }

        eventCoors = CLLocationCoordinate2DMake([[event.location 
                                                  stringByMatching:@"^(.*?),"   
                                                  capture:1L] floatValue], 
                                                [[event.location 
                                                  stringByMatching:@".*?,(.*)" 
                                                  capture:1L] floatValue]);
        if (eventCoors.latitude == 0 && eventCoors.longitude == 0) 
        {
            eventCoors = [GeoCoder getGeoCodeCoordinates:[event location]];
            
            if (eventCoors.latitude == 0 && eventCoors.longitude == 0) 
            {
                // We can't locate this event on the map.
                [eventsList removeObjectAtIndex:i];
                continue;
            }
            [event setLocation:[NSString stringWithFormat:@"%f,%f %@",
                                eventCoors.latitude,
                                eventCoors.longitude,
                                event.location]];
        }else
        {
            NSString* tmp = [event.location copy];
            [event setLocation:[NSString stringWithFormat:@"%@ %@",
                                tmp,
                                [[GeoCoder getGeoCodeString:event.location] 
                                 stringByMatching:@"\"(.*)\"" capture:1L]]];
            [tmp release];
        }
    }
    // Will be returned sorted array
    return eventsList;
}

@end

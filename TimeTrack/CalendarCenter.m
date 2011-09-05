//
//  CalendarCenter.m
//  TimeTrack
//
//  Created by Roman Hardukevich on 18.08.11.
//  Copyright 2011 iTransition ©. All rights reserved.
//

#import "CalendarCenter.h"
#import "MainViewController.h"

@interface CalendarCenter()
+(CLLocation*)createLocationFromEvent:(EKEvent*)event;
@end

@implementation CalendarCenter

@synthesize eventsList, eventStore, defaultCalendar, detailViewController,delegate;

static CalendarCenter* defaultCenter = nil;


+(CalendarCenter*)defaultCenter
{
    @synchronized([CalendarCenter class])
    {
        
        if (!defaultCenter)
        {
            defaultCenter = [[CalendarCenter alloc] init];
        }
    }
    return defaultCenter;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        // Initialize an event store object with the init method. Initilize the array for events.
        self.eventStore = [[EKEventStore alloc] init];
        
//        self.eventsList = [[NSMutableArray alloc] init];
        
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

#pragma mark - Fetch Events

+(CLLocation*)createLocationFromEvent:(EKEvent*)event
{
    NSArray*arr = [event.location componentsSeparatedByString:@","];
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([[arr objectAtIndex:0] floatValue],
                                                             [[arr objectAtIndex:1] floatValue]);
    if (coor.latitude == 0 && coor.longitude == 0)
    {
        return nil;
    }
    else
    {
        return [[[CLLocation alloc] initWithLatitude:coor.latitude longitude:coor.longitude] autorelease];
    }
}

- (NSArray *)fetchEventsWithCoordinatesFrom:(NSDate*)from to:(NSDate*)to
{
    // Take all events between input dates [from; to]

    eventsList = [[self.eventStore eventsMatchingPredicate:
                   [self.eventStore predicateForEventsWithStartDate:from
                                                            endDate:to
                                                          calendars:nil]]
                  mutableCopy];
    
    
    CLLocation* eventCoors;
    EKEvent* event;
    NSUInteger count = eventsList.count;
    
    for (NSInteger i = count - 1; i >= 0; --i)
    {
        event = [eventsList objectAtIndex:i];
        
        if ([event.startDate compare:from] == NSOrderedAscending)
        {
            [eventsList removeObjectAtIndex:i];
            continue;
        }

        eventCoors = [CalendarCenter createLocationFromEvent:event];
        
        
        // If there are no coordinates in field "location"
        if (eventCoors == nil) 
        {
            //[GeoCoder createLocationFromGeoString:(NSString *)];
            eventCoors = [GeoCoder getGeoCodeCoordinates:[event location]];
            
            if (eventCoors.coordinate.latitude == 0 && eventCoors.coordinate.longitude == 0) 
            {
                // We can't locate this event on the map.
                [eventsList removeObjectAtIndex:i];
                continue;
            }

            [event setLocation:[NSString stringWithFormat:@"%f,%f %@",
                                eventCoors.coordinate.latitude,
                                eventCoors.coordinate.longitude,
                                event.location]];
        }
        else
        {
            NSMutableString* tmp = [event.location mutableCopy];
           // [event.location release];
            [event setLocation:[NSString stringWithFormat:@"%@ %@",
                                tmp,
                                [ [GeoCoder getGeoCodeString:event.location] stringByMatching:@"\"(.*)\"" capture:1L]]];
            [tmp release];
        }
        
    }
    
    // Will be returned sorted array
    return eventsList;
}

#pragma mark - EKEvent Delegate

-(void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
	NSError *error = nil;
	EKEvent *thisEvent = controller.event;
	
	switch (action)
    {
		case EKEventEditViewActionCanceled:
			// Edit action canceled, do nothing.
			break;
        
		case EKEventEditViewActionSaved:
			// When user hit "Done" button, save the newly created event to the event store
            
			[self.eventsList addObject:thisEvent];
			[controller.eventStore saveEvent:controller.event
                                        span:EKSpanThisEvent
                                       error:&error];
            [delegate addAnnotationFromEvent:thisEvent];
            
			break;
			
		case EKEventEditViewActionDeleted:
			// When deleting an event, remove the event from the event store
			// If deleting an event from the currenly default calendar, then update its
			// eventsList.
            
            [self.eventsList removeObject:thisEvent];
			[controller.eventStore removeEvent:thisEvent span:EKSpanThisEvent error:&error];
            [((MainViewController*)delegate).mapView updateEvents];
			break;
			
		default:
			break;
            
	}
	// Dismiss the modal view controller
    
	[controller dismissModalViewControllerAnimated:YES];
}


@end

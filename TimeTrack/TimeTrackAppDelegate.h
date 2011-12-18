//
//  TimeTrackAppDelegate.h
//  TimeTrack
//
//  Created by Roman Hardukevich on 18.08.11.
//  Copyright 2011 iTransition ©. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TrackMapViewController;

@interface TimeTrackAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet TrackMapViewController *mainViewController;

@end

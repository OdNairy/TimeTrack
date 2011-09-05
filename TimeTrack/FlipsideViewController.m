//
//  FlipsideViewController.m
//  TimeTrack
//
//  Created by Roman Hardukevich on 18.08.11.
//  Copyright 2011 iTransition ©. All rights reserved.
//

#import "FlipsideViewController.h"


@implementation FlipsideViewController

@synthesize delegate=_delegate;

- (void)dealloc
{
    [navigationModeSegment release];
    [useGeolocationSwitch release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];  
}

- (void)viewDidUnload
{
    [navigationModeSegment release];
    navigationModeSegment = nil;
    [useGeolocationSwitch release];
    useGeolocationSwitch = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Actions

- (IBAction)save:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

- (IBAction)cancel:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}


@end

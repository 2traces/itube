//
//  MainViewController.m
//  tube
//
//  Created by Alex 1 on 9/24/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"
#import "SelectingTabBarViewController.h"
#import "ManagedObjects.h"

#define FromStation 0
#define ToStation 1

@implementation MainViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	DLog(@"initWithNibName");
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}



 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 	DLog(@"viewDidLoad");
     [(MainView*)self.view viewInit:self];
 }




 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
     return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 


- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)showInfo {    
	
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

-(void)showTabBarViewController
{
    SelectingTabBarViewController *controller = [[SelectingTabBarViewController alloc] initWithNibName:@"SelectingTabBarViewController" bundle:[NSBundle mainBundle]];
    controller.delegate = self;
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

-(void)returnFromSelection:(NSArray*)stations
{
    MainView *ourView = (MainView*)self.view;

    if ([stations count]>1) {
        // это история и надо ставить обе станции
        [ourView didFirstStationSelected:[[stations objectAtIndex:0] name] line:[[[[stations objectAtIndex:0] lines] index] integerValue]];
        [ourView didSecondStationSelected:[[stations objectAtIndex:1] name] line:[[[[stations objectAtIndex:1] lines] index] integerValue]];
    } else {
        // это конкретная станция
        if (currentSelection==0) {
            [ourView didFirstStationSelected:[[stations objectAtIndex:0] name] line:[[[[stations objectAtIndex:0] lines] index] integerValue]];
        } else {
            [ourView didSecondStationSelected:[[stations objectAtIndex:0] name] line:[[[[stations objectAtIndex:0] lines] index] integerValue]];
        }
    }
    
    [ourView processStationSelect2];
    
    MHelper *helper = [MHelper sharedHelper];
    [helper saveBookmarkFile];
    [helper saveHistoryFile];
    [self dismissModalViewControllerAnimated:YES];
}

-(void)pressedSelectFromStation
{
    DLog(@"From Station from controller pressed");
    currentSelection=FromStation;
    [self showTabBarViewController];
}

-(void)pressedSelectToStation
{
    DLog(@"To Station from controller pressed");
    currentSelection=ToStation;
    [self showTabBarViewController];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

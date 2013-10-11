//
//  NavigationViewController.m
//  tube
//
//  Created by Alexey on 5/11/12.
//
//

#import "NavigationViewController.h"
#import "ManagedObjects.h"
#import "SettingsNavController.h"
#import "tubeAppDelegate.h"

@interface NavigationViewController ()

@end

@implementation NavigationViewController

@synthesize glController;
@synthesize currentPlaces;
@synthesize currentCategory;
@synthesize separatingView;
@synthesize shadow;

-(IBAction)searchButton:(UIButton *)sender
{
    [_textField resignFirstResponder];
}

-(IBAction)searchText:(UITextField *)sender
{
    [glController loadCitiesLikeThis:sender.text];
}

- (void) showSettings
{
    SettingsNavController *controller = [[SettingsNavController alloc] initWithNibName:@"SettingsNavController" bundle:[NSBundle mainBundle]];
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

- (void) showPurchases:(int)index
{
    SettingsNavController *controller = [[SettingsNavController alloc] initWithNibName:@"SettingsNavController" bundle:[NSBundle mainBundle]];
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

- (BOOL) categoriesOpen {
    return categoriesOpen;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil glViewController:(GlViewController*)glViewController
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.glController = glViewController;
        self.glController.navigationViewController = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.glController.view.layer.cornerRadius = self.separatingView.layer.cornerRadius = 5;
    [self.view insertSubview:[self.glController view] aboveSubview:self.separatingView];
    
    CGRect mainViewFrame = self.glController.view.frame;
    self.glController.view.frame = mainViewFrame;
    
    rectMapFull = mainViewFrame;
    rectMapCut = rectMapFull;
    
    CGFloat delta;
    
    rectMapCut.size.height -= delta;
    rectMapCut.origin.y += delta;
    
    layerMode = HCOSMLayer;

    currentPlacePin = -1;

}

- (void)viewDidAppear:(BOOL)animated {
    
    CGRect windowBounds = [[[UIApplication sharedApplication] keyWindow] bounds];
    //self.view.frame = windowBounds;
    
    if (windowBounds.size.height > 480) {
        if (IS_IPAD)
            self.shadow.image = [UIImage imageNamed:@"navigation_shadow_higher_ipad.png"];
        else
            self.shadow.image = [UIImage imageNamed:@"navigation_shadow_higher.png"];
        CGRect frame = self.shadow.frame;
        if (IS_IPAD)
        {
            frame.size.height = 1004;
        }
        else
            frame.size.height = 548;
        self.shadow.frame = frame;
    }

    
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.shouldShowRateScreen) {
        [appDelegate askForRate];
        appDelegate.shouldShowRateScreen = NO;
    }
    
    [self showRasterMap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGRect windowBounds = [[[UIApplication sharedApplication] keyWindow] bounds];
    //self.view.frame = windowBounds;
    
    if (windowBounds.size.height > 480) {
        if (IS_IPAD)
            self.shadow.image = [UIImage imageNamed:@"navigation_shadow_higher_ipad.png"];
        else
            self.shadow.image = [UIImage imageNamed:@"navigation_shadow_higher.png"];
        CGRect frame = self.shadow.frame;
        if (IS_IPAD)
        {
            frame.size.height = 1004;
        }
        else
            frame.size.height = 548;
        self.shadow.frame = frame;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showCategories:(id)sender {

    [UIView animateWithDuration:0.5f animations:^{
        CGRect glViewFrame = self.glController.view.frame;
        CGRect separatingFrame = self.separatingView.frame;

        if (glViewFrame.origin.x == 0) {
            separatingFrame.origin.x = glViewFrame.origin.x = 227;
            categoriesOpen = YES;
        }
        else {
            separatingFrame.origin.x = glViewFrame.origin.x =  0;
            categoriesOpen = NO;

        }
        self.glController.view.frame = glViewFrame;
        self.separatingView.frame = separatingFrame;
    }];
    
}

- (void) hideCategoriesAnimated:(BOOL)animated {
    CGFloat duration = animated ? 0.5f : 0;
        CGRect mainViewFrame = self.glController.view.frame;
        CGRect separatingFrame = self.separatingView.frame;
        mainViewFrame.origin.x = separatingFrame.origin.x = 0;
        categoriesOpen = NO;
        self.glController.view.frame = mainViewFrame;
        self.separatingView.frame = separatingFrame;
}

- (void) showFullMap {
    CGRect newRect = self.glController.view.frame;
    newRect.origin.y = rectMapFull.origin.y;
    newRect.size.height = rectMapFull.size.height;
    
    self.glController.view.frame = newRect;
    [self.glController moveModeButtonToFullScreen];
}

- (void) showCutMap {
    CGRect newRect = self.glController.view.frame;
    newRect.origin.y = rectMapCut.origin.y;
    newRect.size.height = rectMapCut.size.height;
    
    self.glController.view.frame = newRect;
    
    CGRect specialMapRect = newRect;
    specialMapRect.origin.y += 40;
    specialMapRect.size.height -= 40;
    self.glController.view.frame = specialMapRect;
    [self.glController moveModeButtonToCutScreen];
}

- (void) centerMapOnUser {
    [self.glController centerMapOnUser];
}

- (void) switchToLayerMode:(HCLayerMode)mode {
    if (mode == layerMode) {
        //If we're trying to set same layer, do nothing
        return;
    }

    //As layerMode could have changed after removing bookmarks layer, check once more
    if (mode != layerMode) {
        switch (mode) {
            case HCOSMLayer:
                layerMode = HCOSMLayer;
                break; 
                
            default:
                break;
        }
    }
}

- (void) showRasterMap {
    [self switchToLayerMode:HCOSMLayer];

}

- (void) centerMapOnPlace:(MPlace*)place {
    CGPoint placePosition = CGPointMake([place.posX floatValue], [place.posY floatValue]);
    self.glController.followUserGPS = NO;
    [self.glController setGeoPosition:placePosition withZoom:-1];
}

- (CGFloat) selectPlaceWithIndex:(NSInteger)index {
    MPlace *place = [[MHelper sharedHelper] getPlaceWithIndex:index];
    CGPoint placePosition = CGPointMake([place.posX floatValue], [place.posY floatValue]);
    
    self.glController.followUserGPS = NO;
    [self.glController scrollToGeoPosition:placePosition withZoom:60000];
    currentPlacePin = [self.glController setLocation:placePosition];
    Pin *pin = [self.glController getPin:currentPlacePin];
    return pin.distanceToUser;
}


- (CGFloat) radialDirectionOffsetToPlaceWithIndex:(NSInteger)index {
    MPlace *place = [[MHelper sharedHelper] getPlaceWithIndex:index];
    CGPoint placePosition = CGPointMake([place.posX floatValue], [place.posY floatValue]);
    return [glController radialOffsetToPoint:placePosition];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    if (IS_IPAD)
        return interfaceOrientation == UIInterfaceOrientationPortrait;// || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown;
    
    if (self.presentedViewController) {
            return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (BOOL)shouldAutorotate {
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations{
    if (IS_IPAD)
        return UIInterfaceOrientationMaskPortrait ;//| UIInterfaceOrientationMaskPortraitUpsideDown;
    if (self.presentedViewController) {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    return UIInterfaceOrientationMaskAll;
}


-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        returningFromLandscape = YES;
    } else {
        if (self.presentedViewController) {
            [self.presentedViewController dismissModalViewControllerAnimated:YES];
        }

        [self hideCategoriesAnimated:NO];
        if (IS_IPAD)
        {
            
        }
        else
        {
            [self showFullMap];
        }
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

}


@end

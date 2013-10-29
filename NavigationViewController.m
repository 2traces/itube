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
@synthesize headingBg;
@synthesize textBg;

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
//
//    self.glController.view.layer.cornerRadius = self.separatingView.layer.cornerRadius = 5;
//    [self.view insertSubview:[self.glController view] aboveSubview:self.separatingView];
    CGRect frame = self.glController.view.frame;
    frame.size = self.separatingView.frame.size;
    frame.origin = CGPointMake(0, 0);
    self.glController.view.frame = frame;
    self.glController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.separatingView addSubview:self.glController.view];
    
    self.headingBg.image = [[UIImage imageNamed:@"navbar_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
    self.textBg.image = [[UIImage imageNamed:@"toolbar_text_bg_lighted2"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
    self.shadow.image = [[UIImage imageNamed:@"navbar_shadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
//
//    CGRect mainViewFrame = self.glController.view.frame;
//    self.glController.view.frame = mainViewFrame;
//    
//    rectMapFull = mainViewFrame;
//    rectMapCut = rectMapFull;
//    
//    CGFloat delta;
//    
//    rectMapCut.size.height -= delta;
//    rectMapCut.origin.y += delta;
//    
//    layerMode = HCOSMLayer;
//
//    currentPlacePin = -1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(distanceUpdated:) name: @"distanceUpdated" object:nil];
    if(IS_IPAD){
        self.listButton.hidden = YES;
        self.distanceBg.hidden = YES;
        [self.headingView addSubview:self.distanceView];
        CGRect frame = self.textBg.frame;
        frame.origin.x -= self.distanceView.frame.size.width;
        self.textBg.frame = frame;
        frame = self.textField.frame;
        frame.origin.x -= self.distanceView.frame.size.width;
        self.textField.frame = frame;
        frame = self.distanceView.frame;
        frame.origin.y = 5;
        frame.origin.x = self.headingView.frame.size.width - frame.size.width;
        self.distanceView.frame = frame;
        self.distanceView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            frame = self.separatingView.frame;
            frame.origin.y += 20;
            frame.size.height -= 20;
            self.separatingView.frame = frame;
            
            frame = self.downloadButton.frame;
            frame.origin.y -= 20;
            self.downloadButton.frame = frame;
        }
    } else {

    }

}

- (void)distanceUpdated:(NSNotification*)notification {
    NSNumber *d = notification.object;
    if (d && [d floatValue] >=0) {
        //Show panel
        self.distanceView.hidden = NO;
        self.distanceLabel.text = [NSString stringWithFormat:@"%.2f", [d floatValue]];
    }
    else {
        //Hide panel
        self.distanceView.hidden = YES;
    }
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

//    [UIView animateWithDuration:0.5f animations:^{
//        CGRect glViewFrame = self.glController.view.frame;
//        CGRect separatingFrame = self.separatingView.frame;
//
//        if (glViewFrame.origin.x == 0) {
//            separatingFrame.origin.x = glViewFrame.origin.x = 227;
//            categoriesOpen = YES;
//        }
//        else {
//            separatingFrame.origin.x = glViewFrame.origin.x =  0;
//            categoriesOpen = NO;
//
//        }
//        self.glController.view.frame = glViewFrame;
//        self.separatingView.frame = separatingFrame;
//    }];
    
}

- (void) hideCategoriesAnimated:(BOOL)animated {
//    CGFloat duration = animated ? 0.5f : 0;
//        CGRect mainViewFrame = self.glController.view.frame;
//        CGRect separatingFrame = self.separatingView.frame;
//        mainViewFrame.origin.x = separatingFrame.origin.x = 0;
//        categoriesOpen = NO;
//        self.glController.view.frame = mainViewFrame;
//        self.separatingView.frame = separatingFrame;
}

- (void) showFullMap {
//    CGRect newRect = self.glController.view.frame;
//    newRect.origin.y = rectMapFull.origin.y;
//    newRect.size.height = rectMapFull.size.height;
//    
//    self.glController.view.frame = newRect;
//    [self.glController moveModeButtonToFullScreen];
}

- (void) showCutMap {
//    CGRect newRect = self.glController.view.frame;
//    newRect.origin.y = rectMapCut.origin.y;
//    newRect.size.height = rectMapCut.size.height;
//    
//    self.glController.view.frame = newRect;
//    
//    CGRect specialMapRect = newRect;
//    specialMapRect.origin.y += 40;
//    specialMapRect.size.height -= 40;
//    self.glController.view.frame = specialMapRect;
//    [self.glController moveModeButtonToCutScreen];
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

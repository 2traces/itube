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
#import "SpotsListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SuggestionsViewController.h"
#import "DownloadMapViewController.h"
#import "TubeSplitViewController.h"

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

//static NSDictionary *distanceAttributes;

-(IBAction)downloadOfflineMap:(id)sender {
    if (!self.downloadVC) {
        self.downloadVC = [[[DownloadMapViewController alloc] initWithNibName:@"DownloadMapViewController" bundle:[NSBundle mainBundle]] autorelease];
    }
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *root = appDelegate.window.rootViewController;
    if ([root isKindOfClass:[TubeSplitViewController class]]) {
        self.downloadVC.view.frame = CGRectMake(0, 0, [root viewSize].width, [root viewSize].height);

    }
    else {
        self.downloadVC.view.frame = self.view.frame;

    }
    if (IS_IPAD) {
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            CGRect frame = self.downloadVC.view.frame;
            frame.origin.y += 20;
            frame.size.height -= 40;
            self.downloadVC.view.frame = frame;
        }
    }
    else {
        CGRect frame = self.downloadVC.view.frame;

        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            frame.origin.y += 20;
        }
        else {
            frame.origin.y -= 20;
        }
        self.downloadVC.view.frame = frame;

    }

    self.downloadVC.view.alpha = 0;
    

    if ([root isKindOfClass:[TubeSplitViewController class]]) {
        [root.view addSubview:self.downloadVC.view];
    }
    else {
        [self.view addSubview:self.downloadVC.view];
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        self.downloadVC.view.alpha = 1;
    }];
    
}

-(IBAction)doneSearching:(UITextField *)sender {
    [self endedSearching];
}

-(IBAction)searchText:(UITextField *)sender
{
    [glController loadCitiesLikeThis:sender.text];
    
    if (IS_IPAD) {
        if ([sender.text length]) {
            if (!self.popover.isPopoverVisible) {
                [self.popover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            }
        }
        else {
            [self.popover dismissPopoverAnimated:YES];
        }

    }
    else {
        if ([sender.text length]) {
            [self.separatingView addSubview:self.suggestionsVC.tableView];
            self.suggestionsVC.tableView.frame = CGRectMake(0, 64, 320, self.separatingView.frame.size.height - 215 - 44);
            self.suggestionsVC.tableView.hidden = NO;
        }
        else {
            self.suggestionsVC.tableView.hidden = YES;

        }
    }
}

- (void) endedSearching {
    [self.view endEditing:YES];
    if (IS_IPAD) {
        [self.popover dismissPopoverAnimated:YES];
    }
    else {
        self.suggestionsVC.tableView.hidden = YES;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    //do whatever you need

    if (IS_IPAD) {
//        [self.popover dismissPopoverAnimated:YES];
    }
    else {
        self.suggestionsVC.tableView.hidden = YES;
    }
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
//    distanceAttributes = [[NSDictionary dictionaryWithObjectsAndKeys:
//     [UIFont fontWithName:@"HelveticaNeue-Italic" size:17], UITextAttributeFont,
//     [UIColor colorWithRed:124.0/255.0f green:124.0/255.0f blue:124.0/255.0f alpha:1.0f], UITextAttributeTextColor,
//     [UIColor whiteColor], UITextAttributeTextShadowColor,
//                           [NSValue valueWithUIOffset:UIOffsetMake(-0.5, 0.5)], UITextAttributeTextShadowOffset, nil] retain];
//
//    self.glController.view.layer.cornerRadius = self.separatingView.layer.cornerRadius = 5;
//    [self.view insertSubview:[self.glController view] aboveSubview:self.separatingView];
    self.suggestionField.placeholder = NSLocalizedString(@"City search", @"");
    self.suggestionsVC = [[[SuggestionsViewController alloc] initWithNibName:@"SuggestionsViewController" bundle:[NSBundle mainBundle]] autorelease];
    self.suggestionsVC.navVC = self;
    [self.suggestionsVC view];
    if (IS_IPAD) {
        self.popover = [[[UIPopoverController alloc] initWithContentViewController:self.suggestionsVC] autorelease];
        self.popover.popoverContentSize = CGSizeMake(320, 44+73+20);
        if ([self.popover respondsToSelector:@selector(setBackgroundColor:)]) {
            [self.popover setBackgroundColor:[UIColor colorWithRed:223.0f/255.0f green:223.0f/255.0f blue:223.0f/255.0f alpha:1.0f]];
        }
    }
    else {
        [self.separatingView addSubview:self.suggestionsVC.tableView];
        self.suggestionsVC.tableView.frame = CGRectMake(0, 64, 320, self.separatingView.frame.size.height - 215 - 44);
        self.suggestionsVC.tableView.hidden = YES;
    }
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(distanceUpdated:) name: @"kMapMoved" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    if (![CLLocationManager locationServicesEnabled]) {
        self.distanceView.hidden = YES;
    }
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
        self.listSplitButton.hidden = NO;
    } else {
        self.listSplitButton.hidden = YES;
    }
    [self distanceUpdated:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData:) name:nSEARCH_RESULTS_READY object:nil];
    
}

- (void)updateData:(NSNotification*)notification {
    NSArray *items = [notification object];
    if (IS_IPAD) {
        NSInteger count = [items count];
        if (count > 10) {
            count = 10;
        }
        self.popover.popoverContentSize = CGSizeMake(320, 44*count+73+20);
    }
    else {
        if ([items count] == 0) {
            self.suggestionsVC.tableView.hidden = YES;
        }
        else {
            self.suggestionsVC.tableView.hidden = NO;
        }
    }
}

-(IBAction)showSpotsList:(id)sender {
    SpotsListViewController *vc = [[[SpotsListViewController alloc] initWithNibName:@"SpotsListViewController" bundle:[NSBundle mainBundle]] autorelease];
    UINavigationController *nvc = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    [self presentViewController:nvc animated:YES completion:^{
        
    }];
}

-(IBAction)distanceTapped:(id)sender {
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    GlViewController *gl = appDelegate.glViewController;
    [gl centerMapOnUser];
//    self.distanceLabel.attributedText = [[[NSAttributedString alloc] initWithString:@"0 km" attributes:distanceAttributes] autorelease];
    self.distanceLabel.text = @"0 km";
}

- (void)distanceUpdated:(NSNotification*)notification {
    tubeAppDelegate *appd = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
    CGFloat distance = [appd.glViewController distanceToMapCenter];
    CGFloat direction = [appd.glViewController radialOffsetToMapCenter];
    
    NSString *distanceString = nil;
    if (distance < 10.0) {
        distanceString = [NSString stringWithFormat:@"%.1f km", distance];
    } else {
        distanceString = [NSString stringWithFormat:@"%.0f km", distance];
    }
    
//    self.distanceLabel.attributedText = [[[NSAttributedString alloc] initWithString:distanceString attributes:distanceAttributes] autorelease];
    self.distanceLabel.text = distanceString;
    
    self.directionArrow.transform = CGAffineTransformMakeRotation(0);
    self.directionArrow.transform = CGAffineTransformMakeRotation(direction+M_PI);
}

- (void)viewDidAppear:(BOOL)animated {
    
    CGRect windowBounds = [[[UIApplication sharedApplication] keyWindow] bounds];
    //self.view.frame = windowBounds;
    
//    if (windowBounds.size.height > 480) {
//        if (IS_IPAD)
//            self.shadow.image = [UIImage imageNamed:@"navigation_shadow_higher_ipad.png"];
//        else
//            self.shadow.image = [UIImage imageNamed:@"navigation_shadow_higher.png"];
//        CGRect frame = self.shadow.frame;
//        if (IS_IPAD)
//        {
//            frame.size.height = 1004;
//        }
//        else
//            frame.size.height = 548;
//        self.shadow.frame = frame;
//    }

    
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
    
//    if (windowBounds.size.height > 480) {
//        if (IS_IPAD)
//            self.shadow.image = [UIImage imageNamed:@"navigation_shadow_higher_ipad.png"];
//        else
//            self.shadow.image = [UIImage imageNamed:@"navigation_shadow_higher.png"];
//        CGRect frame = self.shadow.frame;
//        if (IS_IPAD)
//        {
//            frame.size.height = 1004;
//        }
//        else
//            frame.size.height = 548;
//        self.shadow.frame = frame;
//    }
    
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

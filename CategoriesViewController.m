//
//  CategoriesViewController.m
//  tube
//
//  Created by Alexey on 5/11/12.
//
//

#import "CategoriesViewController.h"
#import "CategoryCell.h"
#import "ManagedObjects.h"
#import "SettingsNavController.h"
#import "tubeAppDelegate.h"
#import "WeatherHelper.h"
#import "WeatherView.h"

@interface CategoriesViewController ()

@end

@implementation HCTeaserObject

@synthesize image;
@synthesize name;
@synthesize urlString;

+ (id) teaserObjectWithName:(NSString*)name image:(UIImage*)image url:(NSString*)url {
    HCTeaserObject *object = [HCTeaserObject new];
    object.name = name;
    object.image = image;
    object.urlString = url;
    return [object autorelease];
}


@end

@implementation CategoriesViewController

@synthesize tableView;
@synthesize scrollView;
@synthesize buttonSettings;
@synthesize navigationDelegate;
@synthesize categories;
@synthesize teasers;

- (IBAction)showSettings:(id)sender {
   // [self.navigationDelegate showSettings];
    if (IS_IPAD)
        [self showiPadSettingsModalView];
    else
        [self.navigationDelegate showSettings];
}

-(void)showiPadSettingsModalView
{
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController showiPadSettingsModalView];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) initializeCategories {
    self.categories = [[MHelper sharedHelper] getCategoriesList];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weatherInfoRecieved:) name:@"kWeatherInfo" object:nil];
}

- (void) initializeTeasers {
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];

//    self.teasers = [NSArray arrayWithObjects:
//                        [HCTeaserObject teaserObjectWithName:@"Berlin"
//                                                       image:[UIImage imageNamed:@"tr_berlin"]
//                                                         url:@"https://itunes.apple.com/us/app/angry-birds-star-wars/id557137623"],
//                        [HCTeaserObject teaserObjectWithName:@"Paris"
//                                                       image:[UIImage imageNamed:@"tr_paris"]
//                                                         url:@"https://itunes.apple.com/us/app/angry-birds-space/id499511971"],
//                        [HCTeaserObject teaserObjectWithName:@"Venice"
//                                                       image:[UIImage imageNamed:@"tr_venice"]
//                                                         url:@"https://itunes.apple.com/us/app/bad-piggies/id533451786"], nil];
    
    self.teasers = [appDelegate getTeasersForMaps];
    
    CGFloat offset = 10;
    
    for (HCTeaserObject *teaser in teasers) {
        UIView *viewTeaser = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, 122)];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 81, 81);
        [button setImage:teaser.image forState:UIControlStateNormal];
        [viewTeaser addSubview:button];
        button.center = CGPointMake(viewTeaser.center.x, viewTeaser.center.y - 3.0f);
        [button addTarget:self action:@selector(openTeaser:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 100 + [teasers indexOfObject:teaser];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, 20)];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"MyriadPro-Regular" size:14.0f];
        label.textColor = [UIColor darkGrayColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = teaser.name;
        [viewTeaser addSubview:[label autorelease]];
        label.center = CGPointMake(viewTeaser.center.x, 112.0f);
        CGRect frame = [viewTeaser frame];
        frame.origin = CGPointMake(offset, 0);
        viewTeaser.frame = frame;
        offset += 90;
        [self.scrollView addSubview:[viewTeaser autorelease]];
    }
    
    offset += 10;
    
    self.scrollView.contentSize = CGSizeMake(offset, 122);
    
}

- (void)openTeaser:(id)sender {
    if (![sender isKindOfClass:[UIButton class]] || ((UIButton*)sender).tag < 100) {
        return;
    }
    NSInteger index = ((UIButton*)sender).tag % 100;
    HCTeaserObject *teaser = [self.teasers objectAtIndex:index];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:teaser.urlString]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeCategories];
    // Do any additional setup after loading the view from its nib.

    CGRect windowBounds = [[[UIApplication sharedApplication] keyWindow] bounds];
    //self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, windowBounds.size.height);
    
    [self reloadCategories];
}

- (void) reloadCategories {
    [self.tableView reloadData];
    
    currentIndex = 1;
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    MCategory *category = self.categories[1];
    [self.navigationDelegate selectCategoryWithIndex:[category.index integerValue]];
    
    [self initializeTeasers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    self.buttonSettings = nil;
    self.scrollView = nil;
    self.tableView = nil;
    [super viewDidUnload];
}

- (void) dealloc {
    self.buttonSettings = nil;
    self.scrollView = nil;
    self.tableView = nil;
    [super dealloc];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath  {
   // NSLog(@"DID DESELECT");
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"DID SELECT...");

    currentIndex = indexPath.row;
    MCategory *category = self.categories[indexPath.row];
    [self.navigationDelegate selectCategoryWithIndex:[category.index integerValue]];
   // NSLog(@"DID SELECT!");

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    if ([[[WeatherHelper sharedHelper] getWeatherInformation] count]>0) {
        return 70.0;
    } else {
        return 0;
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    WeatherView *view;
    
    if ([[WeatherHelper sharedHelper] getWeatherInformation]) {
        view = [[WeatherView alloc]  initWithFrame:CGRectMake(0, 0, 219, 68)];
    }
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.categories count];
}


- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCategory *category = self.categories[indexPath.row];
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];

    NSString *imagePath = [NSString stringWithFormat:@"%@/categories/%@", appDelegate.mapDirectoryPath, category.image_normal];
    UIImage *imageNormal = [UIImage imageWithContentsOfFile:imagePath];
    
    imagePath = [NSString stringWithFormat:@"%@/categories/%@", appDelegate.mapDirectoryPath, category.image_highlighted];
    UIImage *imageHighlighted = [UIImage imageWithContentsOfFile:imagePath];
    CategoryCell *cell = [[CategoryCell alloc] initwithTitle:category.name image:imageNormal highlightedImage:imageHighlighted];
    return [cell autorelease];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)] autorelease];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

-(void)weatherInfoRecieved:(NSNotification*)note
{
    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
}


@end

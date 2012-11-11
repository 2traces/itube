//
//  NavigationViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 5/11/12.
//
//

#import "NavigationViewController.h"
#import "CategoriesViewController.h"
#import "PhotosViewController.h"
#import "MainViewController.h"
#import "MainView.h"

@interface NavigationViewController ()

@end

@implementation NavigationViewController

@synthesize categoriesController;
@synthesize photosController;
@synthesize mainController;
@synthesize glController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mainViewController:(MainViewController*)mainViewController glViewController:(GlViewController*)glViewController
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.mainController = mainViewController;
        self.mainController.navigationViewController = self;

        self.glController = glViewController;
        self.glController.navigationViewController = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.categoriesController = [[[CategoriesViewController alloc] initWithNibName:@"CategoriesViewController" bundle:[NSBundle mainBundle]] autorelease];
    self.categoriesController.navigationDelegate = self;
    self.photosController = [[[PhotosViewController alloc] initWithNibName:@"PhotosViewController" bundle:[NSBundle mainBundle]]  autorelease];
    self.photosController.navigationDelegate = self;
    [self.view addSubview:[self.categoriesController view]];
    [self.view addSubview:[self.mainController view]];
    [self.view addSubview:[self.photosController view]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showCategories:(id)sender {
    [UIView animateWithDuration:0.5f animations:^{
        CGRect mainViewFrame = self.mainController.view.frame;
        CGRect photosViewFrame = self.photosController.view.frame;
        if (mainViewFrame.origin.x == 0) {
            mainViewFrame.origin.x = photosViewFrame.origin.x = 227;
            [self.photosController.buttonCategories setTitle:@"HIDE" forState:UIControlStateNormal];
        }
        else {
            mainViewFrame.origin.x = photosViewFrame.origin.x = 0;
            [self.photosController.buttonCategories setTitle:@"SHOW" forState:UIControlStateNormal];

        }
        self.mainController.view.frame = self.glController.view.frame = mainViewFrame;
        self.photosController.view.frame = photosViewFrame;
    }];
}

- (void) showRasterMap {
    [self.view insertSubview:self.glController.view belowSubview:self.mainController.view];
    [self.mainController.view removeFromSuperview];
}

- (void) showMetroMap {
    [self.view insertSubview:self.mainController.view belowSubview:self.glController.view];

    [self.glController.view removeFromSuperview];
}

@end

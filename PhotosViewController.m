//
//  PhotosViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 5/11/12.
//
//

#import "PhotosViewController.h"

@interface PhotosViewController ()

@end

@implementation PhotosViewController

@synthesize scrollPhotos;
@synthesize buttonCategories;
@synthesize navigationDelegate;
@synthesize disappearingView;
@synthesize panelView;

- (IBAction)showCategories:(id)sender {
    [self.navigationDelegate showCategories:self];
}

- (IBAction)showBookmarks:(id)sender {
    [self.navigationDelegate showBookmarks:self];

}



- (IBAction)showHidePhotos:(id)sender {
    [self.navigationDelegate showHidePhotos:self];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped:)];
    tapGR.delegate = self;
    [self.scrollPhotos addGestureRecognizer:tapGR];
    [tapGR autorelease];
}

- (void)photoTapped:(UITapGestureRecognizer *)recognizer {
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    
    for (int i = 0; i < 10; i++) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Place %i", i+1], @"title", @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", @"text", nil];
        [array addObject:dict];
    }
    
    [self.navigationDelegate showReaderWithItems:array activePage:0];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIControl class]]) {
        // we touched a button, slider, or other UIControl
        return NO; // ignore the touch
    }
    return YES; // handle the touch
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

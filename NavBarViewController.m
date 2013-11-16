//
//  NavBarViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 1/11/13.
//
//

#import "NavBarViewController.h"
#import "SpotsListViewController.h"
#import "SpotInfoViewController.h"

@interface NavBarViewController ()

@end

@implementation NavBarViewController

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
    self.list = [[[SpotsListViewController alloc] initWithNibName:@"SpotsListViewController" bundle:[NSBundle mainBundle]] autorelease];
    self.list.navBarVC = self;
    self.list.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.list.view.frame = CGRectMake(0, 0, self.container.frame.size.width, self.container.frame.size.height);
    [self.container addSubview:self.list.view];
    CGFloat yOffset = 44;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        yOffset += 20;
    }
    UIImageView *shadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, yOffset - 1, 320, 34)];
    shadow.image = [[UIImage imageNamed:@"navbar_shadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
    [self.view addSubview:shadow];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushVC:(SpotInfoViewController*)vc animated:(BOOL)animated {
    if (self.info) {
        self.info.spotInfo = vc.spotInfo;
        [self.info setup];
        return;
    }
    self.info = vc;
    self.info.navBarVC = self;
    self.info.view.frame = CGRectMake(self.list.view.frame.size.width, 0, self.list.view.frame.size.width, self.list.view.frame.size.height);
    self.info.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.container addSubview:self.info.view];
    CGFloat duration = animated ? 0.5f : 0;
    [UIView animateWithDuration:duration animations:^{
        CGRect infoFrame = self.info.view.frame;
        CGRect listFrame = self.list.view.frame;
        
        infoFrame.origin.x = 0;
        listFrame.origin.x = - listFrame.size.width;
        
        self.info.view.frame = infoFrame;
        self.list.view.frame = listFrame;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)popVCAnimated:(BOOL)animated {
    [self.bar setItems:@[self.list.navigationItem] animated:NO];
    CGFloat duration = animated ? 0.5f : 0;
    [UIView animateWithDuration:duration animations:^{
        CGRect infoFrame = self.info.view.frame;
        CGRect listFrame = self.list.view.frame;
        
        infoFrame.origin.x = listFrame.size.width;
        listFrame.origin.x = 0;
        
        self.info.view.frame = infoFrame;
        self.list.view.frame = listFrame;
    } completion:^(BOOL finished) {
        [self.info.view removeFromSuperview];
        self.info = nil;
    }];
}

@end

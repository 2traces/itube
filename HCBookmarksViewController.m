//
//  HCBookmarksViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 14/11/12.
//
//

#import "HCBookmarksViewController.h"
#import "HCBookmarkItemView.h"

@interface HCBookmarksViewController ()

@end

@implementation HCBookmarksViewController

@synthesize items;
@synthesize scrollView;

- (IBAction)close:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
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
    CGFloat offset = 50;
    for (int i = 0; i < 10; i ++) {
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"HCBookmarkItemView" owner:self options:nil];
        HCBookmarkItemView *itemView = (HCBookmarkItemView*)[nibObjects objectAtIndex:0];
        [itemView setImage:[UIImage imageNamed:@"sample_photo"] text:@"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." placeName:[NSString stringWithFormat:@"Place %i", i+1] placeDistance:@"Some really long address, or distance."];
        [self.items addObject:itemView];
        [self.scrollView addSubview:itemView];
        CGRect frame = itemView.frame;
        frame.origin.y = offset;
        offset += itemView.frame.size.height;
        itemView.frame = frame;
    }
    self.scrollView.contentSize = CGSizeMake(320.0f, offset);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

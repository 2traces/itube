//
//  SuggestionsViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 4/11/13.
//
//

#import "SuggestionsViewController.h"
#import "GlViewController.h"
#import "tubeAppDelegate.h"
#import "NavigationViewController.h"

@interface SuggestionsViewController ()

@end

@implementation SuggestionsViewController

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

    self.headingBg.image = [[UIImage imageNamed:@"suggestions_heading"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];

    UIImageView *shadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, 320, 34)];
    shadow.image = [[UIImage imageNamed:@"navbar_shadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
    [self.view addSubview:shadow];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData:) name:nSEARCH_RESULTS_READY object:nil];
    
}

- (void)updateData:(NSNotification*)notification {
    NSArray *items = [notification object];
    if ([items isKindOfClass:[NSArray class]]) {
        self.items = items;
        [self.tableView reloadData];
    }
}

- (void)hide {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Search results";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SuggestionItemCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    cell.textLabel.text = [[self.items objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    GlViewController *gl = appDelegate.glViewController;
    NSDictionary *item = [self.items objectAtIndex:indexPath.row];
    [gl scrollToGeoPosition:CGPointMake([item[@"lat"] floatValue], [item[@"lon"] floatValue]) withZoom:-1];
    [self.navVC endedSearching];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


@end

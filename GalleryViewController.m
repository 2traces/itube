//
//  GalleryViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GalleryViewController.h"
#import "ManagedObjects.h"

@interface GalleryViewController ()

@end

@implementation GalleryViewController

@synthesize label;
@synthesize scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setupScrollView {
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * [images count], self.scrollView.frame.size.height);
    self.scrollView.pagingEnabled = YES;
    CGFloat offset = 0;
    for (MPhoto *photo in images) {
        NSString *rasterPath = [[NSBundle mainBundle] pathForResource:@"vector" ofType:nil];
        NSString *fn = [NSString stringWithFormat:@"%@/photos/%@", rasterPath, photo.fileName];
        UIImage *image = [UIImage imageWithContentsOfFile:fn];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(offset, 0, self.scrollView.frame.size.width - 20, self.scrollView.frame.size.height)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        imageView.image = image;
        
        offset += self.scrollView.frame.size.width;
        
        [self.scrollView addSubview:imageView];
        [imageView autorelease];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.label.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:16.0f];
    images = [[[MHelper sharedHelper] getPhotoList] retain];
    [self setupScrollView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [images release];
    images = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

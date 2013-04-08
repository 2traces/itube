//
//  HtmlGallery.m
//  tube
//
//  Created by alex on 08.04.13.
//
//

#import "HtmlGallery.h"

@implementation HtmlGallery

@synthesize mainImage;

- (id)initWithMedia:(MMedia *)media withParent:(UIView *)parent withAppDelegate:(tubeAppDelegate *)appDelegate{
    self = [super initWithFrame:parent.frame];
    if (self) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:parent.frame];
        [webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        webView.delegate = self;
        NSString *htmlPath = [NSString stringWithFormat:@"%@/%@", appDelegate.mapDirectoryPath, media.filename];
        NSURL* url = [NSURL fileURLWithPath:htmlPath];
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
        [self addSubview:webView];
    }
    return self;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSLog(@"request %@", request.description);
    return YES;
}

- (void)dealloc{
    if (self.mainImage != nil) {
        [self.mainImage release];
        self.mainImage = nil;
    }
    [super dealloc];
}

@end

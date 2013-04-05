//
//  WebViewGalleryOpener.m
//  tube
//
//  Created by alex on 05.04.13.
//
//

#import "WebViewGalleryOpener.h"

@implementation WebViewGalleryOpener

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSLog(@"request %@", request.description);
    return YES;
}

@end

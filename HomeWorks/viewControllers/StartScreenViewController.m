//
// Created by bsideup on 4/4/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "StartScreenViewController.h"
#import "AFHTTPRequestOperation.h"
#import "RXMLElement.h"
#import "NSObject+homeWorksServiceLocator.h"


@implementation StartScreenViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSURLRequest*request = [NSURLRequest requestWithURL:self.catalogDownloadUrl];
    AFHTTPRequestOperation *catalogDownloadOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    [catalogDownloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Catalog succesfully downloaded");

        RXMLElement *rxml = [RXMLElement elementFromXMLData:operation.responseData];
        NSLog(@"%@", [[[rxml child:@"term"] child:@"subject"] attribute:@"name"]);

        // Check that file is parsed fine
        if([rxml attribute:@"baseurl"]) {
            [self.catalogRxml initFromXMLData:operation.responseData];
            [operation.responseString writeToFile:self.catalogFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }

        [self performSegueWithIdentifier:@"showList" sender:self];
    }                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error downloading catalog!");
        [self performSegueWithIdentifier:@"showList" sender:self];
    }];

    [catalogDownloadOperation start];
}
@end
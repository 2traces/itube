//
// Created by bsideup on 4/4/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "NSObject+homeWorksServiceLocator.h"


@implementation NSObject (homeWorksServiceLocator)


-(NSURL *)catalogDownloadUrl {

    static NSURL *catalogDownloadUrl;

    if(catalogDownloadUrl == nil) {
        catalogDownloadUrl = [NSURL URLWithString:@"http://www.trylogic.ru/homeworks/catalog.xml"];
    }

    return catalogDownloadUrl;
}

- (NSString *)catalogFilePath {
    static NSString *catalogFilePath;

    if(catalogFilePath == nil) {
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        catalogFilePath = [documentsDirectory stringByAppendingPathComponent:@"catalog.xml"];
    }

    return catalogFilePath;
}


-(RXMLElement *)catalogRxml {
    static RXMLElement *catalogRxml;

    if(catalogRxml == nil) {
        catalogRxml = [RXMLElement elementFromXMLString:[NSString stringWithContentsOfFile:self.catalogFilePath encoding:NSUTF8StringEncoding error:nil] encoding:NSUTF8StringEncoding];
    }

    return catalogRxml;
}

@end
//
// Created by bsideup on 4/4/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "RXMLElement.h"

@interface NSObject (homeWorksServiceLocator)

-(NSURL *)catalogDownloadUrl;

-(NSString *)catalogFilePath;

-(RXMLElement *)catalogRxml;

@end
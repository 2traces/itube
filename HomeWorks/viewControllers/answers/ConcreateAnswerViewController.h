//
// Created by Sergey Egorov on 4/17/13.
// Copyright (c) 2013 Trylogic. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>

@class RXMLElement;


@interface ConcreateAnswerViewController : QLPreviewController

@property(nonatomic) RXMLElement *term;
@property(nonatomic) RXMLElement *subject;
@property(nonatomic) RXMLElement *book;

@property (nonatomic) BOOL purchased;

- (id)initWithTerm:(RXMLElement *)term subject:(RXMLElement *)subject book:(RXMLElement *)book purchased:(BOOL)purchased;

@end
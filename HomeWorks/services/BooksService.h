//
// Created by Sergey Egorov on 6/30/13.
// Copyright (c) 2013 Trylogic. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface BooksService : NSObject


-(BOOL)isAvailableOfflineWithTermId:(NSString *)termId withSubjectId:(NSString *)subjectId withBookId:(NSString *)bookId;

@end
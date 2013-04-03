//
// Created by bsideup on 01.11.12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class TLWhenObserver;

@interface NSObject (TLBindings)

- ( TLWhenObserver * ) bind:(NSString *)sourcePropertyKeyPath
				 toProperty:(NSString *)targetPropertyKeyPath
						 of:(id)targetPropertyOwner
		 withTransformation:(id (^)(id))aValueBlock;

- ( TLWhenObserver * ) bind:(NSString *)sourcePropertyKeyPath
				 toProperty:(NSString *)targetPropertyKeyPath
						 of:(id)targetPropertyOwner;

- ( TLWhenObserver * ) bindString:(NSString *)sourcePropertyKeyPath
					   toProperty:(NSString *)targetPropertyKeyPath
							   of:(id)targetPropertyOwner
				 withStringFormat:(NSString *)stringFormat;


-(TLWhenObserver *) whenProperty:(NSString *)sourcePropertyKeyPath
					 isChangedDo:(void (^)(id))aBlock;
@end
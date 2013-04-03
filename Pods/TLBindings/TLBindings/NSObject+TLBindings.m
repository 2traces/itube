//
// Created by bsideup on 01.11.12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "NSObject+TLBindings.h"
#import "TLWhenObserver.h"

// #define TL_DEBUG_BINDINGS

@implementation NSObject (TLBindings)

- ( TLWhenObserver * ) bind:(NSString *)sourcePropertyKeyPath
				 toProperty:(NSString *)targetPropertyKeyPath
						 of:(id)targetPropertyOwner
{
	return [self bind:sourcePropertyKeyPath toProperty:targetPropertyKeyPath of:targetPropertyOwner withTransformation:nil];
}

- ( TLWhenObserver * ) bindString:(NSString *)sourcePropertyKeyPath
					   toProperty:(NSString *)targetPropertyKeyPath
							   of:(id)targetPropertyOwner
				 withStringFormat:(NSString *)stringFormat
{
	return [self bind:sourcePropertyKeyPath toProperty:targetPropertyKeyPath of:targetPropertyOwner withTransformation:^( id newValue )
	{
		return [NSString stringWithFormat:stringFormat, newValue];
	}];
}


- ( TLWhenObserver * ) bind:(NSString *)sourcePropertyKeyPath
				 toProperty:(NSString *)targetPropertyKeyPath
						 of:(id)targetPropertyOwner
		 withTransformation:(id (^)(id))aValueBlock
{
	TLWhenObserver *observer = [[TLWhenObserver alloc] initWithProperty:targetPropertyKeyPath of:targetPropertyOwner doBlock:^( id newValue )
	{
		#ifdef TL_DEBUG_BINDINGS
		NSLog( @"property %@ of %@ is changed to: %@", targetPropertyKeyPath, targetPropertyOwner, newValue );
		#endif

		[self setValue:( aValueBlock ? aValueBlock( newValue ) : newValue ) forKeyPath:sourcePropertyKeyPath];
	}];

	return observer;
}


- ( TLWhenObserver * ) whenProperty:(NSString *)sourcePropertyKeyPath
						isChangedDo:(void (^)(id))aBlock
{
	TLWhenObserver *observer = [[TLWhenObserver alloc] initWithProperty:sourcePropertyKeyPath of:self doBlock:aBlock];

	return observer;
}

@end
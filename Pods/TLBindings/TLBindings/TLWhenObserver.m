//
// Created by bsideup on 31.10.12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TLWhenObserver.h"


@implementation TLWhenObserver
{

	NSString *property;
	NSObject *of;

	void(^block)( id );

}
- ( id ) initWithProperty:(NSString *)aProperty
					   of:(NSObject *)aOf
				  doBlock:(void (^)(id))aBlock
{
	if ( self = [super init] )
	{
		property = aProperty;
		of = aOf;
		block = aBlock;

		[of addObserver:self forKeyPath:aProperty options:NSKeyValueObservingOptionNew context:NULL];

		block( [of valueForKeyPath:property] );
	}

	return self;
}

- ( void ) observeValueForKeyPath:(NSString *)keyPath
						 ofObject:(id)object
						   change:(NSDictionary *)change
						  context:(void *)context
{
	if ( object == of && [keyPath isEqualToString:property] )
	{
		block( [change valueForKey:NSKeyValueChangeNewKey] );
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- ( void ) dealloc
{
	[of removeObserver:self forKeyPath:property];
	of = nil;
	property = nil;
	block = nil;
}


@end
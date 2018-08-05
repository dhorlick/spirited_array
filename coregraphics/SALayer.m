//
//  SALayer.m
//  spiritedarray
//
//  Created by Dave Horlick on 3/13/13.
//  Copyleft 2013 River Porpoise Software
//

#import "SALayer.h"

@implementation SALayer

- (id)init
{
    [NSException raise:@"Unsupported Operation Exception"
                format:@"Call initWith:designatedBounded, instead at %d", (int)__LINE__];
    
    return self;
}

-(id)initWithViewHelper: (SAViewHelper*) designatedViewHelper
{
    self = [super init];
    if (self)
    {
        viewHelper = designatedViewHelper;
        // self.frameIndex = 0;
        self.timeValue = 0;
        [self setNeedsDisplay];
    }
    
    return self;
}

- (id)initWithLayer:(id)layer
{
	if (self = [super initWithLayer:layer])
    {
		if ([layer isKindOfClass:[SALayer class]])
        {
			SALayer* other = (SALayer*) layer;
			self.timeValue = other.timeValue;
            viewHelper = [other viewHelper];
		}
	}
	
	return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
	if ([key isEqualToString:@"timeValue"])
    {
		return YES;
	}
	
	return [super needsDisplayForKey:key];
}


-(void)drawInContext:(CGContextRef)context
{
    [viewHelper drawRect:[self bounds] Context:context Frame:self.timeValue];
}

-(SAViewHelper*) viewHelper
{
    return viewHelper;
}

@dynamic timeValue;

@end

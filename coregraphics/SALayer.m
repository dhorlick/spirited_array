//
//  SALayer.m
//  spiritedarray
//
//  Created by Dave Horlick on 3/13/13.
//  Copyleft 2013 River Porpoise Software
//

#import "SALayer.h"
#import "SAAppDelegate.h"

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
		self.blurRadius = 0;
        self.timeValue = 0;
		[self updateBlurLayer];
        [self setNeedsDisplay];
    }
	
    return self;
}

-(void)updateBlurLayer
{
	// NSLog(@"updateBlurLayer: starting...");
	if (self.blurRadius != 0)
	{
		// NSLog(@"updateBlurLayer: blurring...");
		if (blurLayer == nil)
		{
			// NSLog(@"allocating a new blurLayer");
			blurLayer = [CALayer layer];
			[self addSublayer:blurLayer];  // thanks, https://stackoverflow.com/a/2822216/1634801
		}
		
		CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
		[blurFilter setDefaults];
		[blurFilter setValue: [NSNumber numberWithFloat:self.blurRadius] forKey:@"inputRadius"];
		blurLayer.backgroundFilters = [NSArray arrayWithObject:blurFilter];
	}
	else
	{
		if (blurLayer != nil)
		{
			[blurLayer removeFromSuperlayer];
			blurLayer = nil;
		}
	}
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

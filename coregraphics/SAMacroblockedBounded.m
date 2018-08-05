//
//  SAH264Bounded.m
//  spiritedarray
//
//  Created by Dave Horlick on 9/22/13.
//  Copyleft 2013 River Porpoise Software
//

#import "SAMacroblockedBounded.h"

@implementation SAMacroblockedBounded

-(id)initWithBounded:(NSObject*) designatedBounded AndMacroblockOfWidth:(uint)designatedMacroblockWidth AndHeight:(uint)designatedMacroblockHeight
{
    self = [super init];
    if (self)
    {
        if(![designatedBounded respondsToSelector:@selector(bounds)])
        {
            [NSException raise:@"MyDelegate Exception"
                        format:@"Parameter lacks a bounds selector at %d", (int)__LINE__];
        }
        
        if (designatedMacroblockWidth==0U)
        {
            [NSException raise:@"IllegalArgument" format:@"Macroblock width cannot be zero."];
        }
        if (designatedMacroblockHeight==0U)
        {
            [NSException raise:@"IllegalArgument" format:@"Macroblock height cannot be zero."];
        }
        
        _bounded = designatedBounded;
        macroblockWidth = designatedMacroblockWidth;
        macroblockHeight = designatedMacroblockHeight;
    }
    
    return self;
}

-(NSRect)bounds
{
    NSRect bounds = (NSRect)[_bounded bounds];
    return [SAMacroblockedBounded makeRectWithWidth:macroblockWidth * (int)ceil((double)bounds.size.width / (double)macroblockWidth)
                                             Height:macroblockHeight * (int)ceil((double)bounds.size.height / (double)macroblockHeight)];
}

+(NSRect)makeRectWithWidth:(int) width Height:(int) height
{
    NSRect myRect;
    
    myRect.origin.x    = 0;
    myRect.origin.y    = 0;
    myRect.size.width  = width;
    myRect.size.height = height;
    
    return myRect;
}

-(NSString *)description
{
    NSRect bounds = [self bounds];
    return [NSString stringWithFormat:@"<SAMacroblockedBounded: x=%f, y=%f, width=%f, height=%f (macroblock width=%u, height=%u)>", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height, macroblockWidth, macroblockHeight];
}

@end

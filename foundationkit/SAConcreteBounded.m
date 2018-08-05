//
//  SAConcreteBounded.m
//  spiritedarray
//
//  Created by Dave Horlick on 10/4/13.
//  Copyleft 2013 River Porpoise Software
//

#import "SAConcreteBounded.h"

@implementation SAConcreteBounded

-(id) initWith: (NSRect)designatedBounds
{
    if (self = [super init])
    {
        bounds = designatedBounds;
    }
    
    return self;
}

-(NSRect) bounds
{
    return bounds;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"<SAConcreteBounded: x=%f, y=%f, widht=%f, height=%f>", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height];
}

@end

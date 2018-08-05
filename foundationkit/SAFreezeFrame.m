//
//  SAFreezeFrame.m
//  spiritedarray
//
//  Created by Dave Horlick on 11/11/12.
//  Copyleft 2012 River Porpoise Software
//

#import "SAFreezeFrame.h"

@implementation SAFreezeFrame

-(id) initWith: (SpiritedArray*) designatedSpiritedArray Frame:(uint) designatedFrozenFrame
{
    if (self = [super init])
    {
        spiritedArray = designatedSpiritedArray;
        frozenFrame = designatedFrozenFrame;
    }
    
    return self;
}

-(uint) frames
{
    return 1;
}

-(SpiritedArray*) spiritedArray
{
    return spiritedArray;
}

-(uint) width
{
    return [spiritedArray width];
}

-(uint) height
{
    return [spiritedArray height];
}

-(SAColorType) pixelColorAtFrame:(uint)frame X:(uint)x Y:(uint)y
{
    if (frame!=0)
    {
        @throw [NSException exceptionWithName:@"bad frame index" reason:@"Frame index must be zero." userInfo:nil];
    }
    
    return [spiritedArray pixelColorAtFrame:frozenFrame X:x Y:y];
}

@end

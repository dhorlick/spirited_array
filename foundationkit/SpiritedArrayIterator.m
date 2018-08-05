//
//  SpiritedArrayIterator.m
//  spiritedarray
//
//  Created by Dave Horlick on 10/29/12.
//  Copyleft 2012 River Porpoise Software
//

#import "SpiritedArrayIterator.h"

@implementation SpiritedArrayIterator

-(id)initWithSpiritedArray: (SpiritedArray*) designatedSpiritedArray;
{
    if (self = [super init])
    {
        spiritedArray = designatedSpiritedArray;
        width = [designatedSpiritedArray width];
        height = [designatedSpiritedArray height];
        frames = [designatedSpiritedArray frames];
        x = -1U;
        y = -1U;
        frame = -1U;
    }
    return self;
}

-(BOOL)rowHasAnotherPixel
{
    return x+1 < [spiritedArray width];
}

-(SAColorType)nextPixel
{
    if ([self rowHasAnotherPixel])
        x++;
    else
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"No more pixels available" userInfo:nil];
    
    return [spiritedArray pixelColorAtFrame:frame X:x Y:y];
}

-(BOOL)imageHasAnotherRow
{
    return y+1 < [spiritedArray height];
}

-(void)nextRow
{
    if ([self imageHasAnotherRow])
    {
        y++;
        x=-1;
    }
    else
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"No more rows." userInfo:nil];
}

-(BOOL)arrayHasAnotherFrame
{
    return frame+1 < [spiritedArray frames];
}

-(void)nextFrame
{
    if ([self arrayHasAnotherFrame])
    {
        frame++;
        x=-1;
        y=-1;
    }
    else
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"No more frames." userInfo:nil];
}

-(void)abandon
{
    if (frame>-1 || x>-1 || y>-1)
    {
        [spiritedArray close];
        frame = -1;
        x = -1;
        y = -1;
    }
}

- (void) close
{
    [spiritedArray close];
}

- (uint) delayInCentisAfterFrame: (uint)requestedFrame
{
    return [spiritedArray delayInCentisAfterFrame:requestedFrame];
}

@end

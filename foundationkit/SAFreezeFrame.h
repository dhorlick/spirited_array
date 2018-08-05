//
//  SAFreezeFrame.h
//  spiritedarray
//
//  Created by Dave Horlick on 11/11/12.
//  Copyleft 2012 River Porpoise Software
//

#import "SpiritedArray.h"

@interface SAFreezeFrame : SpiritedArray
{
    SpiritedArray* spiritedArray;
    uint frozenFrame;
}

-(SpiritedArray*) spiritedArray;

@end

//
//  OptimizedSpiritedArray.h
//  spiritedarray
//
//  Created by Dave Horlick on 11/12/12.
//  Copyleft 2012 River Porpoise Software
//

#import "SpiritedArray.h"

@interface OptimizedSpiritedArray : SpiritedArray
{
    SpiritedArray* spiritedArray;
}

- (id) initWith: (SpiritedArray*) designatedSpiritedArray;

@end

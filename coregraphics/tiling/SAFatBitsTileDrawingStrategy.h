//
//  SAFatBitsTileDrawingStrategy.h
//  spiritedarray
//
//  Created by Dave Horlick on 3/18/13.
//  Copyleft 2013 River Porpoise Software
//

#import <Foundation/Foundation.h>
#import "SATileDrawingStrategy.h"

@interface SAFatBitsTileDrawingStrategy : SATileDrawingStrategy
{
    uint metapixelWidthInPixelsMinusAnyTrim;
    uint metapixelHeightInPixelsMinusAnyTrim;
}
@end

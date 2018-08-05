//
//  SAGraphPaperTileDrawingStrategy.h
//  spiritedarray
//
//  Created by Dave Horlick on 9/15/13.
//  Copyleft 2013 River Porpoise Software
//

#import "SATileDrawingStrategy.h"

@interface SAGraphPaperTileDrawingStrategy : SATileDrawingStrategy
{
    uint metapixelWidthInPixelsMinusAnyTrim;
    uint metapixelHeightInPixelsMinusAnyTrim;
}
@end

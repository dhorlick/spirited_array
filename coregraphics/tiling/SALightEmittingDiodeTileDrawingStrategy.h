//
//  SALightEmittingDiodeTileDrawingStrategy.h
//  spiritedarray
//
//  Created by Dave Horlick on 3/18/13.
//  Copyleft 2013 River Porpoise Software
//

#import "SATileDrawingStrategy.h"

@interface SALightEmittingDiodeTileDrawingStrategy : SATileDrawingStrategy
{
    uint metapixelWidthInPixelsMinusAnyTrim;
    uint metapixelHeightInPixelsMinusAnyTrim;
    float centerGradientIntensityDelta; // 0 < x << 1
    float edgeGradientIntensityDelta; // 0 < x << 1
}
@end

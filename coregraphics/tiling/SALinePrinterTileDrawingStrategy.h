//
//  SALinePrinterTileDrawingStrategy.h
//  spiritedarray
//
//  Created by Dave Horlick on 8/18/13.
//  Copyleft 2013 River Porpoise Software
//

#import "SATileDrawingStrategy.h"

@interface SALinePrinterTileDrawingStrategy : SATileDrawingStrategy
{
    NSString* fontFamily;
    NSMutableArray* palette;
}

-(id) initWithFontFamily:(NSString*)designatedFontFamily;
-(NSString*) fontFamily;

@end

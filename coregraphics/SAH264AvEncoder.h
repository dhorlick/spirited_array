//
//  SAH264AvEncoder.h
//  spiritedarray
//
//  Created by Dave Horlick on 9/18/13.
//  Copyleft 2013 River Porpoise Software
//

#import <Foundation/Foundation.h>
#import "SAViewHelper.h"

@interface SAH264AvEncoder : NSObject
{
}

-(void) encode:(NSString*)spiritedArraySourceFilePath TileDrawingStrategy:tileDrawingStrategy WidthInPixels:(uint)widthInPixels HeightInPixels:(uint)heightInPixels TileWidthInPixels:(uint)tileWidthInPixels TileHeightInPixels:(uint)tileHeightInPixels BlurRadius:(uint)blurRadius Url:(NSURL*)url QuicktimeContainer:(BOOL)quicktimeContainer;

@end

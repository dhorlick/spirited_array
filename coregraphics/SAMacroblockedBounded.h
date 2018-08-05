//
//  SAH264Bounded.h
//  spiritedarray
//
//  Created by Dave Horlick on 9/22/13.
//  Copyleft 2013 River Porpoise Software
//

#import <Foundation/Foundation.h>

@interface SAMacroblockedBounded : NSObject
{
    uint macroblockWidth;
    uint macroblockHeight;
}

@property id bounded;

-(id)initWithBounded:(NSObject*) designatedBounded AndMacroblockOfWidth:(uint)designatedMacroblockWidth AndHeight:(uint)designatedMacroblockHeight;
-(NSRect)bounds;
+(NSRect)makeRectWithWidth:(int) width Height:(int) height;

@end

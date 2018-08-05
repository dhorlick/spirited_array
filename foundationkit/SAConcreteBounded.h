//
//  SAConcreteBounded.h
//  spiritedarray
//
//  Created by Dave Horlick on 10/4/13.
//  Copyleft 2013 River Porpoise Software
//

#import <Foundation/Foundation.h>

@interface SAConcreteBounded : NSObject
{
    NSRect bounds;
}

-(id) initWith: (NSRect)designatedRect;
-(NSRect)bounds;

@end

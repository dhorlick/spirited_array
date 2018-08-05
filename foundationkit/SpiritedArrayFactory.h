//
//  SpirtedArrayFactory.h
//  spiritedarray
//
//  Created by Dave Horlick on 8/27/13.
//  Copyleft 2013 River Porpoise Software
//

#import "SpiritedArray.h"
#import <Foundation/Foundation.h>

@interface SpiritedArrayFactory : NSObject

+(SpiritedArray *) build:(NSString *)imageFileName;
+(NSString*) fileExtension: (NSString*) string;

@end

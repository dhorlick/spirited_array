//
//  StreamedH264Decoder.h
//  spiritedarray
//
//  Created by Dave Horlick on 2/5/14.
//  Copyleft 2014 River Porpoise Software. All rights reserved.
//

#import "SpiritedArray.h"
#import <AVFoundation/AVFoundation.h>
#import "MemorizedSpiritedArray.h"

@interface StreamedH264Decoder : SpiritedArray
{
    BOOL ready;
    MemorizedSpiritedArray* memorized;
}
@end

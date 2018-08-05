//
//  SALayer.h
//  spiritedarray
//
//  Created by Dave Horlick on 3/13/13.
//  Copyleft 2013 River Porpoise Software
//

#import <QuartzCore/QuartzCore.h>
#import "SAViewHelper.h"

@interface SALayer : CALayer
{
    SAViewHelper* viewHelper;
}
// @property (nonatomic) uint frameIndex; // TODO add "assign"?
@property (nonatomic) int timeValue;

-(id)initWithViewHelper: (SAViewHelper*) designatedViewHelper;
-(SAViewHelper*) viewHelper;

@end

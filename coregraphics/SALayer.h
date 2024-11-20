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
	CALayer* blurLayer;
}
@property (nonatomic) int timeValue;
@property (nonatomic) float blurRadius;

-(id)initWithViewHelper: (SAViewHelper*) designatedViewHelper;
-(SAViewHelper*) viewHelper;
-(void)updateBlurLayer;

@end

//
//  SAView.m
//  spiritedarray
//
//  Created by Dave Horlick on 10/19/12.
//  Copyleft 2012 River Porpoise Software
//

#import "SAMacView.h"
#import "SALayer.h"
#import "SAAppDelegate.h"

@implementation SAMacView

-(void) setFrameSize: (NSSize)newSize
{
    [super setFrameSize:newSize];
    // NSLog(@"intercepted setFrameSize. new width = %f, new height = %f", newSize.width, newSize.height);
    self.layer.bounds = [self bounds];
    SALayer* saLayer = (SALayer*) self.layer;
    
    // TODO bounds has changed by more than one tile footprint…
    [[saLayer viewHelper] clearCachedSpiritedArray];
    [[saLayer viewHelper] regenerateStatusText];
}

@end

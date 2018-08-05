//
//  SAVideoExportSettingsController.m
//  spiritedarray
//
//  Created by Dave Horlick on 10/3/13.
//  Copyleft 2013 River Porpoise Software
//

#import "SAVideoExportSettingsController.h"

@implementation SAVideoExportSettingsController

- (IBAction)doExportDimensionsMoreOrLessWindowSize:(id)sender
{
    self.videoExportSettings.widthInPixels = [NSNumber numberWithUnsignedInt:self.initialWidthInPixels];
    self.videoExportSettings.heightInPixels = [NSNumber numberWithUnsignedInt:self.initialHeightInPixels];
}

- (IBAction)doExportDimensionsFullHighDef:(id)sender
{
    self.videoExportSettings.widthInPixels = [NSNumber numberWithUnsignedInt:1920U];
    self.videoExportSettings.heightInPixels = [NSNumber numberWithUnsignedInt:1080U];
}

- (IBAction)doExportDimensionsNonFullHighDef:(id)sender
{
    self.videoExportSettings.widthInPixels = [NSNumber numberWithUnsignedInt:1280U];
    self.videoExportSettings.heightInPixels = [NSNumber numberWithUnsignedInt:720U];
}

- (IBAction)doExportDimensionsMediumStandardDef:(id)sender
{
    self.videoExportSettings.widthInPixels = [NSNumber numberWithUnsignedInt:640U];
    self.videoExportSettings.heightInPixels = [NSNumber numberWithUnsignedInt:480U];
}

- (IBAction)doExportDimensionsSomewhatLargeWidescreen:(id)sender
{
    self.videoExportSettings.widthInPixels = [NSNumber numberWithUnsignedInt:853U];
    self.videoExportSettings.heightInPixels = [NSNumber numberWithUnsignedInt:480U];
}

- (void)awakeFromNib
{
    self.widthInPixelsTextField.delegate = self;
    self.heightInPixelsTextField.delegate = self;
}

- (BOOL)control:(NSControl *)control isValidObject:(id)object
{
    return [object isKindOfClass:[NSNumber class]];
}

@end

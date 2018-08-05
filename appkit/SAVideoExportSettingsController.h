//
//  SAVideoExportSettingsController.h
//  spiritedarray
//
//  Created by Dave Horlick on 10/3/13.
//  Copyleft 2013 River Porpoise Software
//

#import <Foundation/Foundation.h>
#import "SAVideoExportSettings.h"

@interface SAVideoExportSettingsController : NSObject < NSTextFieldDelegate >

@property (weak) IBOutlet NSTextField* widthInPixelsTextField;
@property (weak) IBOutlet NSTextField* heightInPixelsTextField;
@property (weak) IBOutlet NSMatrix* dimensionsRadioButtonMatrix;
@property (weak) IBOutlet SAVideoExportSettings* videoExportSettings;

@property uint initialWidthInPixels;
@property uint initialHeightInPixels;

- (IBAction)doExportDimensionsMoreOrLessWindowSize:(id)sender;
- (IBAction)doExportDimensionsFullHighDef:(id)sender;
- (IBAction)doExportDimensionsNonFullHighDef:(id)sender;
- (IBAction)doExportDimensionsMediumStandardDef:(id)sender;
- (IBAction)doExportDimensionsSomewhatLargeWidescreen:(id)sender;

@end

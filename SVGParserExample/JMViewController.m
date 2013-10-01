
#import "JMViewController.h"
#import "JMExampleView.h"

@interface JMViewController ()
@property (nonatomic) IBOutlet JMExampleView *exampleView;
@property (nonatomic) IBOutlet UISwitch *antialiasSwitch;
@end

@implementation JMViewController

- (IBAction)scaleSliderValueChanged:(UISlider *)sender
{
    self.exampleView.scale = sender.value;
    self.exampleView.shouldAntialias = self.antialiasSwitch.on;
    [self.exampleView setNeedsDisplay];
}

- (IBAction)antialiasSwitchWasTapped:(UISwitch *)sender {
    self.exampleView.shouldAntialias = self.antialiasSwitch.on;
    [self.exampleView setNeedsDisplay];
}

@end

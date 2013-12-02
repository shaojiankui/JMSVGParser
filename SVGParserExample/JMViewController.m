
#import "JMViewController.h"
#import "JMExampleView.h"
#import "JMSVGDocument.h"

@interface JMViewController ()
@property (nonatomic) IBOutlet JMExampleView *exampleView;
@property (nonatomic) IBOutlet UISwitch *antialiasSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
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

- (IBAction)buttonWastapped:(UIButton *)sender {
    self.imageView.image = [JMSVGDocument documentNamed:@"awesome_tiger"].image;
}

@end

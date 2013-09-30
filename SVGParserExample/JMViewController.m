
#import "JMViewController.h"
#import "JMSVGParser.h"
#import "JMStyledPath.h"

@interface JMExampleView ()
@property (nonatomic) CGFloat scale;
@property (nonatomic) NSArray *shapes;
@end

@implementation JMExampleView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (!(self = [super initWithCoder:aDecoder])) return nil;
    
    self.shapes = [JMSVGParser parseFileNamed:@"awesome_tiger"];
    self.scale = 1.f;
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), self.scale, self.scale);

    for (JMStyledPath *styledPath in self.shapes) {
        [styledPath drawStyledPath];
    }
}

@end
@interface JMViewController ()
@property (strong, nonatomic) IBOutlet JMExampleView *exampleView;

@end

@implementation JMViewController

- (IBAction)scaleSliderValueChanged:(UISlider *)sender
{
    self.exampleView.scale = sender.value;
    [self.exampleView setNeedsDisplay];
}

@end

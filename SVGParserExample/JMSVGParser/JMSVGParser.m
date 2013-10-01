
#import "JMSVGParser.h"
#import "JMStyledPath.h"
#import "JMStyledPathFactory.h"

@interface JMSVGParser () <NSXMLParserDelegate>
@property (nonatomic) NSMutableArray *paths;
@property (nonatomic) NSXMLParser *parser;
@end

@implementation JMSVGParser

+ (NSArray *)parseFileNamed:(NSString *)fileName;
{
    JMSVGParser *parser = [JMSVGParser.alloc initWithSVGDocument:[NSBundle.mainBundle pathForResource:fileName ofType:@"svg"]];
    if ([parser parse])
        return parser.paths;

    return nil;
}

- (id)initWithSVGDocument:(NSString *)path;
{
    if (!(self = [super init])) return nil;
    
    self.parser = [NSXMLParser.alloc initWithContentsOfURL:[NSURL fileURLWithPath:path]];
    self.parser.delegate = self;
    self.paths = NSMutableArray.new;
    return self;
}

- (BOOL)parse;
{
    BOOL didSucceed = [self.parser parse];
    if (self.parser.parserError)
        NSLog(@"parserError: %@", self.parser.parserError);

    return didSucceed;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    JMStyledPath *path = [JMStyledPathFactory styledPathWithElementName:elementName attributes:attributeDict];
    if (path)
        [self.paths addObject:path];
}

@end

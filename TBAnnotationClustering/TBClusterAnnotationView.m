//
//  TBClusterAnnotationView.m
//  TBAnnotationClustering
//
//  Created by Theodore Calmes on 10/4/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import "TBClusterAnnotationView.h"

CGPoint TBRectCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

CGRect TBCenterRect(CGRect rect, CGPoint center)
{
    CGRect r = CGRectMake(center.x - rect.size.width/2.0,
                          center.y - rect.size.height/2.0,
                          rect.size.width,
                          rect.size.height);
    return r;
}

static CGFloat const TBScaleFactorAlpha = 0.3;
static CGFloat const TBScaleFactorBeta = 0.4;

CGFloat TBScaledValueForValue(CGFloat value)
{
    return 1.0 / (1.0 + expf(-1 * TBScaleFactorAlpha * powf(value, TBScaleFactorBeta)));
}

@interface TBClusterAnnotationView ()
@end

@implementation TBClusterAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setCount:1];
    }
    return self;
}

- (void)setCount:(NSUInteger)count
{
    _count = count;

    CGRect newBounds = CGRectMake(0, 0, roundf(44 * TBScaledValueForValue(count)), roundf(44 * TBScaledValueForValue(count)));
    self.frame = TBCenterRect(newBounds, self.frame.origin);

    [self setNeedsDisplay:YES];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];

    CGContextSetAllowsAntialiasing(context, true);

    NSColor *outerCircleStrokeColor = [NSColor colorWithWhite:0 alpha:0.25];
    NSColor *innerCircleStrokeColor = [NSColor whiteColor];
    NSColor *innerCircleFillColor = [NSColor colorWithRed:(255.0 / 255.0) green:(95 / 255.0) blue:(42 / 255.0) alpha:1.0];

    CGRect circleFrame = CGRectInset(rect, 4, 4);

    [outerCircleStrokeColor setStroke];
    CGContextSetLineWidth(context, 5.0);
    CGContextStrokeEllipseInRect(context, circleFrame);

    [innerCircleStrokeColor setStroke];
    CGContextSetLineWidth(context, 4);
    CGContextStrokeEllipseInRect(context, circleFrame);

    [innerCircleFillColor setFill];
    CGContextFillEllipseInRect(context, circleFrame);
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];

    NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:style, NSParagraphStyleAttributeName, [NSColor whiteColor], NSForegroundColorAttributeName,[NSFont boldSystemFontOfSize:12],NSFontAttributeName,nil];
    
    
    CGRect viewRect = self.bounds;

    CGSize size = [[@(_count) stringValue] sizeWithAttributes:attr];
    float x_pos = (viewRect.size.width - size.width) / 2;
    float y_pos = (viewRect.size.height - size.height) /2;
    [[@(_count) stringValue] drawAtPoint:CGPointMake(viewRect.origin.x + x_pos, viewRect.origin.y + y_pos) withAttributes:attr];
}

@end

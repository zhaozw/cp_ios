//
//  MKAnnotationView+WebCache.m
//  customMapAnnotation
//
//  Created by Mohith K M on 9/26/11.
//  Copyright 2011 Mokriya  (www.mokriya.com). All rights reserved.
//

#import "MKAnnotationView+WebCache.h"
#import "SDWebImageManager.h"
#import "SDImageCache.h"


@implementation MKAnnotationView(WebCache)

- (void)setPin:(NSInteger)number hasCheckins:(BOOL)checkins hasVirtual:(BOOL)virtual isSolar:(BOOL)solar withLabel:(BOOL)withLabel {
    CGFloat fontSize = 20;
    NSString *imageName;
    CGRect labelFrame = CGRectNull;
    
    if (solar) {
        imageName = @"pin-solar";
    } else {
        // If no one is currently checked in, use the smaller image
        if (checkins) {
            if(virtual)
            {
                imageName = @"pin-virtual-checkedin";
                labelFrame = CGRectMake(0, 23, 93, 20);
            }
            else
            {
                imageName = @"pin-checkedin";
                labelFrame = CGRectMake(0, 15, 93, 20);
            }
        } else {       
            labelFrame = CGRectMake(0, 9, 54, 12);
            imageName = @"pin-checkedout";
            fontSize = 12;
        }
    }
    
    
    [self setImage:[UIImage imageNamed:imageName]];
    
    int subViewCount = self.subviews.count;
    if(subViewCount > 0)
    {
        if(subViewCount > 1)
        {
            //Ideally there would be a better way to identify the subviews
            NSLog(@"MultipleSubviews!  The incorrect subview could be getting hidden!");
        }
        [[self.subviews objectAtIndex:0] removeFromSuperview];
        
    }
    
    // Add number label
    if (withLabel && !CGRectIsNull(labelFrame)) {
        UILabel *numberLabel = [[UILabel alloc] initWithFrame:labelFrame];
        numberLabel.backgroundColor = [UIColor clearColor];
        numberLabel.opaque = NO;
        numberLabel.textColor = [UIColor whiteColor];
        numberLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:fontSize];
        numberLabel.textAlignment = UITextAlignmentCenter;
        
        numberLabel.text = [NSString stringWithFormat:@"%d", number];
        [self addSubview:numberLabel];
    }
}

- (void)setImage:(UIImage *)newImage fancy:(BOOL)fancyImage {
    UIImage *frame = [UIImage imageNamed:@"pin-frame"];
    
    UIGraphicsBeginImageContext(CGSizeMake(38, 43));
    [newImage drawInRect:CGRectMake(3, 3, 32, 32)];
    [frame drawInRect: CGRectMake(0, 0, 38, 43)];
    
    // NSLog(@"fancy image!");
    
    [self setImage:UIGraphicsGetImageFromCurrentImageContext()];
}

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil fancy:NO];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder fancy:(BOOL)fancyImage
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager cancelForDelegate:self];
    [self setImage:placeholder fancy:fancyImage];
    if (url)
    {
        [manager downloadWithURL:url delegate:self];
    }
}

- (void)cancelCurrentImageLoad
{
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    [self setImage:image fancy:YES];
}

@end
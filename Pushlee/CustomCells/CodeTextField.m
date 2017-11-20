//
//  CodeTextField.m
//  Pushlee
//
//  Created by AppsCreationTech on 12/20/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "CodeTextField.h"

@implementation CodeTextField

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.frame.size.height / 2.f;
}

- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    return CGRectZero;
}

@end

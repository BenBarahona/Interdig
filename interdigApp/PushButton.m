/**
 *  Siphon SIP-VoIP for iPhone and iPod Touch
 *  Copyright (C) 2008-2010 Samuel <samuelv0304@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#import "PushButton.h"


@implementation PushButton

/*
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
  return _contentRect;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{  
  CGRect rect = _contentRect;
    NSLog(@"TITLE> %@", self.titleLabel);
  CGSize titleSize = [[self titleForState:UIControlStateNormal] sizeWithFont: [self.titleLabel font]];

  rect.origin.x += (rect.size.width - titleSize.width)/2.;
  rect.origin.y = rect.size.height;
  rect.size.width  = titleSize.width;
  rect.size.height = titleSize.height;

  return rect;
}

- (CGRect)contentRectForBounds:(CGRect)bounds
{
  return _contentRect;
}*/

- (void)dealloc 
{
  //[_contentRect release];
  [super dealloc];
}

- (void)setContentRect:(CGRect)rect
{
    _contentRect = rect;
}

@end

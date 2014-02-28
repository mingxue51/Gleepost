//
//  GLPMacros.h
//  Gleepost
//
//  Created by Lukas on 11/13/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#ifndef Gleepost_GLPMacros_h
#define Gleepost_GLPMacros_h

#define CGRectAddX(v, x) \
v.frame = CGRectMake(v.frame.origin.x + x, \
v.frame.origin.y, \
v.frame.size.width, \
v.frame.size.height)

#define CGRectAddY(v, y) \
v.frame = CGRectMake(v.frame.origin.x, \
v.frame.origin.y + y, \
v.frame.size.width, \
v.frame.size.height)

#define CGRectAddXY(v, x, y) \
v.frame = CGRectMake(v.frame.origin.x + x, \
v.frame.origin.y + y, \
v.frame.size.width, \
v.frame.size.height)

#define CGRectAddW(v, w) \
v.frame = CGRectMake(v.frame.origin.x, \
v.frame.origin.y, \
v.frame.size.width + w, \
v.frame.size.height)

#define CGRectAddH(v, h) \
v.frame = CGRectMake(v.frame.origin.x, \
v.frame.origin.y, \
v.frame.size.width, \
v.frame.size.height + h)

#define CGRectAddWH(v, w, h) \
v.frame = CGRectMake(v.frame.origin.x, \
v.frame.origin.y, \
v.frame.size.width + w, \
v.frame.size.height + h)

#define CGRectSetX(v, x) \
v.frame = CGRectMake(x, \
v.frame.origin.y, \
v.frame.size.width, \
v.frame.size.height)

#define CGRectSetY(v, y) \
v.frame = CGRectMake(v.frame.origin.x, \
y, \
v.frame.size.width, \
v.frame.size.height)

#define CGRectSetXY(v, x, y) \
v.frame = CGRectMake(x, \
y, \
v.frame.size.width, \
v.frame.size.height)

#define CGRectSetW(v, w) \
v.frame = CGRectMake(v.frame.origin.x, \
v.frame.origin.y, \
w, \
v.frame.size.height)

#define CGRectSetH(v, h) \
v.frame = CGRectMake(v.frame.origin.x, \
v.frame.origin.y, \
v.frame.size.width, \
h)

#define CGRectSetWH(v, w, h) \
v.frame = CGRectMake(v.frame.origin.x, \
v.frame.origin.y, \
w, \
h)

#define CGRectSetBelow(v, below, verticalOffset) \
v.frame = CGRectMake(v.frame.origin.x, CGRectGetMaxY(below.frame) + verticalOffset, \
v.frame.size.width, v.frame.size.height)

#define CGRectMoveY(v, offset) \
v.frame = CGRectSetY(v, v.frame.origin.y + offset)

#endif

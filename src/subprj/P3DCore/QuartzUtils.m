//
//  QuartzUtils.m
//  Pleasant3D
//
//  Created by Eberhard Rensch on 02.08.09.
//  Copyright 2009 Pleasant Software. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify it under
//  the terms of the GNU General Public License as published by the Free Software 
//  Foundation; either version 3 of the License, or (at your option) any later 
//  version.
// 
//  This program is distributed in the hope that it will be useful, but WITHOUT ANY 
//  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
//  PARTICULAR PURPOSE. See the GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License along with 
//  this program; if not, see <http://www.gnu.org/licenses>.
// 
//  Additional permission under GNU GPL version 3 section 7
// 
//  If you modify this Program, or any covered work, by linking or combining it 
//  with the P3DCore.framework (or a modified version of that framework), 
//  containing parts covered by the terms of Pleasant Software's software license, 
//  the licensors of this Program grant you additional permission to convey the 
//  resulting work.
//

#import "QuartzUtils.h"


CGImageRef CreateCGImageFromFile( NSString *path )
{
    CGImageRef image = NULL;
    CFURLRef url = (__bridge CFURLRef) [NSURL fileURLWithPath: path];
    CGImageSourceRef src = CGImageSourceCreateWithURL(url, NULL);
    if( src ) {
        image = CGImageSourceCreateImageAtIndex(src, 0, NULL);
        CFRelease(src);
        if(!image)
            NSLog(@"Warning: CGImageSourceCreateImageAtIndex failed on file %@ (ptr size=%d)", path, (int)sizeof(void*));
    }
    return image;
}


CGImageRef GetCGImageNamed( NSString *name)
{
	return GetCGImageNamedFromBundleWithClass(name, nil);
}

CGImageRef GetCGImageNamedFromBundleWithClass( NSString *name, Class bundleClass)
{
    // For efficiency, loaded images are cached in a dictionary by name.
    static NSMutableDictionary *sMap=nil;
    if( ! sMap )
        sMap = [[NSMutableDictionary alloc] init];
    
    CGImageRef image = (__bridge CGImageRef) [sMap objectForKey: name];
    if( ! image ) {
        // Hasn't been cached yet, so load it:
        NSString *path;
        if( [name hasPrefix: @"/"] )
            path = name;
        else {
			if(bundleClass==nil)
				path = [[NSBundle mainBundle] pathForResource:name ofType: nil];
			else
				path = [[NSBundle bundleForClass:bundleClass] pathForResource:name ofType:nil];
            NSCAssert1(path,@"Couldn't find bundle image resource '%@'",name);
        }
        image = CreateCGImageFromFile(path);
        NSCAssert1(image,@"Failed to load image from %@",path);
        [sMap setObject: (__bridge id)image forKey: name];
        CFRelease(image);
    }
    return image;
}

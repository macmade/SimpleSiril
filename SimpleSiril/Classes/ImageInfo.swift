/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2023, Jean-David Gadina - www.xs-labs.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the Software), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

import Cocoa
import UniformTypeIdentifiers

public class ImageInfo: NSObject
{
    @objc public private( set ) dynamic var url:   URL
    @objc public private( set ) dynamic var name:  String
    @objc public private( set ) dynamic var size:  Int
    @objc public private( set ) dynamic var type:  String
    @objc public private( set ) dynamic var image: NSImage?

    public class func load( from url: URL ) -> [ ImageInfo ]
    {
        guard let enumerator = FileManager.default.enumerator( atPath: url.path( percentEncoded: false ) )
        else
        {
            return []
        }

        return enumerator.compactMap
        {
            enumerator.skipDescendants()

            guard let name = $0 as? String
            else
            {
                return nil
            }

            return ImageInfo(url: url.appendingPathComponent( name ) )
        }
    }

    public init?( url: URL )
    {
        guard let resources = try? url.resourceValues( forKeys: [ .totalFileSizeKey ] ),
              let size      = resources.totalFileSize,
              let type      = UTType( filenameExtension: url.pathExtension ),
              type.conforms( to: UTType.image ),
              FileManager.default.fileExists( atPath: url.path( percentEncoded: false ) )
        else
        {
            return nil
        }


        self.url   = url
        self.name  = url.lastPathComponent
        self.size  = size
        self.type  = type.localizedDescription ?? "Unknown"
        self.image = NSImage( byReferencing: url )
    }

    public override func isEqual( _ object: Any? ) -> Bool
    {
        guard let info = object as? ImageInfo
        else
        {
            return false
        }

        return self.url == info.url
    }

    public override func isEqual( to object: Any? ) -> Bool
    {
        self.isEqual( object as? ImageInfo )
    }

    public override var hash: Int
    {
        self.url.hashValue
    }
}

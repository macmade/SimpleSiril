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

public class ImagesSelectionViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate
{
    public enum Kind
    {
        case required
        case optional
    }

    @objc private dynamic var isOptional: Bool
    @objc private dynamic var isEnabled:  Bool
    @objc private dynamic var icon:       NSImage?
    @objc private dynamic var label1:     String
    @objc private dynamic var label2:     String
    @objc private dynamic var showImages: Bool
    @objc private dynamic var images:     [ ImageInfo ]

    @objc public dynamic var directory: URL?
    {
        didSet
        {
            self.update()
        }
    }

    private var timer: Timer?

    @IBOutlet private var tableView:       NSTableView?
    @IBOutlet private var arrayController: NSArrayController?

    public init( title: String, kind: Kind, directory: String? )
    {
        self.isOptional = kind == .optional
        self.isEnabled  = kind == .required
        self.label1     = ""
        self.label2     = ""
        self.showImages = false
        self.images     = []

        super.init( nibName: nil, bundle: nil )

        self.title = title

        if let directory = directory
        {
            self.directory = URL( filePath: directory )
        }
    }

    public required init?( coder: NSCoder )
    {
        nil
    }

    public override var nibName: NSNib.Name?
    {
        "ImagesSelectionViewController"
    }

    public override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView?.sizeLastColumnToFit()

        self.arrayController?.sortDescriptors =
            [
                NSSortDescriptor( key: "name", ascending: true )
            ]
    }

    public override func viewDidAppear()
    {
        super.viewDidAppear()
        self.update()

        self.timer = Timer.scheduledTimer( withTimeInterval: 1, repeats: true )
        {
            [ weak self ] _ in self?.update()
        }
    }

    public override func viewDidDisappear()
    {
        super.viewDidDisappear()
        self.timer?.invalidate()

        self.timer = nil
    }

    @IBAction
    public func showImage( _ sender: Any? )
    {
        guard let image = sender as? ImageInfo
        else
        {
            NSSound.beep()

            return
        }

        NSWorkspace.shared.open( image.url )
    }

    @IBAction
    private func chooseDirectory( _ sender: Any? )
    {
        guard let window = self.view.window
        else
        {
            NSSound.beep()

            return
        }

        let panel = NSOpenPanel()

        panel.canChooseFiles                = false
        panel.allowsMultipleSelection       = false
        panel.canChooseDirectories          = true
        panel.canCreateDirectories          = true
        panel.canDownloadUbiquitousContents = true

        panel.beginSheetModal( for: window )
        {
            if $0 == .OK, let url = panel.url
            {
                self.directory = url
            }
        }
    }

    @IBAction private func showImages( _ sender: Any? )
    {
        self.showImages = true
    }

    @IBAction private func hideImages( _ sender: Any? )
    {
        self.showImages = false
    }

    private func update()
    {
        var isDir = ObjCBool( booleanLiteral: false )

        guard let url = self.directory
        else
        {
            self.images = []
            self.icon   = NSImage( systemSymbolName: "folder.fill.badge.questionmark", accessibilityDescription: nil )
            self.label1 = "--"
            self.label2 = "No directory is set"

            return
        }

        guard FileManager.default.fileExists( atPath: url.path( percentEncoded: false ), isDirectory: &isDir ),
        isDir.boolValue
        else
        {
            self.icon   = NSImage( systemSymbolName: "folder.fill.badge.questionmark", accessibilityDescription: nil )
            self.images = []
            self.label1 = url.path( percentEncoded: false )
            self.label2 = "The directory does not exist"

            return
        }

        self.images = ImageInfo.load( from: url )
        self.icon   = NSWorkspace.shared.icon( forFile: url.path( percentEncoded: false ) )
        self.label1 = url.path( percentEncoded: false )
        self.label2 = if self.images.count == 0
        {
            "No image"
        }
        else if self.images.count == 1
        {
            "1 image"
        }
        else
        {
            "\( self.images.count ) images"
        }
    }

    public func tableView( _ tableView: NSTableView, shouldSelectRow row: Int ) -> Bool
    {
        false
    }
}

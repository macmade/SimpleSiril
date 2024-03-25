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

public class MainWindowController: NSWindowController
{
    @objc private dynamic var lightController: ImagesSelectionViewController
    @objc private dynamic var darkController:  ImagesSelectionViewController
    @objc private dynamic var flatController:  ImagesSelectionViewController
    @objc private dynamic var biasController:  ImagesSelectionViewController

    @IBOutlet private var stackView: NSStackView?

    @objc private dynamic var lightObserver: NSKeyValueObservation?
    @objc private dynamic var darkObserver:  NSKeyValueObservation?
    @objc private dynamic var flatObserver:  NSKeyValueObservation?
    @objc private dynamic var biasObserver:  NSKeyValueObservation?

    init()
    {
        self.lightController = ImagesSelectionViewController( title: "Light Frames",       kind: .required, directory: Preferences.shared.lightDirectory )
        self.darkController  = ImagesSelectionViewController( title: "Dark Frames",        kind: .optional, directory: Preferences.shared.darkDirectory )
        self.flatController  = ImagesSelectionViewController( title: "Flat Frames",        kind: .optional, directory: Preferences.shared.flatDirectory )
        self.biasController  = ImagesSelectionViewController( title: "Bias/Offset Frames", kind: .optional, directory: Preferences.shared.biasDirectory )

        super.init( window: nil )
    }

    required init?( coder: NSCoder )
    {
        nil
    }

    public override var windowNibName: NSNib.Name?
    {
        "MainWindowController"
    }

    public override func windowDidLoad()
    {
        super.windowDidLoad()

        self.addImageSelectionController( self.lightController, in: self.stackView )
        self.addImageSelectionController( self.darkController,  in: self.stackView )
        self.addImageSelectionController( self.flatController,  in: self.stackView )
        self.addImageSelectionController( self.biasController,  in: self.stackView )

        self.lightObserver = self.lightController.observe( \.directory ) { [ weak self ] o, c in Preferences.shared.lightDirectory = self?.lightController.directory?.path( percentEncoded: false ) }
        self.darkObserver  = self.darkController.observe(  \.directory ) { [ weak self ] o, c in Preferences.shared.darkDirectory  = self?.darkController.directory?.path(  percentEncoded: false ) }
        self.flatObserver  = self.flatController.observe(  \.directory ) { [ weak self ] o, c in Preferences.shared.flatDirectory  = self?.flatController.directory?.path(  percentEncoded: false ) }
        self.biasObserver  = self.biasController.observe(  \.directory ) { [ weak self ] o, c in Preferences.shared.biasDirectory  = self?.biasController.directory?.path(  percentEncoded: false ) }
    }

    private func addImageSelectionController( _ controller: NSViewController, in container: NSStackView? )
    {
        guard let container = container
        else
        {
            return
        }

        controller.view.translatesAutoresizingMaskIntoConstraints = false

        container.addView( controller.view, in: .center )
        container.addConstraint( NSLayoutConstraint( item: controller.view, attribute: .left,  relatedBy: .equal, toItem: container, attribute: .left,  multiplier: 1, constant: 0 ) )
        container.addConstraint( NSLayoutConstraint( item: controller.view, attribute: .right, relatedBy: .equal, toItem: container, attribute: .right, multiplier: 1, constant: 0 ) )
    }

    @IBAction
    private func showPreferences( _ sender: Any? )
    {
        guard let delegate = NSApp.delegate as? ApplicationDelegate
        else
        {
            NSSound.beep()

            return
        }

        delegate.showPreferencesWindow( sender )
    }
}

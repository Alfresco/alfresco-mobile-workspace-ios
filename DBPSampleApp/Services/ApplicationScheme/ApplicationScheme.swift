//
//  ApplicationScheme.swift
//  DBPSampleApp
//
//  Created by Emanuel Lupu on 08/10/2019.
//  Copyright © 2019 Alfresco. All rights reserved.
//

import UIKit
import MaterialComponents

class ApplicationScheme: NSObject {
    
    private static var singleton = ApplicationScheme()
    
    static var shared: ApplicationScheme {
        return singleton
    }
    
    override init() {
        self.buttonScheme.colorScheme = self.colorScheme
        self.buttonScheme.typographyScheme = self.typographyScheme
        super.init()
    }
    
    public let buttonScheme = MDCContainerScheme()
    
    public let colorScheme: MDCSemanticColorScheme = {
        let scheme = MDCSemanticColorScheme(defaults: .material201804)
        scheme.primaryColor = #colorLiteral(red: 0.2474783659, green: 0.6575964093, blue: 0.2639612854, alpha: 1)
        scheme.primaryColorVariant = #colorLiteral(red: 0, green: 0.4588235294, blue: 0.2901960784, alpha: 1)
        scheme.onPrimaryColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        scheme.secondaryColor = #colorLiteral(red: 0, green: 0.3333333333, blue: 0.7215686275, alpha: 1)
        scheme.onSecondaryColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        scheme.surfaceColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        scheme.onSurfaceColor = #colorLiteral(red: 0.2474783659, green: 0.6575964093, blue: 0.2639612854, alpha: 1)
        scheme.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        scheme.onBackgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.72)
        scheme.errorColor = #colorLiteral(red: 1, green: 0.2470588235, blue: 0.2666666667, alpha: 1)
        
        return scheme
    }()
    
    public let errorColorScheme: MDCSemanticColorScheme = {
        let scheme = MDCSemanticColorScheme(defaults: .material201804)
        scheme.primaryColor = #colorLiteral(red: 1, green: 0.2470588235, blue: 0.2666666667, alpha: 1)
        scheme.primaryColorVariant = #colorLiteral(red: 0, green: 0.4588235294, blue: 0.2901960784, alpha: 1)
        scheme.onPrimaryColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        scheme.secondaryColor = #colorLiteral(red: 0, green: 0.3333333333, blue: 0.7215686275, alpha: 1)
        scheme.onSecondaryColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        scheme.surfaceColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        scheme.onSurfaceColor = #colorLiteral(red: 1, green: 0.2470588235, blue: 0.2666666667, alpha: 1)
        scheme.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        scheme.onBackgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.72)
        scheme.errorColor = #colorLiteral(red: 1, green: 0.2470588235, blue: 0.2666666667, alpha: 1)
        
        return scheme
    } ()
    
    public let typographyScheme: MDCTypographyScheme = {
        let scheme = MDCTypographyScheme()
        
        let fontName = "Muli"
        scheme.headline5 = UIFont(name: fontName, size: 24)!
        scheme.headline6 = UIFont(name: fontName, size: 20)!
        scheme.subtitle1 = UIFont(name: fontName, size: 12)!
        scheme.button = UIFont(name: fontName, size: 14)!
        return scheme
    }()
    
    public let shapeScheme: MDCShapeScheming = {
        let scheme = MDCShapeScheme()
        return scheme
    }()
}

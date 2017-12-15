import Foundation

/**
 :nodoc:
 Encompasses all information necessary for creating a visual cue about a given `RouteStep`.
 */
@objc(MBVisualInstruction)
open class VisualInstruction: NSObject, NSSecureCoding {
    
    /**
     :nodoc:
     Distance in meters from the beginning of the step at which the visual instruction should be visible.
     */
    @objc public let distanceAlongStep: CLLocationDistance
    
    /**
     :nodoc:
     A plain text representation of `primaryTextComponents`.
     */
    @objc public let primaryText: String

    /**
     :nodoc:
     Most important visual content to convey to the user about the `RouteStep`.
     
     This is the structured representation of `primaryText`.
     */
    @objc public let primaryTextComponents: [VisualInstructionComponent]
    
    /**
     :nodoc:
     A plain text representation of `secondaryTextComponents`.
     */
    @objc public let secondaryText: String?
    
    /**
     :nodoc:
     Ancillary visual information about the `RouteStep`.
     
     This is the structured representation of `secondaryText`.
     */
    @objc public let secondaryTextComponents: [VisualInstructionComponent]?
    
    
    /**
     The type of maneuver.
     */
    public var maneuverType: ManeuverType?
    
    
    /**
     :nodoc:
     The type of maneuver.
     */
    public var maneuverDirection: ManeuverDirection?
    
    
    /**
     :nodoc:
     The direction in which the maneuver moves.
     */
    @objc public convenience init(json: [String: Any]) {
        let distanceAlongStep = json["distanceAlongGeometry"] as! CLLocationDistance
        
        let primaryTextComponent = json["primary"] as! JSONDictionary
        let primaryText = primaryTextComponent["text"] as! String
        let primaryTextComponents = (primaryTextComponent["components"] as! [JSONDictionary]).map {
            VisualInstructionComponent(json: $0)
        }
        
        var secondaryText: String?
        var secondaryTextComponents: [VisualInstructionComponent]?
        if let secondaryTextComponent = json["secondary"] as? JSONDictionary {
            secondaryText = secondaryTextComponent["text"] as? String
            secondaryTextComponents = (secondaryTextComponent["components"] as! [JSONDictionary]).map {
                VisualInstructionComponent(json: $0)
            }
        }
        
        var maneuverType: ManeuverType?
        if let maneuverString = json["type"] as? String, let type = ManeuverType(description: maneuverString) {
            maneuverType = type
        }
        
        var maneuverDirection: ManeuverDirection?
        if let maneuverDirectionString = json["modifier"] as? String, let directions = ManeuverDirection(description: maneuverDirectionString) {
            maneuverDirection = directions
        }
        
        self.init(distanceAlongStep: distanceAlongStep, primaryText: primaryText, primaryTextComponents: primaryTextComponents, secondaryText: secondaryText, secondaryTextComponents: secondaryTextComponents, maneuverType: maneuverType, maneuverDirection: maneuverDirection)
    }
    
    /**
     :nodoc:
     Initialize a `VisualInstruction`.
     */
    public init(distanceAlongStep: CLLocationDistance, primaryText: String, primaryTextComponents: [VisualInstructionComponent], secondaryText: String?, secondaryTextComponents: [VisualInstructionComponent]?, maneuverType: ManeuverType?, maneuverDirection: ManeuverDirection?) {
        self.distanceAlongStep = distanceAlongStep
        self.primaryText = primaryText
        self.primaryTextComponents = primaryTextComponents
        self.secondaryText = secondaryText
        self.secondaryTextComponents = secondaryTextComponents
        self.maneuverType = maneuverType
        self.maneuverDirection = maneuverDirection
    }
    
    public required init?(coder decoder: NSCoder) {
        distanceAlongStep = decoder.decodeDouble(forKey: "distanceAlongStep")
        
        guard let primaryText = decoder.decodeObject(of: NSString.self, forKey: "primaryText") as String? else {
            return nil
        }
        self.primaryText = primaryText
        
        primaryTextComponents = decoder.decodeObject(of: [NSArray.self, VisualInstructionComponent.self], forKey: "primaryTextComponents") as? [VisualInstructionComponent] ?? []
        
        guard let secondaryText = decoder.decodeObject(of: NSString.self, forKey: "primarysecondaryTextText") as String? else {
            return nil
        }
        self.secondaryText = secondaryText
        
        secondaryTextComponents = decoder.decodeObject(of: [NSArray.self, VisualInstructionComponent.self], forKey: "primaryTextComponents") as? [VisualInstructionComponent]
        
        if let maneuverTypeDescription = decoder.decodeObject(of: NSString.self, forKey: "maneuverType") as String? {
            maneuverType = ManeuverType(description: maneuverTypeDescription)
        } else {
            maneuverType = nil
        }
        
        if let maneuverDirectionDescription = decoder.decodeObject(of: NSString.self, forKey: "maneuverDirection") as String? {
            maneuverDirection = ManeuverDirection(description: maneuverDirectionDescription)
        } else {
            maneuverDirection = nil
        }
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(distanceAlongStep, forKey: "distanceAlongStep")
        coder.encode(primaryText, forKey: "primaryText")
        coder.encode(primaryTextComponents, forKey: "primaryTextComponents")
        coder.encode(secondaryText, forKey: "secondaryText")
        coder.encode(secondaryTextComponents, forKey: "secondaryTextComponents")
        coder.encode(maneuverType, forKey: "maneuverType")
        coder.encode(maneuverDirection, forKey: "maneuverDirection")
    }
}

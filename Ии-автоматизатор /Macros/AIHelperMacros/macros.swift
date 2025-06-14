import SwiftSyntaxMacros
import SwiftSyntax
import SwiftUI

public struct AutoCodableMacro: MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declNode: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let structDecl = declNode.as(StructDeclSyntax.self) else { return [] }
        var cases: [String] = []
        for member in structDecl.members.members {
            if let varDecl = member.decl.as(VariableDeclSyntax.self) {
                for binding in varDecl.bindings {
                    if let idPattern = binding.pattern.as(IdentifierPatternSyntax.self) {
                        let name = idPattern.identifier.text
                        cases.append("case \(name)")
                    }
                }
            }
        }
        let enumDecl = DeclSyntax(stringLiteral: """
        enum CodingKeys: String, CodingKey {
          \(cases.joined(separator: "\n          "))
        }
        """ )
        return [enumDecl]
    }
}

public struct AutoUIMacro: MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else { return [] }
        let structName = structDecl.identifier.text
        var uiLines: [String] = []

        // Iterate over stored properties and generate appropriate SwiftUI controls
        for member in structDecl.members.members {
            guard let varDecl = member.decl.as(VariableDeclSyntax.self) else { continue }
            for binding in varDecl.bindings {
                guard let idPattern = binding.pattern.as(IdentifierPatternSyntax.self) else { continue }
                let propName = idPattern.identifier.text

                // Determine the explicit type annotation, if any
                let rawType = binding.typeAnnotation?.type.description.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let baseType = rawType.replacingOccurrences(of: "?", with: "")

                let capitalized = propName.prefix(1).uppercased() + propName.dropFirst()
                let control: String
                switch baseType {
                case "String":
                    control = "TextField(\"\(capitalized)\", text: $model.\(propName))"
                case "Int", "Double", "Float":
                    control = "TextField(\"\(capitalized)\", value: $model.\(propName), format: .number)"
                case "Bool":
                    control = "Toggle(\"\(capitalized)\", isOn: $model.\(propName))"
                default:
                    control = "Text(\"\(capitalized): \\(model.\(propName))\")"
                }
                uiLines.append(control)
            }
        }

        let formContent = uiLines.joined(separator: "\n                ")

        let viewDecl = DeclSyntax(stringLiteral: """
        struct \(structName)FormView: View {
            @Binding var model: \(structName)

            var body: some View {
                Form {
                    Section(header: Text(\"\(structName)\")) {
                        \(formContent)
                    }
                }
            }
        }
        """)

        return [viewDecl]
    }
} 
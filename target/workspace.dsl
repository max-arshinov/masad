workspace "A minimal approach to software architecture documentation" {
    !identifiers hierarchical
    !include constants.dsl
    
    model {
        archetypes {
            !include archetypes.dsl
            !include internet-banking-system/archetypes.dsl
        }

        !include model.dsl
        !include deployment.dsl
    }

    views {
        theme default
        !include views.dsl
        styles {
            !include styles.dsl
        }
    }
}  
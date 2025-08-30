workspace "A minimal approach to software architecture documentation" {
    !identifiers hierarchical
    !include scripts.dsl
        
    model {
        # Enable nested groups support
        properties {
            "structurizr.groupSeparator" "/"
        }
        archetypes {
            !include archetypes.dsl
        }

        !include model.dsl        
    }

    views {
        theme default
        styles {
            !include styles.dsl
        }
    }
}  
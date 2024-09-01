workspace "A minimal approach to software architecture documentation" {
    !identifiers hierarchical

    model {
        !include model.dsl
        !include deployment.dsl
    }

    views {
        theme default
        theme https://static.structurizr.com/themes/amazon-web-services-2020.04.30/theme.json
#        !include views.dsl
        styles {
            !include styles.dsl
        }
    }
}  
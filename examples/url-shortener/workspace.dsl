workspace extends ../analytics-platform/workspace.dsl {
    name "URL Shortener"
    model {
        archetypes {
            !include archetypes.dsl
        }

        !include model.dsl
        !include deployment.dsl
    }

    views {
        #!include views.dsl
    }
}  
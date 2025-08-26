workspace extends ../base/workspace.dsl {
    name "Analytics System"
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

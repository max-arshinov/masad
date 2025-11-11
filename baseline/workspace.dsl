workspace extends ../base/workspace.dsl {
    name "PROVIDE YOUR WORKSPACE NAME HERE"
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
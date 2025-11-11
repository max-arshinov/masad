workspace extends ../base/workspace.dsl {
    name "PROVIDE YOUR WORKSPACE NAME HERE"
    model {
        archetypes {
            !include archetypes.dsl
        }

        !include model.dsl
    }

    views {
        #!include views.dsl
    }
}  
workspace extends ../base/workspace.dsl {
    name "Internet Banking System" 
    model {
        archetypes {
            !include archetypes.dsl
        }

        !include model.dsl
        !include deployment.dsl
    }

    views {
        !include views.dsl
    }
}  
deploymentEnvironment "Development" {
    !include deployment/dev.dsl
}

deploymentEnvironment "Live" {
    !include deployment/live.dsl
}

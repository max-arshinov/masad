devEnv = deploymentEnvironment "Development" {
    !include deployment/dev.dsl
}

liveEnv = deploymentEnvironment "Live" {
    !include deployment/live.dsl
}

urlDevEnv = deploymentEnvironment "Development A" {
    !include deployment/dev.dsl
}

urlLiveEnv = deploymentEnvironment "Live A" {
    !include deployment/live.dsl
}

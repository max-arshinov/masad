#C4
app = container {
    tag "Application"
}

spa = container {
    technology "JavaScript"
    tag "SPA"
}

angular = spa {
    tag "Web"
    technology "Angular"
}

react = spa {
    technology "React"
}

vue = spa {
    technology "Vue"
}

mobile = app {
    tag "Mobile"
}

datastore = container {
    tag "Database"
}

controller = component {
    tag "Controller"
}

mvc = app {
    tag "MVC"
}

#Deployment
dockerNode = deploymentNode {
    technology "Docker"
} 

browserNode = deploymentNode {
    technology "Chrome, Firefox, Safari, or Edge"
}

#Relationships
async = -> {
    tag "Async"
}
            
https = -> {
    technology "HTTPS"
}

hx = --https-> {
    technology "XML/HTTPS"
}

hj = --https-> {
    technology "JSON/HTTPS"
}

sql = -> {
    technology "SQL/TCP"
}
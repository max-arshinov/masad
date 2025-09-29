#Containers
app = container {
    tag "Application"
}

webApp = app {
    tag "Application"
}

api = container {
    tag "Application"
}

spa = container {
    technology "JavaScript"
    tag "Web"
}

angular = spa {
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
    tag "Datastore"
}

cache = datastore {
    tag "Cache"
}

broker = container {
    tag "Broker"
}

kafka = broker {
    tag "Broker"
}

# Components
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

tcp = -> {
    technology "TCP"
}

kafka = --async-> {
    technology "Kafka"
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
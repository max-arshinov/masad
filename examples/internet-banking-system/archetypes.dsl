oracle = datastore {
    technology "Oracle"
}

springBean = component {
    tag "Spring Bean"
}

springMvc = mvc {
    technology "Spring"
}

tomcat = deploymentNode {
    technology "Apache Tomcat 8.x"
}

ubuntuNode = deploymentNode {
    technology "Ubuntu 16.04 LTS"
}

#Deployment
oracleNode = deploymentNode {
    technology "Oracle 12c"
} 
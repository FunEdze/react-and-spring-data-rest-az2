# react-and-spring-data-rest

The application has a react frontend and a Spring Boot Rest API, packaged as a single module Maven application.

You can build the application running (`./mvnw clean verify`), that will generate a Spring Boot flat JAR in the target folder.

To start the application you can just run (`java -jar target/react-and-spring-data-rest-*.jar`), then you can call the API by using the following curl (shown with its output):

---

\$ curl -v -u greg:turnquist localhost:8080/api/employees/1
{
"firstName" : "Frodo",
"lastName" : "Baggins",
"description" : "ring bearer",
"manager" : {
"name" : "greg",
"roles" : [ "ROLE_MANAGER" ]
},
"\_links" : {
"self" : {
"href" : "http://localhost:8080/api/employees/1"
}
}
}

---

To see the frontend, navigate to http://localhost:8080. You are immediately redirected to a login form. Log in as `greg/turnquist`




Repository URL: [react-and-spring-data-rest-az2](https://github.com/FunEdze/react-and-spring-data-rest-az2.git)

### Overview
A cloud-native solution demonstrating:
- React Frontend
- Spring Boot Backend
- Azure Cloud Infrastructure
- Infrastructure as Code
- CI/CD Implementation

### Setup Requirements
1. **Azure Resources**
   - Azure Subscription
   - Azure DevOps Account

2. **Service Connection**
   - Name: Azure-Service-Connection-1

3. **Variable Groups**
   - AzureCredentials
   - DatabaseCredentials
   - InfrastructureDetails

### Deployment Order
```bash
1. infrastructure-pipeline.yml
2. backend-pipeline.yml
3. frontend-pipeline.yml
4. ingress-setup.yml
```

### Components
- Azure Kubernetes Service
- Azure Container Registry
- Azure SQL Database
- Azure Key Vault
- Kubernetes Deployments

### Quick Start
```bash
# Clone repository
git clone https://github.com/FunEdze/react-and-spring-data-rest-az2.git

# Set up pipelines in Azure DevOps
# Run in order mentioned above

# Get application URL
kubectl get service nginx-ingress-controller
```

### Cleanup
```bash
# Run destroy pipeline
infrastructure-destroy-pipeline.yml
```

For detailed setup and configuration, refer to individual component documentation.
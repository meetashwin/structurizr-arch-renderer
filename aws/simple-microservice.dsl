/*
    Reference AWS Architecture - https://docs.aws.amazon.com/whitepapers/latest/microservices-on-aws/simple-microservices-architecture-on-aws.html
*/
workspace "Amazon Example" "Simple microservices architecture on AWS" {

    model {
        simpleMicroservice = softwaresystem "AWS Simple Microservices" "A reference implementation of Microservices on AWS." {
            userInterface = container "User Interface" "Contains all User Interface components" {
                tags "UI"
            }
            computeImplementation = container "Computer Implementation" "Contains all Compute components" {
                tags "Compute"
            }
            dataStore = container "Data Store" "Contains all Datastore components" {
                tags = "Datastore"
            }
            amazonAurora = container "Relational Data Store" "Amazon Aurora RDS instance" {
                tags = "Amazon Web Services - RDS Amazon Aurora instance"
            }
        }
        
        userInterface -> computeImplementation ""
        computeImplementation -> dataStore ""
        
        prod = deploymentEnvironment "Production" {
            deploymentNode "AWS Microservices" {
                tags = "Amazon Web Services - Cloud"
                
                deploymentNode "User Interface" {
                    cloudFront = infrastructureNode "Amazon CloudFront" {
                        description "Highly scalable CDN on AWS"
                        tags "Amazon Web Services - CloudFront"
                    }
                    s3 = infrastructureNode "Amazon S3" {
                        description "Scalable object store"
                        tags "Amazon Web Services - Simple Storage Service S3"
                    }
                }
                
                deploymentNode "Compute implementation" {
                    newelb = infrastructureNode "Elastic Load Balancer" {
                        description "Automatically distributes incoming application traffic."
                        tags "Amazon Web Services - Elastic Load Balancing"
                    }
                    ecs = infrastructureNode "Amazon ECS" {
                        description "AWS Elastic Container Service"
                        tags "Amazon Web Services - Elastic Container Service Service"
                    }   
                }
                
                deploymentNode "Data Store" {
                    elasticache = infrastructureNode "Amazon ElastiCache" {
                        description "Amazon Aurora RDS instance"
                        tags "Amazon Web Services - ElastiCache For Redis"
                    }
                    aurora = infrastructureNode "Amazon Aurora" {
                        description "Amazon Aurora RDS instance"
                        tags "Amazon Web Services - RDS Amazon Aurora instance"
                    }
                    dynamodb = infrastructureNode "Amazon DynamoDB" {
                        description "Amazon DynamoDB datastore"
                        tags "Amazon Web Services - DynamoDB"
                    }
                }
            }
            
            cloudFront -> s3 ""
            cloudFront -> newelb ""
            newelb -> ecs ""
            ecs -> elasticache ""
            ecs -> aurora ""
            ecs -> dynamodb ""
        }
        
        springPetClinic = softwaresystem "Spring PetClinic" "Allows employees to view and manage information regarding the veterinarians, the clients, and their pets." {
            webApplication = container "Web Application" "Allows employees to view and manage information regarding the veterinarians, the clients, and their pets." "Java and Spring Boot" {
                tags "Application"
            }
            database = container "Data Store" "Stores information regarding the veterinarians, the clients, and their pets." "Relational database schema" {
                tags "Database"
            }
        }

        webApplication -> database "Reads from and writes to" "MySQL Protocol/SSL"

        live = deploymentEnvironment "Live" {

            deploymentNode "Amazon Web Services" {
                tags "Amazon Web Services - Cloud"

                region = deploymentNode "US-East-1" {
                    tags "Amazon Web Services - Region"

                    route53 = infrastructureNode "Route 53" {
                        description "Highly available and scalable cloud DNS service."
                        tags "Amazon Web Services - Route 53"
                    }

                    elb = infrastructureNode "Elastic Load Balancer" {
                        description "Automatically distributes incoming application traffic."
                        tags "Amazon Web Services - Elastic Load Balancing"
                    }

                    deploymentNode "Autoscaling group" {
                        tags "Amazon Web Services - Auto Scaling"

                        deploymentNode "Amazon EC2" {
                            tags "Amazon Web Services - EC2"

                            webApplicationInstance = containerInstance webApplication
                        }
                    }

                    deploymentNode "Amazon RDS" {
                        tags "Amazon Web Services - RDS"

                        deploymentNode "MySQL" {
                            tags "Amazon Web Services - RDS MySQL instance"

                            databaseInstance = containerInstance database
                        }
                    }

                }
            }

            route53 -> elb "Forwards requests to" "HTTPS"
            elb -> webApplicationInstance "Forwards requests to" "HTTPS"
        }
    }

    views {
        deployment springPetClinic "Live" "AmazonWebServicesDeployment" {
            include *
            autolayout lr

            animation {
                route53
                elb
                webApplicationInstance
                databaseInstance
            }
        }
        
        deployment simpleMicroservice "Production" "AmazonMicroservicesDeployment" {
            include *
            autolayout lr

            animation {
                cloudFront
                newelb
                s3
                ecs
                elasticache
                aurora
                dynamodb
            }
        }

        styles {
            element "Element" {
                shape roundedbox
                background #ffffff
            }
            element "Container" {
                background #ffffff
            }
            element "Application" {
                background #ffffff
            }
            element "Database" {
                shape cylinder
            }
        }

        themes https://static.structurizr.com/themes/amazon-web-services-2020.04.30/theme.json
    }

}
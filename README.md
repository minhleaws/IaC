# IaC
Infrastructure as Code Demo

```
# deployment
.
├── aws
│   └── us-east-1
│       └── dev
│           ├── db
│           │   ├── aurora-mysql
│           │   │   └── main.tf
│           │   ├── dynamodb
│           │   │   └── main.tf
│           │   └── elasticache-redis
│           │       └── main.tf
│           ├── eks
│           │   ├── cluster
│           │   │   ├── main.tf
│           │   │   └── outputs.tf
│           │   └── workloads
│           │       ├── main.tf
│           │       └── policies
│           │           ├── app.json
│           │           └── aws-lb-controller.json
│           └── network
│               ├── main.tf
│               ├── outputs.tf
│               ├── vpc-endpoints.tf
│               └── vpc-flowlogs.tf
└── gcp
    └── us-central-1
        └── dev
```

```
# modules
.
├── aws
│   ├── dynamodb
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── eks-cluster
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── eks-fargate-profile
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── eks-service-account
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── elasticache-redis
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── iam-role-policy
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── kms
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── network
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── rds-aurora
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── s3
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── security-group
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── sns
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
└── gcp
    └── todo.txt
```